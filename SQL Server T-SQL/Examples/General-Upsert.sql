 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	UPSERT
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