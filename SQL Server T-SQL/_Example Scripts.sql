RAISERROR(N'This file is for copy/paste and reading use, not for executing as a whole thing.', 20, 1) WITH LOG;
/*
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 
						This file will be a holder for common code blocks that I'm always having to look up the specific syntax for. 
						Hopefully, this cheat sheet will be useful!
 
 -- ==============================================================================================================================================================================================================================
		
		Availability Groups
			1.	Add DB to existing AG.
			2.	Apply logs manually to secondary node.
			3.	Remove DB from AG.
			4.	Exit proc if not running on the primary node.
		
		Error Handling
			1.	Raise an error (to stop scripts from executing, etc.). 
			2.	Error checking with try/catch

		General
			1.	Comma-separated lists
				a. STUFF ... For XML
				b. STRING_AGG
			2.	Cursors
			3.	Email
			4.	Identity Columns
				a.	Inserting into identity fields
				b.	Getting identity values back from inserts.
			5.	Pivot & unpivot
				Pivot turns rows into columns.
				Unpivot turns columns into rows.
			6.	Random numbers
			7.	Upsert
		
		Procedures: 			
			1.	Drop if Exists, 
			2.	Create or Replace Procedure / Basic syntax / set nocount, rowcount
			3.	Proc with output value
		
		Statistics
			1.	Set statistics on.
			2.	Get stats via sys.dm_exec_query_stats

		
		
		*See also "_Example Scripts.Bitwise Explanation.sql" for Bit operations
 -- ==============================================================================================================================================================================================================================  */
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	AVAILABILITY GROUPS
		-- When the DB is stuck in Not Synchronizing / Recovery Pending, do 3, then 2, then 1.
		-- https://dba.stackexchange.com/questions/129471/availability-group-database-stuck-in-not-synchronizing-recovery-pending-mode
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	-- Re-join database to availability group
		ALTER DATABASE [StackExchange.Bicycles.Meta] SET HADR AVAILABILITY GROUP = [SENetwork_AG];
		ALTER DATABASE [StackExchange.Bicycles.Meta] SET HADR RESUME;
 
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		2.	Apply logs manually to secondary node to catch up to prod.
		RESTORE LOG [StackExchange.Bicycles.Meta] FROM DISK = '\\ny-back01\backups\SQL\_Trans\SENetwork_AG\StackExchange.Bicycles.Meta\StackExchange.Bicycles.Meta_LOG_20160217_033201.trn' WITH NORECOVERY;
 
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		3.	Remove database from Availability Group:    
		Alter Database [StackExchange.Bicycles.Meta] SET HADR OFF;
 
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		4.	Exit procedure if not running on the primary node

		CREATE OR ALTER Procedure [dbo].[[OnlyRunOnPrimaryNode]
		as
		begin
			/* ----------------------------------------------------------------------------------------
				Only let this run on the primary node of the Availability Group; otherwise, exit.
				Declare @result int = 0;
				exec @result = [dbo].[[OnlyRunOnPrimaryNode] ;
				print @result; --- displays 1 on primary node, -1 on secondary node(s).
			---------------------------------------------------------------------------------------- */
			DECLARE @RoleDesc NVARCHAR(60);
			SELECT @RoleDesc = a.role_desc
			FROM sys.dm_hadr_availability_replica_states AS a
			JOIN sys.availability_replicas AS b ON b.replica_id = a.replica_id
			WHERE b.replica_server_name = @@SERVERNAME ;
			-- print 'RoleDesc: ' + isnull(@roleDesc, 'PRIMARY');
			IF isnull(@roleDesc, 'PRIMARY') <> 'PRIMARY' 
			Begin
				print('NOT the primary node. Exiting with no work done.');
				--Select 1/0  -- to throw an error instead of returning w/no results.
				Return -1;
			end;
			return 1
		End;
		go



 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	ERROR HANDLING
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	Generate an error to stop execution of this script
 --
		RAISERROR(N'Oops! This stuff isn''t ready for you. Better try that again later.', 20, 1) WITH LOG;
		GO
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		2.	Error Checking with rollback/commits.
 --
		Declare @ErrMsg nvarchar(max);
 		Begin Transaction;
		begin try
			--do something here.
			commit;
		END TRY
		BEGIN CATCH
			RollBack;
			SELECT @@ErrMsg = isnull(ERROR_NUMBER(), 0), @szErrMsg = 
				'Error: ' + Cast( isnull(ERROR_NUMBER(), 0) AS varChar) + 
				isnull('. State: ' + cast(ERROR_STATE() AS varchar), '') + 
				isnull('. Severity: ' + cast(ERROR_SEVERITY() AS varChar), '') + 
				isnull('. Procedure: ' + ERROR_PROCEDURE() , '') + 
				isnull('. Line: ' + cast(ERROR_LINE() as varchar), '') + '.   ' +
				isnull(ERROR_MESSAGE(), '') + '  ' ;
			--Do something with the error message
		END CATCH;
	
	
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	Generate comma-separated list as output from Select statement
			-- https://dba.stackexchange.com/questions/207371/please-explain-what-does-for-xml-path-type-value-nvarcharmax

			-- a.	Older method
			Select STUFF(
				/* The STUFF function inserts a string into another string.  */
				(
					/*	-- t.Name TableName, c.column_id, c.name ColumnName, ty.name TypeName
							Base query that returns columns and rows.
							Convert it such that it's a single column, comma separated.
							prepend an extra ,.
					*/
					select top 20	
						', ' + t.Name + ',' + cast(c.column_id as varchar) + ',' + c.name + ',' + ty.name
					from sys.tables				t
					inner join sys.all_columns	c	on c.object_id = t.object_id
					inner join sys.types		ty	on ty.user_type_id = c.user_type_id
					where is_ms_shipped = 0
					order by t.Name, c.column_id
					FOR XML PATH (''), TYPE
					/* For XML Path converts rows/cols into XMLfragment of <column name>column value</column name>. 
						The ('') is the row XML key, so no row elements. Change '' to ('Fred') to enclose each row in <Fred></Fred> elements.
						change ", TYPE" to "root('Bob')" to enclose the XML in <Bob></Bob> element.
						<TableName>Alerts</TableName><column_id>1</column_id><ColumnName>AlertID</ColumnName><TypeName>numeric</TypeName>
						<TableName>Alerts</TableName><column_id>2</column_id><ColumnName>AlertTime</ColumnName><TypeName>datetime2</TypeName>
					*/
			).value('.', 'NVARCHAR(MAX)'), 1, 2, '');
			/*   the . is an xQuery expression representing current node (the only node here).
				'(./text())[1]'     is faster for larger data sets. 
				The 1, 2, '' strips the leading , from the string.
			*/
				
			-- b. Newer method.
				/* in SQL 2017+, use STRING_AGG instead. Easier to read. */
				with cte as (
					/* Need a CTE, because we can't sort without it. */
					select top 20	
						t.Name + ',' + cast(c.column_id as varchar) + ',' + c.name + ',' + ty.name col1
					from sys.tables				t
					inner join sys.all_columns	c	on c.object_id = t.object_id
					inner join sys.types		ty	on ty.user_type_id = c.user_type_id
					where is_ms_shipped = 0
					order by t.Name, c.column_id
				)
				Select STRING_AGG(col1, ',')
				from cte;

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	2.	Cursors
		Declare @TableName 	varchar(500);
		Declare @ColumnID  	int;
		Declare @ColumnName	nvarchar(500);
		declare @ColumnType nvarchar(500);
		
		Declare c_TableColumns Cursor For
		select top 20	
			t.Name TableName, c.column_id, c.name ColumnName, ty.name TypeName
		from sys.tables				t
		inner join sys.all_columns	c	on c.object_id = t.object_id
		inner join sys.types		ty	on ty.user_type_id = c.user_type_id
		where is_ms_shipped = 0
		order by t.Name, c.column_id;
	
		Open c_TableColumns;
		Fetch Next From c_TableColumns Into @TableName, @ColumnID, @ColumnName, @ColumnType;
		While @@FETCH_STATUS = 0
		begin
			print @TableName + '.' + @ColumnName + ' ' + @ColumnType + '   --   ' + cast(@ColumnID as nvarchar);
			Fetch Next From c_TableColumns Into @TableName, @ColumnID, @ColumnName, @ColumnType;
		end;
		Close c_TableColumns;
		Deallocate c_TableColumns;

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	3.	Email
		--	https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-send-dbmail-transact-sql?view=sql-server-ver15

		Declare @sendTo nvarchar(500) = 'charles.moore@daytonohio.gov;test@example.com';
		Declare @emailCC nvarchar(500) = 'test2@example.com;test3@example.com');
		
		exec msdb.dbo.sp_send_dbmail @Recipients = @sendTo, @blind_copy_recipients = 'charles.moore@daytonohio.gov', 
			@body  = 'TESTING!', @Subject = 'Testing!',  @body_format = 'HTML', @copy_recipients = @emailCC;

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	4.	Identity columns

			--	a.	inserting into identity fields. 
				--	Only ONE table per session can have this set to on.
				SET IDENTITY_INSERT database.dbo.Table1 ON; 	-- Allows inserts into identity fields. 
				SET IDENTITY_INSERT database.dbo.Table1 OFF; 	-- Ends inserts into identity fields
			
			--	b.	Getting identity values
				Declare @ID int;
				set @ID = @@IDENTITY		 	-- function returns the last identity created for any table in the same session (The session is the database connection).
				set @ID = scope_identity() 	 	-- function returns the last identity created for any table in the same session and the same scope (the current query or the current stored procedure).
				set @ID = ident_current(name) 	-- returns the last identity created for a specific named table or view in any session.
												-- identity() function is not used to get an identity, it's used to create an identity in a select...into query.
				--  
				-- A situation where the scope_identity() and the @@IDENTITY functions differ, is
				--		if you have a trigger on the table. If you have a query that inserts a record, causing the trigger to insert another record somewhere, 
				--		the scope_identity() function will return the identity created by the query, while the @@identity function will return the identity created by the trigger.
				-- So, normally, use the scope_identity() function.

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	5. Pivot and Unpivot
 --			Pivot
 --			Unpivot turns columns into rows.
 
			CREATE OR ALTER FUNCTION dbo.GenerateUnpivotSql (@Sql NVARCHAR(MAX))
			RETURNS NVARCHAR(MAX) AS
			/* https://michaeljswart.com/2022/09/this-function-generates-unpivot-syntax/
				declare @sql nvarchar(max) ='SELECT * FROM sys.databases WHERE database_id = 2';
				declare @newsql nvarchar(max) = dbo.GenerateUnpivotSql (@sql);
				exec sp_executesql @sql;
				exec sp_executesql @newsql;
			*/
			BEGIN 
			RETURN '
			WITH Q AS 
			(
			SELECT TOP (1) ' + 
			(
				SELECT 
				STRING_AGG(
					CAST(
					'CAST(' + QUOTENAME(NAME) + ' AS sql_variant) AS ' + QUOTENAME(NAME) 
					AS NVARCHAR(MAX)
					), ',
				'
				)
				FROM sys.dm_exec_describe_first_result_set(@sql, DEFAULT, DEFAULT)
			) + '
			FROM ( 
				' + @sql + '
			) AS O 
			)
			SELECT U.FieldName, U.FieldValue
			FROM Q
			UNPIVOT (FieldValue FOR FieldName IN (' +
			(
				SELECT STRING_AGG( CAST( QUOTENAME(name) AS NVARCHAR(MAX) ), ',
			' ) 
			FROM sys.dm_exec_describe_first_result_set(@sql, DEFAULT, DEFAULT)
			) + '
			)) AS U';
			END
			GO



 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	6.	Random numbers
			-- https://stackoverflow.com/questions/1045138/how-do-i-generate-a-random-number-for-each-row-in-a-t-sql-select
			-- https://web.archive.org/web/20110829015850/http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/sql-server-set-based-random-numbers
	
			-- ABS(CHECKSUM(NewID())) % {range} + {Min}
			Select ABS(CHECKSUM(NewID())) % 19 + 1  -- this will give a range between 1 and 20
	
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	7.	UPSERT
			-- https://michaeljswart.com/2017/07/sql-server-upsert-patterns-and-antipatterns/#InsideaSerializableTransactionWithLockHints
			--https://sqlperformance.com/2020/09/locking/upsert-anti-pattern
			-- update it; if nothing gets updated, insert it:
			--UPDLOCK is used to protect against conversion deadlocks at the statement level (let another session wait instead of encouraging a victim to retry).
			--SERIALIZABLE is used to protect against changes to the underlying data throughout the transaction (ensure a row that doesn't exist continues to not exist).
			CREATE PROCEDURE s_AccountDetails_Upsert ( @Email nvarchar(4000), @Etc nvarchar(max) )
			AS 
			BEGIN TRAN
			-- top 1 to guarantee only 1 row. (In this example, email is PK)
			UPDATE TOP (1) dbo.AccountDetails WITH (UPDLOCK, SERIALIZABLE)
				SET Etc = @Etc
			WHERE Email = @Email;
			
			IF (@@ROWCOUNT = 0)
			BEGIN      
				INSERT dbo.AccountDetails ( Email, Etc )
				VALUES ( @Email, @Etc );
			END 
			COMMIT
	
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	PROCEDURES
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	Drop a procedure if it exists.
 --
		DROP PROCEDURE IF EXISTS [dbo].[DoSomethingWithYourLife]
		GO

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		2.	Create or Replace Procedure / Basic syntax / set nocount, rowcount
		CREATE OR ALTER Procedure [dbo].[SampleProcedure] (
			@inSomeValue int = 0,	/* Hey, look, it's a value. */
			@inOtherValue int = 0,	/* Oh, my, it's another value. */
			@inDebug bit = 0	    /* if set to 1, print extra details for debugging */
		)
		as
		/* this isn't a great example...
			but at least it has comments!
			-- exec dbo.SampleProcedure 2, 4, 1 -- returns 1 row: 	2	4	6.   Prints Message: inSomeValue: 2. inOtherValue: 4
		*/
		Begin
			set nocount on; /*	When SET NOCOUNT is ON, the "(1 row affected)" stuff isn't sent.
								When SET NOCOUNT is OFF, the row count is returned.
								The @@ROWCOUNT function is updated even when SET NOCOUNT is ON. */
			set rowcount 0; /* 	0 = off/all rows are returned. SET ROWCOUNT > 0 is equivalent to Select Top ...
								This overrides the SELECT statement TOP keyword if the rowcount is the smaller value. */
			If @inDebug = 1
				print 'inSomeValue: ' + cast(@inSomeValue as varchar) + '. inOtherValue: ' + cast(@inOtherValue as varchar);		
			
			Select @inSomevalue [SomeValue], @inOtherValue [OtherValue], @inSomeValue + @inOtherValue [SumValue];
		End;

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		3.	Procedure that has an output value
 		CREATE OR ALTER Procedure [dbo].[SampleProcedure] (
			@inSomeValue int = 0,	/* Hey, look, it's a value. */
			@inOtherValue int = 0,	/* Oh, my, it's another value. */
			@inDebug bit = 0	    /* if set to 1, print extra details for debugging */
			@SumValue int OUTPUT
		)
		as
		/* this isn't a great example...
			but at least it has comments!
			-- exec dbo.SampleProcedure 2, 4, 1, @SumValue = @MyValue OUTPUT    -- returns 1 row: 	2	4	6.   Prints Message: inSomeValue: 2. inOtherValue: 4. Stores the sum in @MyValue
		*/
		Begin
			set nocount on; /*	When SET NOCOUNT is ON, the "(1 row affected)" stuff isn't sent.
								When SET NOCOUNT is OFF, the row count is returned.
								The @@ROWCOUNT function is updated even when SET NOCOUNT is ON. */
			set rowcount 0; /* 	0 = off/all rows are returned. SET ROWCOUNT > 0 is equivalent to Select Top ...
								This overrides the SELECT statement TOP keyword if the rowcount is the smaller value. */
			If @inDebug = 1
				print 'inSomeValue: ' + cast(@inSomeValue as varchar) + '. inOtherValue: ' + cast(@inOtherValue as varchar);		
			
			Select @inSomevalue [SomeValue], @inOtherValue [OtherValue], @inSomeValue + @inOtherValue [SumValue];
			
			@SumValue = @inSomeValue + @inOtherValue;
		End;

 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	STATISTICS
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	show statistics and time data. Don't forget to click the "show actual plan" button if that's needed.
 -- 
		set statistics time on;
		set statistics io on;
		set statistics time, io on;
		set statistics xml on;			-- Basically equivalent to the "Show Actual Execution plan" button and won't work if that button is on, since they do the same thing.

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		2. The abaove statistics can be gathered from this query:
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
 
 



	

	