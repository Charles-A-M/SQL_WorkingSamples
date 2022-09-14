 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	Email
		--	https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-send-dbmail-transact-sql?view=sql-server-ver15

		Declare @sendTo nvarchar(500) = 'test@example.com';
		Declare @emailCC nvarchar(500) = 'test2@example.com;test3@example.com');
		
		exec msdb.dbo.sp_send_dbmail @Recipients = @sendTo, @blind_copy_recipients = 'test4@example.com', 
			@body  = 'TESTING!', @Subject = 'Testing!',  @body_format = 'HTML', @copy_recipients = @emailCC;