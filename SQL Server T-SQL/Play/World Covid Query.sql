/* ==================================================================================
		World data by country
		https://stackoverflow.com/questions/10404348/sql-server-dynamic-pivot-query
		data from https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"
   ==================================================================================
*/
declare @cols as nvarchar(max), @query as nvarchar(max);

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(w.[location]) 
            FROM covid.world w
			where iso_code is null 
			  or  iso_code <> 'OWID_WRL'
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

--select @cols;
--select distinct [location] from covid.world where iso_code is null or iso_code <> 'OWID_WRL' order by 1

set @query = 'SELECT Cast(DataDate as date) wCase_Dt, ' + @cols + ' from 
            (
                select DataDate
                    , new_cases 
                    , [location]
                from covid.world
				where iso_code is null  or iso_code <> ''OWID_WRL''
           ) x
            pivot 
            (
                 sum(new_cases)
                for [location] in (' + @cols + ')
            ) p order by 1'

execute(@query)


set @query = 'SELECT Cast(DataDate as date) wDeath_Dt, ' + @cols + ' from 
            (
                select DataDate
                    , new_deaths 
                    , [location]
                from covid.world
				where iso_code is null  or iso_code <> ''OWID_WRL''
           ) x
            pivot 
            (
                 sum(new_deaths)
                for [location] in (' + @cols + ')
            ) p order by 1'

execute(@query);

--select sum([population]) from (
select distinct iso_code, continent, [location], [population]  
  from covid.world
  where [population] is not null
order by 4 desc
--) a

  -- 331,002,700.    E   +08

  select cast('1/22/2020 17:00 +0:00' as datetimeoffset(0))  AT TIME ZONE 'Eastern Standard Time', cast('2020-05-13 03:32:26 +0:00' as datetimeoffset(0)),
      convert(datetime2(0), '1/22/2020 17:00 +0:00') AT TIME ZONE 'Eastern Standard Time', convert(datetime2(0), '2020-05-13 03:32:26 +0:00') AT TIME ZONE 'Eastern Standard Time'
	  ;