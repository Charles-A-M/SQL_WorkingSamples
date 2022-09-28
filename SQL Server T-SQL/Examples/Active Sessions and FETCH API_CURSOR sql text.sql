-- kill 59;

EXEC sp_WhoIsActive
    @find_block_leaders = 1,
    @sort_order = '[blocked_session_count] DESC, session_id'

 -- resolve the FETCH API_CURSOR.... cursors to their underlying query:
SELECT c.session_id, c.properties, c.creation_time, c.is_open, t.text
FROM sys.dm_exec_cursors (0) c
CROSS APPLY sys.dm_exec_sql_text (c.sql_handle) t

-- https://www.sqlskills.com/blogs/joe/hunting-down-the-origins-of-fetch-api_cursor-and-sp_cursorfetch/
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cursors-transact-sql?view=sql-server-ver16



