 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	ERROR HANDLING
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	Generate an error to stop execution of this script
 --
		RAISERROR(N'Oops! This stuff isn''t ready for you. Better try that again later.', 20, 1) WITH LOG;
		GO
		THROW 51000, 'The record does not exist.', 1;  
		
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
			THROW 51000, 'The record does not exist.', 1;  
		END CATCH;
	
	/*
THROW 51000, 'The record does not exist.', 1;  
	err num >= 50000,
			err msg
				state 1-255.
	
Differences Between RAISERROR and THROW
The following table lists differences between the RAISERROR and THROW statements.

	RAISERROR statement								THROW statement
If a msg_id is passed to RAISERROR, 			The error_number parameter does not have to be defined in sys.messages. Must be >= 50000 
the ID 	must be defined in sys.messages.	

The msg_str parameter can contain 				The message parameter does not accept printf style formatting.
printf formatting styles.
	
The severity parameter specifies the 			There is no severity parameter. When THROW is used to initiate the exception, the severity is 
severity of the exception.						always set to 16. However, when THROW is used to re-throw an existing exception, the severity
												is set to that exception's severity level.
												
Does not honor SET XACT_ABORT.					Transactions will be rolled back if SET XACT_ABORT is ON.


issue a THROW inside a catch block without any parameters throws the error that was caught.
*/


USE tempdb;  
GO  
CREATE TABLE dbo.TestRethrow  
(    ID INT PRIMARY KEY  
);  
BEGIN TRY  
    INSERT dbo.TestRethrow(ID) VALUES(1);  
--  Force error 2627, Violation of PRIMARY KEY constraint to be raised.  
    INSERT dbo.TestRethrow(ID) VALUES(1);  
END TRY  
BEGIN CATCH  
  
    PRINT 'In catch block.';  
    THROW;  
END CATCH; 

/*

In catch block. 
Msg 2627, Level 14, State 1, Line 1  
Violation of PRIMARY KEY constraint 'PK__TestReth__3214EC272E3BD7D3'. Cannot insert duplicate key in object 'dbo.TestRethrow'.  
The statement has been terminated.

*/

