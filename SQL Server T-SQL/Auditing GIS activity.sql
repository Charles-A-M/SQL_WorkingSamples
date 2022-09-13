--2019-06-12T11:15:53,495
--select top 500 * from ExtendedEvents where Client_Hostname = 'GIS-KINGZ-PC'

select * from (
select  DatePart(dd, corrected_time) [Day], 
	datePart(HH, corrected_time) [Hour],
	Client_Hostname,
	--Database_Name, 
	 case when substring(client_app_name, 1, 3) = 'SDE' then 'SDE'
	   when substring(client_app_name, 1, 6) = 'ArcGIS' then 'ArcGIS'
	   else Client_App_Name end [ClientApp],
	--substring(client_app_name, 1, 3) [ClientApp], 
	--username, 
	case when message is null then '' else 'Yes' end [Failed], 
	count(*) [Count]
  from ExtendedEvents 
where  Corrected_Time between cast('2019-06-03T00:00:00.000' as datetime2) and SYSDATETIME()  --cast('2019-06-12T14:45:00.000' as datetime2)
  and server_instance_name in ('WTRSQLGISPD-1', 'WTRSQLGISPD-2')
  and Database_Name not in ('ReportServer', 'msdb')
  and username not in ('CODWTR\sqlagent', 'CODWTR\cmadmin',  'CODWTR\sqlEngine', 'NT SERVICE\SQLTELEMETRY', 'CODWTR\spbackup')
  and Client_App_Name <> 'Always On Operations Dashboard'
  --group by  DatePart(dd, corrected_time), DatePart(HH, corrected_time), Database_Name, Client_Hostname, substring(client_app_name, 1, 3), username, message
  group by  DatePart(dd, corrected_time), DatePart(HH, corrected_time), Client_Hostname,
	case when substring(client_app_name, 1, 3) = 'SDE' then 'SDE'
	   when substring(client_app_name, 1, 6) = 'ArcGIS' then 'ArcGIS'
	  else Client_App_Name end,
	--username, 
	case when message is null then '' else 'Yes' end
 -- order by 1, 2, 3
 ) as srcTable PIVOT(sum([Count]) For [Hour] in ( [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23]
 )) as PivotTale
 order by [Day], Client_Hostname, [ClientApp]  --, username;



 select * from (
 select  DatePart(dd, corrected_time) [Day], 
	--datePart(HH, corrected_time) [Hour],
	Client_Hostname,
	--Database_Name, 
	 case when substring(client_app_name, 1, 3) = 'SDE' then 'SDE'
	   when substring(client_app_name, 1, 6) = 'ArcGIS' then 'ArcGIS'
	   else Client_App_Name end [ClientApp],
	--substring(client_app_name, 1, 3) [ClientApp], 
	--username, 
	case when message is null then '' else 'Yes' end [Failed], 
	count(*) [Count]
  from ExtendedEvents 
where  Corrected_Time between cast('2019-06-01T00:00:00.000' as datetime2) and SYSDATETIME()  --cast('2019-06-12T14:45:00.000' as datetime2)
  and server_instance_name in ('WTRSQLGISPD-1', 'WTRSQLGISPD-2')
  and Database_Name not in ('ReportServer', 'msdb')
  and username not in ('CODWTR\sqlagent', 'CODWTR\cmadmin',  'CODWTR\sqlEngine', 'NT SERVICE\SQLTELEMETRY', 'CODWTR\spbackup')
  and Client_App_Name <> 'Always On Operations Dashboard'
  --group by  DatePart(dd, corrected_time), DatePart(HH, corrected_time), Database_Name, Client_Hostname, substring(client_app_name, 1, 3), username, message
  group by  DatePart(dd, corrected_time), --DatePart(HH, corrected_time), 
	Client_Hostname,
	case when substring(client_app_name, 1, 3) = 'SDE' then 'SDE'
	   when substring(client_app_name, 1, 6) = 'ArcGIS' then 'ArcGIS'
	  else Client_App_Name end,
	--username, 
	case when message is null then '' else 'Yes' end
 ) as srcTable PIVOT(sum([Count])
	 For [Day] in ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23]
	 )) as PivotTale
 order by Client_Hostname, [ClientApp]