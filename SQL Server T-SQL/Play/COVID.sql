/*
--
-- -------------------------------------------------------------------------------------------
-- WORLD
--
declare @colsGlobal as nvarchar(max);
SET @colsGlobal = STUFF((SELECT distinct ',' + QUOTENAME(j.country_region) 
            FROM covid.jhu_global j 
            where len(j.country_region) > 1
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');
declare @queryGlobalConf as nvarchar(max);
set @queryGlobalConf = 'SELECT Last_Update  worldCases, ' + @colsGlobal + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , confirmed 
                    , country_region
                from covid.jhu_global
           ) x
            pivot 
            (
                sum(confirmed) 
                for country_region in (' + @colsGlobal + ')
            ) p order by 1';
execute(@queryGlobalConf);

declare @queryGlobalDth as nvarchar(max);
set @queryGlobalDth = 'SELECT Last_Update  worldDeaths, ' + @colsGlobal + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , deaths 
                    , country_region
                from covid.jhu_global
           ) x
            pivot 
            (
                sum(deaths) 
                for country_region in (' + @colsGlobal + ')
            ) p order by 1';
execute(@queryGlobalDth); 
--
-- -------------------------------------------------------------------------------------------
-- USA
--
declare @colsUS as nvarchar(max);
set @colsUS  = STUFF((SELECT distinct ',' + QUOTENAME(j.Province_State) 
            FROM covid.jhu_us j
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');
declare @colsOH as nvarchar(max);
set @colsOH  = STUFF((SELECT distinct ',' + QUOTENAME(j.admin2) 
            FROM covid.jhu_us j
			where Province_State = 'Ohio'
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,''); 
declare @queryUSConf as nvarchar(max);
set @queryUSConf = 'SELECT Last_Update  USCases, ' + @colsUS + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , confirmed 
                    , province_state
                from covid.jhu_US
           ) x
            pivot 
            (
                sum(confirmed) 
                for province_state in (' + @colsUS + ')
            ) p order by 1';
execute(@queryUSConf);
 
declare @queryUSDth as nvarchar(max);
set @queryUSDth = 'SELECT Last_Update  USDeaths, ' + @colsUS + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , deaths 
                    , province_state
                from covid.jhu_US
           ) x
            pivot 
            (
                sum(deaths) 
                for Province_state in (' + @colsUS + ')
            ) p order by 1';
execute(@queryUSDth); 
--
-- -------------------------------------------------------------------------------------------
-- OH
--
declare @queryOHConf as nvarchar(max);
set @queryOhConf = 'SELECT Last_Update  ohCases, ' + @colsOH + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , confirmed 
                    , admin2
                from covid.jhu_US
				where province_state = ''Ohio''
           ) x
            pivot 
            (
                sum(confirmed) 
                for admin2 in (' + @colsOH + ')
            ) p order by 1';
execute(@queryohConf);   
declare @queryOhDth as nvarchar(max);
set @queryOhDth = 'SELECT Last_Update  ohDeaths, ' + @colsOH + ' from 
            (
                select Cast(LastUpdate as date) Last_Update
                    , deaths 
                    , admin2
                from covid.jhu_US
				where province_state = ''Ohio''
           ) x
            pivot 
            (
                sum(deaths) 
                for admin2 in (' + @colsOH + ')
            ) p order by 1';
execute(@queryohDth); 
--
-- -------------------------------------------------------------------------------------------
-- TN? KY?
--

 select Cast(LastUpdate as date) Last_Update
                    , deaths 
					, confirmed
                    , admin2
                from covid.jhu_US
				where province_state = 'Ohio'
				order by Last_Update, admin2


select 
	Cast(LastUpdate as date) Last_Update
    , sum(confirmed) confirmed
	, sum(deaths) deaths
from covid.jhu_global
group by Cast(LastUpdate as date)
order by 1


 --


 --Create View covid.TN_Henry_Summary as 

with Global1 as (
select Cast(LastUpdate as date) Last_Update
		, sum(confirmed) Confirmed
		, sum(deaths) Deaths
  from covid.jhu_US
  where province_state = 'Tennessee'
    and admin2 = 'Henry'
 group by Cast(LastUpdate as date)
 ), Global2 as (
 select Last_Update, 
		Confirmed, 
		Confirmed - LAG(Confirmed, 1, 0) OVER (Order By Last_Update) [New Confirmed],
		Deaths,
		Deaths - LAG(Deaths, 1, 0) OVER (Order By Last_Update) [New Deaths]
   from Global1
)
select Last_Update, 
	Confirmed,
	[New Confirmed],
	/* these don't work. Not sure why the values are wrong.
	AVG([New Confirmed] ) OVER (Order by Last_Update asc ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING) [7 Day Avg Confirmed 1],
	AVG([New Confirmed] ) OVER (Order by Last_Update asc ROWS BETWEEN 7 PRECEDING AND 0 FOLLOWING) [7 Day Avg Confirmed 2],
	AVG([New Confirmed] ) OVER (Order by Last_Update asc ROWS BETWEEN 8 PRECEDING AND 0 FOLLOWING) [7 Day Avg Confirmed 3],
	AVG([New Confirmed] ) OVER (Order by Last_Update asc ROWS BETWEEN 7 PRECEDING AND 1 FOLLOWING) [7 Day Avg Confirmed 4], */
	-- this will be NULL for the 1st 6 rows:
	(	[New Confirmed] + 
		LAG([New Confirmed], 1) OVER (Order By Last_Update) + 
		LAG([New Confirmed], 2) OVER (Order By Last_Update) + 
		LAG([New Confirmed], 3) OVER (Order By Last_Update) + 
		LAG([New Confirmed], 4) OVER (Order By Last_Update) + 
		LAG([New Confirmed], 5) OVER (Order By Last_Update) + 
		LAG([New Confirmed], 6) OVER (Order By Last_Update) ) / 7.0 [7 Day Avg New Confirmed], 
	Deaths,
	[New Deaths],
	(	[New Deaths] + 
		LAG([New Deaths], 1) OVER (Order By Last_Update) + 
		LAG([New Deaths], 2) OVER (Order By Last_Update) + 
		LAG([New Deaths], 3) OVER (Order By Last_Update) + 
		LAG([New Deaths], 4) OVER (Order By Last_Update) + 
		LAG([New Deaths], 5) OVER (Order By Last_Update) + 
		LAG([New Deaths], 6) OVER (Order By Last_Update) ) / 7.0 [7 Day Avg New Deaths]
  from Global2



 

select Cast(LastUpdate as date) Last_Update
    , sum(confirmed) confirmed
	, sum(deaths) deaths
 from covid.jhu_US
 where province_state = 'Tennessee'
 group by Cast(LastUpdate as date)
order by 1

select Cast(LastUpdate as date) Last_Update
    , sum(confirmed) confirmed
	, sum(deaths) deaths
 from covid.jhu_US
 where province_state = 'Tennessee'
 group by Cast(LastUpdate as date)
order by 1
*/
 