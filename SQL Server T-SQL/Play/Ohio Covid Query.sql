/* ==================================================================================
		Ohio data by county
		https://stackoverflow.com/questions/10404348/sql-server-dynamic-pivot-query
		data from https://coronavirus.ohio.gov/
   ==================================================================================
*/

declare @cols as nvarchar(max), @query as nvarchar(max);

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.County) 
            FROM covid.ohio c
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');

--select @cols

set @query = 'SELECT Cast(onsetDate as date) oCase_dt, ' + @cols + ' from 
            (
                select onsetDate
                    , caseCount 
                    , County
                from covid.ohio
           ) x
            pivot 
            (
                 sum(caseCount)
                for County in (' + @cols + ')
            ) p order by 1';

execute(@query)


set @query = 'SELECT Cast(onsetDate as date) oDeath_Dt, ' + @cols + ' from 
            (
                select onsetDate
                    , deathCount 
                    , County
                from covid.ohio
           ) x
            pivot 
            (
                 sum(deathCount)
                for County in (' + @cols + ')
            ) p order by 1'


execute(@query)


set @query = 'SELECT Cast(onsetDate as date) Hosp_dt, ' + @cols + ' from 
            (
                select onsetDate
                    , HospitalCount
                    , County
                from Covid.Ohio
           ) x
            pivot 
            (
                 sum(HospitalCount)
                for County in (' + @cols + ')
            ) p order by 1'


--execute(@query);

/*

select datereported, cumulativeCasesUS, cumulativeDeathsUS
 from covid.who
 where countryCode = 'US'
 order by 1
 ;

select datereported, sum(cumulativeCases) CumCases, sum(cumulativeDeaths) CumDeaths
 from covid.who
group by DateReported
 order by 1
 ;

 */