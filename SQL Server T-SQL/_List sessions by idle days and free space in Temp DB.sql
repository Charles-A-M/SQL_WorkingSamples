Use TempDB
Go

Select sum(FreeMB) free_mb, 
	sum(SizeMB) size_mb, 
	100 - (( sum(FreeMB) / sum(SizeMB) ) * 100) PctUsed, 
	( sum(FreeMB) / sum(SizeMB) ) * 100 PctFree
from (
	select sum(Size) * 8.0 / 1024 SizeMB, 0.0 FreeMB
	  from sys.database_files
	  where type_desc = 'LOG'
	union all
    SELECT 0, (total_log_size_in_bytes - used_log_space_in_bytes)*1.0/1024/1024 
	  FROM sys.dm_db_log_space_usage
) a

-- exec sp_who2
-- https://social.msdn.microsoft.com/Forums/sqlserver/en-US/b15b5c0f-d78f-4b56-999f-6d63d83838b0/performance-impact-due-to-sleeping-sessions?forum=sqldatabaseengine
SELECT 
	  sessions.session_id
	, sessions.status
	, sessions.last_request_start_time
	, sessions.last_request_end_time
	, sessions.memory_usage*8 AS mem_used_KB
	--, tasks.task_state
	, sessions.login_name
	, sessions.login_time
	, sessions.host_name
	, sessions.program_name
	, datediff(d, sessions.login_time, SYSDATETIME() ) LoggedInDays
	, datediff(d, sessions.last_request_end_time, sysDateTime() ) IdleDays,
	'KILL ' + cast(sessions.session_id as varchar(25)) + '; ' Kill_me
FROM sys.dm_exec_connections AS connections
JOIN sys.dm_exec_sessions AS sessions ON
	sessions.session_id = connections.session_id
LEFT JOIN sys.dm_os_tasks AS tasks ON
	tasks.session_id = sessions.session_id
where  sessions.host_name <> @@SERVERNAME  --649 rows as of 11:32
     and task_state is null 
	 and datediff(d, sessions.last_request_end_time, sysDateTime() ) > 1 --28 rows 
ORDER BY
	 datediff(d, sessions.last_request_end_time, sysDateTime() ) desc


