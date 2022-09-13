/*
  https://www.brentozar.com/archive/2016/07/logging-activity-using-sp_whoisactive-take-2/
  http://whoisactive.com/
  Schedule this code to run about every 30 - 60 seconds to capture what's going on at that moment.
  Make sure to set the destination database to a valid entry.

   To find out what's going on  :
select * from DBA_Tools.dbo.WhoIsActive
Where Collection_Time Between '2018-12-03 11:00:00' and '2018-12-03 12:00:00'
 -- and blocked_session_count > 0
order by collection_time, blocked_session_count desc;
*/
SET NOCOUNT ON;
 
DECLARE @retention INT = 14, --keep 14 days of data.
        @destination_table VARCHAR(500) = 'WhoIsActive',
        @destination_database sysname = 'DBA_Tools',
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;
 
SET @destination_table = @destination_database + '.dbo.' + @destination_table;
 
--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
								@find_block_leaders = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
        EXEC ( @schema );
    END;
 
--create index on collection_time
SET @SQL
    = 'USE ' + QUOTENAME(@destination_database)
      + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;
 
IF @exists = 0
    BEGIN;
        SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
        EXEC ( @SQL );
    END;
 
--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
						@find_block_leaders = 1,
                        @destination_table = @destination_table;
 
--purge older data
SET @SQL
    = 'DELETE FROM ' + @destination_table + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS VARCHAR(10))
      + ', GETDATE());';
EXEC ( @SQL );