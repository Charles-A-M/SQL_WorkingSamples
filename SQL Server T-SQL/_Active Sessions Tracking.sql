/*
--https://www.brentozar.com/archive/2016/07/logging-activity-using-sp_whoisactive-take-2/
select * from DBA_Tools.dbo.WhoIsActive
Where Collection_Time Between '2018-12-03 11:00:00' and '2018-12-03 12:00:00'
 and blocked_session_count > 0
order by collection_time, blocked_session_count desc;

EXEC sp_WhoIsActive 
    @find_block_leaders = 1, @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
    @sort_order = '[blocked_session_count] DESC

exec sp_BlitzLock

--select * from sys.dm_exec_sessions order by login_time;
/*
-- https://sqlworkbooks.com/2017/06/using-sp_whoisactive-with-temp-tables-to-limit-data-collected/
use DBA_Tools;
go

DECLARE @whoisactive_table VARCHAR(4000) ;
DECLARE @schema VARCHAR(4000) ;
SET @whoisactive_table = QUOTENAME ('dbo') + '.' + QUOTENAME ('WhoIsActive_tempdb')
EXEC master.dbo.sp_WhoIsActive
  @output_column_list = '[tempdb%][%]',
  @get_plans = 1,
  @return_schema = 1,
  @format_output = 0,
  @schema = @schema OUTPUT ;
SET @schema = REPLACE(@schema, '<table_name>', @whoisactive_table) ;
EXEC(@schema) ;

delete from DBA_Tools.dbo.WhoIsActive_tempdb;

EXEC master.dbo.sp_WhoIsActive
  @output_column_list = '[tempdb%][%]',
  @get_plans = 1,
  @format_output = 0,
  @destination_table = 'DBA_Tools.dbo.WhoIsActive_tempdb';
  */

/*
--https://social.msdn.microsoft.com/Forums/sqlserver/en-US/7d57d59b-69ae-48e1-8cac-a9bbabb3f873/the-transaction-log-for-database-database-is-full-due-to-activetransaction?forum=sqldatabaseengine
Use SDE
dbcc opentran
-- SPID = 237
dbcc inputbuffer(237)

select * from sys.sysprocesses where spid=237 
*/


exec sp_who2;

select * from dbo.WhoIsActive_tempdb
 where blocking_session_id is not null;
 --89,90
 select * from dbo.WhoIsActive_tempdb
where session_id in (237, 523, 89, 90, 71)
or blocking_session_id in (237, 523)
order by login_time 

-- kill 147