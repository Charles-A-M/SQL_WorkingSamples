 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	Identity columns

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