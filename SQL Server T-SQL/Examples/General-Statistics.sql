 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	STATISTICS
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	show statistics and time data. Don't forget to click the "show actual plan" button if that's needed.
 -- 
		set statistics time on;
		set statistics io on;
		set statistics time, io on;
		set statistics xml on;			-- Basically equivalent to the "Show Actual Execution plan" button and won't do anything if that button is on, since they do the same thing.

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		2. The abaove statistics can be gathered from this query, with or without the set ... on command:
		Select top 1
			s.last_logical_reads,		
			s.last_physical_reads,
			s.last_elapsed_time,
			s.last_rows,
			s.last_execution_time,
			s.last_grant_kb,
			s.last_used_grant_kb,
			s.last_ideal_grant_kb
		From  sys.dm_exec_query_stats s
		Cross Apply sys.dm_exec_sql_text(s.sql_handle) as t
		Where t.Text = @queryText
		order by last_execution_time desc; 