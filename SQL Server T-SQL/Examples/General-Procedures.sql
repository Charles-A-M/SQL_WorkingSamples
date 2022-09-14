 THROW 51000, 'Why are you here?', 1;  
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
			set nocount on; 	/*	ON	:	the "(1 row affected)" stuff isn't sent.
									OFF	:	the row count is returned.
									Note:	The @@ROWCOUNT function is updated even when SET NOCOUNT is ON. 	*/
			set rowcount 0; 	/* 	0	:	off/all rows are returned. 
									> 0 :	equivalent to Select Top ...
									Note:	This overrides the SELECT TOP keyword if the rowcount is the smaller value. 	*/
			SET XACT_ABORT on;  /*	ON	:	If Transact-SQL statement raises a run-time error, the entire transaction is terminated and rolled back.
									OFF	:	in some cases only the Transact-SQL statement that raised the error is rolled back and the transaction continues processing. 
									Note:	The THROW statement honors SET XACT_ABORT. RAISERROR does not. New applications should use THROW instead of RAISERROR.	*/
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
			-- the calling code will now have a new value in @sumValue.
		End;