/*  https://gist.github.com/SQLAdrian/db6d23498321fc90bcd463fd0e479080
Core assumptions:
1. All thigs being equal except for CPU usage
2. Memory power consumption remains statatic
3. Storage power consumption remains static
4. Hyperthreading enabled
5. Base CPU consumption remains static
	Refer to https://www.kompulsa.com/much-power-computers-consume/,
	Base Watt Usage of CPU = =IF([@Basefreq]<2.2,75,IF([@Basefreq]<3.2,60,50))
6. CPU power usage per vCPU calculated as follows
	Refer to https://www.kompulsa.com/much-power-computers-consume/, then
	Per vCPU Usage Watt =[@Cores]*2*IF([@Basefreq]<2.2,1.5,IF([@Basefreq]<3.2,2.5,ROUND([@Basefreq],0)))
7. Conversion rate of 1 kWh = 0.5kg (This can vary per country). 1W = 0.5g of CO2
https://www.goclimate.com/blog/the-carbon-footprint-of-servers/ >> 
https://i.dell.com/sites/csdocuments/CorpComm_Docs/en/carbon-footprint-poweredge-r640.pdf >>
https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/poweredge-r640-spec-sheet.pdf
Lifetime:
4 years 
Lifetime CO2
7730 kgCO2e
Will cost $316 to offset with https://ekos.co.nz/gift-packs
1760.3 kWh for 56 CPUs
https://www.infoq.com/articles/power-consumption-servers/
https://en.wikipedia.org/wiki/List_of_CPU_power_dissipation_figures#Xeon_(Six_Core,_Core-based)
https://outervision.com/power-supply-calculator
https://www.anandtech.com/show/15044/the-amd-ryzen-threadripper-3960x-and-3970x-review-24-and-32-cores-on-7nm/2
When a single core is active, it consumes ~13.5 watts. This slowly goes down when more cores get loaded, 
but at 6 cores loaded we are still consuming ~12 watts per core. 
Even at 16 cores loaded, we’re still around 10 watts per core. This is pretty impressive. 
At full core loading, we’re fluctuating between 6 and 11 watts per core, 
as workloads get moved around to manage core loading.
Base of 75W plus 1W @ 2GHz, 2.5W @ 3.0GHz and 3W @ 4GHz
----
Offset SQL only. Calculate CPU cycles used since startup
Calculate cycles for last 5 hours
compare to SQL ring buffer usage.
Calculate CPU speed mulitply by number of cores and utilization
------
Indexes:
Now to convert 1 Cost to 1 Watt.
Easier to convert cost of query to overall SQL CPU usage
As soon as we have the cost of the query as %, we can correlate with SQL CPU usage accross n CPU cores.
Calculate speed and multiply by 
*/
--------------------------------

DECLARE @cpu_speed_mhz int
DECLARE @cpu_speed_ghz decimal(18,2);

EXEC master.sys.xp_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                            @key = 'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
                            @value_name = '~MHz',
                            @value = @cpu_speed_mhz OUTPUT;

SELECT @cpu_speed_ghz = CAST(CAST(@cpu_speed_mhz AS DECIMAL) / 1000 AS DECIMAL(18,2));


DECLARE @CPUcount INT
DECLARE @CPUsocketcount INT
DECLARE @CPUHyperthreadratio INT
	SELECT @CPUcount = cpu_count 
	, @CPUsocketcount = [cpu_count] / [hyperthread_ratio]
	, @CPUHyperthreadratio = [hyperthread_ratio]
	FROM sys.dm_os_sys_info;
		
DECLARE @BaseWatt MONEY
SELECT @BaseWatt = 
CASE 
	WHEN @cpu_speed_ghz < 2.2 THEN 55
	WHEN @cpu_speed_ghz BETWEEN 2.2 AND 2.5  THEN 50
	WHEN @cpu_speed_ghz BETWEEN 2.5 AND 2.8  THEN 45
	WHEN @cpu_speed_ghz BETWEEN 2.8 AND 3.2  THEN 40
	WHEN @cpu_speed_ghz > 3.2 THEN 35
END

DECLARE @WattperCPU MONEY
SELECT @WattperCPU = 
CASE 
	WHEN @cpu_speed_ghz < 2 THEN 1
	WHEN @cpu_speed_ghz BETWEEN 2.0 AND 2.5  THEN 2
	WHEN @cpu_speed_ghz BETWEEN 2.5 AND 2.8  THEN 3
	WHEN @cpu_speed_ghz BETWEEN 2.8 AND 3.2  THEN 3.5
	WHEN @cpu_speed_ghz > 3.2 THEN 4
END

DECLARE @TotalWatt MONEY
SELECT @TotalWatt = @BaseWatt +(@WattperCPU *@CPUcount)
DECLARE @ts BIGINT
SELECT @ts =(
	SELECT cpu_ticks/(cpu_ticks/ms_ticks)
	FROM sys.dm_os_sys_info 
	) OPTION (RECOMPILE)
SET STATISTICS IO, TIME ON

DECLARE @avgcpu MONEY
	
SELECT @avgcpu = AVG(SQLProcessUtilization) 
		FROM 
		(
			SELECT 
			record.value('(./Record/@id)[1]','int') AS record_id
			, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','money') AS [SystemIdle]
			, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','money') AS [SQLProcessUtilization]
			, [timestamp]
			FROM 
			(
				SELECT
				[timestamp]
				, convert(xml, record) AS [record] 
				FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE'%%'
			)AS x
		) as y

SELECT 
query_plan
, execution_count
, [AvgCPU(ms)]
, [OverallCPUUsage%] [Average 5 hour CPU %]
, OverallWatt
, 0.5 * OverallWatt [g CO2e]
, CONVERT(MONEY, 0.5 * OverallWatt * 4.8 /*makes a day*/ * 365 /*Makes a year*/ /1000) /*Makes a kilogram */[kg CO2e per year]
FROM (
SELECT TOP 1000
[Plan]
, [AvgCPU(ms)]
, total_worker_time 
,(total_worker_time) *100 / SUM(total_worker_time ) OVER (  PARTITION BY 1.00  ) * @avgcpu/100 [OverallCPUUsage%]
,(total_worker_time) *100 / SUM(total_worker_time ) OVER (  PARTITION BY 1.00  ) * @avgcpu/100/100 * @TotalWatt [OverallWatt]
,[AvgDuration(ms)]
 ,AvgReads
, execution_count
, qp.query_plan
FROM (
SELECT TOP 100/* No export: qp.query_plan,*/
plan_handle [Plan]
,SUM(total_worker_time)/AVG(execution_count)/1000 AS [AvgCPU(ms)]
,SUM(CONVERT(MONEY,total_worker_time))  total_worker_time
--,SUM(total_worker_time)  *100 / SUM(total_worker_time ) OVER (  PARTITION BY 1.00  ) * @avgcpu/
, SUM(total_elapsed_time)/AVG(execution_count)/1000 AS [AvgDuration(ms)]
--, CONVERT(MONEY,SUM(total_worker_time ) OVER (  PARTITION BY plan_handle  ))*100 /  SUM(total_worker_time ) OVER (  PARTITION BY 1.00  )[PlanSQLCPUUsage%]
--, @avgcpu * CONVERT(MONEY,SUM(total_worker_time ) OVER (  PARTITION BY plan_handle  ))*100 /  SUM(total_worker_time ) OVER (  PARTITION BY 1.00  ) [PlanServerCPUUsage%]
--, CONVERT(MONEY,SUM(total_worker_time ) OVER (  PARTITION BY plan_handle  )) /  SUM(total_worker_time ) OVER (  PARTITION BY 1.00  ) * @TotalWatt *  @avgcpu [PlanWatts]

, (SUM(total_logical_reads)+SUM(total_physical_reads))/AVG(execution_count) AS AvgReads 
, AVG(execution_count ) execution_count
FROM sys.dm_exec_query_stats qs
GROUP BY plan_handle
ORDER BY total_worker_time DESC
) T1
cross apply sys.dm_exec_query_plan([Plan]) qp
ORDER BY total_worker_time DESC
) T2
WHERE query_plan is not NULL