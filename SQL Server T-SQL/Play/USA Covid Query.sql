/* ==================================================================================
		USA data by state.
		https://stackoverflow.com/questions/10404348/sql-server-dynamic-pivot-query
		data from https://covidtracking.com/data/download
   ==================================================================================
*/
declare @cols as nvarchar(max), @query as nvarchar(max);

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(u.[state]) 
            FROM covid.usa u
			order by 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

--select @cols
-- 

set @query = 'SELECT  uDeath_Dt, ' + @cols + ' from
	(
		select cast(lastupdateEt as date) uDeath_Dt, [deathIncrease], [state] ST
		from covid.usa 
	) x
	pivot
	(
		sum( [deathIncrease] ) for ST in (' + @cols + ')
	) p order by 1 '

execute(@query);

set @query = 'SELECT uCase_Dt, ' + @cols + ' from
	(
		select  cast(lastupdateEt as date) uCase_dt, [positiveIncrease], [state] ST
		from covid.usa 
	) x
	pivot
	(
		sum( [positiveIncrease] ) for ST in (' + @cols + ')
	) p order by 1 '

execute(@query);

