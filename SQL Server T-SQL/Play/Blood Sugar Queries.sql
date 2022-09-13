/*
BolusSource:
CLOSED_LOOP_FOOD_BOLUS
CLOSED_LOOP_BG_CORRECTION
CLOSED_LOOP_BG_CORRECTION_AND_FOOD_BOLUS
MANUAL
BOLUS_WIZARD
CLOSED_LOOP_MICRO_BOLUS
*/

print(' Gathering temp data... ');

IF OBJECT_ID('tempdb..#Medtronic1') IS NOT NULL DROP TABLE #Medtronic1;
GO
select
	   dateadd(minute, datediff(minute,0,date_time) / 60 * 60, 0) date_time_rounded
	   , isnull(BG_Reading, SensorGlucose) BG
	   , BolusVolumeDelivered
	   , BolusSource
	   , BasalRate
	     /* , TempBasalType, TempBasalAmount, TempBasalDuration, */
	   , case when BasalRate is not null then BasalRate / 60
	          when BolusSource = 'CLOSED_LOOP_MICRO_BOLUS' then BolusVolumeDelivered
		      else null
	     end Basal 
	   , case when BolusSource <> 'CLOSED_LOOP_MICRO_BOLUS' then BolusVolumeDelivered else null end OtherBolus
  into #medtronic1
  FROM [CharlesTest].[dbo].[MedtronicData]
 order by 1
;

print(' Summarizing temp data... ');

IF OBJECT_ID('tempdb..#Medtronic2') IS NOT NULL DROP TABLE #Medtronic2;
GO
Select date_time_rounded
  	   , sum(Basal) Basal
	   , avg(bg) BG
       , sum(OtherBolus) Bolus
  into #medtronic2
  from #medtronic1
 group by date_time_rounded
 order by 1;

select count(distinct cast(date_time_rounded as date)) [Days of Data], min(cast(date_time_rounded as date)) [First Date], max(cast(date_time_rounded as date)) [Last Date] from #medtronic2;

print(' Reporting data... ');

select mTime [Basal Data], 
       [Sunday], 
       [Monday], 
       [Tuesday], 
       [Wednesday], 
       [Thursday], 
       [Friday],
	   [Saturday]
  From ( Select cast(date_time_rounded as time) mTime, 
	            dateName(weekday, date_time_rounded) [Day],
	            Basal
	       from #medtronic2
       ) p pivot (
	     avg (Basal)
	     For  [Day] in ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])
       ) pvt
 order by 1;
  
select mTime [Avg Bolus], 
       [Sunday], 
       [Monday], 
       [Tuesday], 
       [Wednesday], 
       [Thursday], 
       [Friday],
	   [Saturday]
  From ( Select cast(date_time_rounded as time) mTime, 
	            dateName(weekday, date_time_rounded) [Day],
	            Bolus
	       from #medtronic2
       ) p pivot (
	     avg (Bolus)
	     For  [Day] in ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])
       ) pvt
 order by 1;


select mTime [Avg BG], 
       [Sunday], 
       [Monday], 
       [Tuesday], 
       [Wednesday], 
       [Thursday], 
       [Friday],
	   [Saturday]
  From ( Select cast(date_time_rounded as time) mTime, 
	            dateName(weekday, date_time_rounded) [Day],
	            BG
	       from #medtronic2
       ) p pivot (
	     avg (BG)
	     For  [Day] in ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])
       ) pvt
 order by 1;


 
 /*
 as of 2021-09-13, 30-day avg:

 150.9 u/day
  basal: 94.1 / 62%
  bolus 56.8 / 38%
 */

 