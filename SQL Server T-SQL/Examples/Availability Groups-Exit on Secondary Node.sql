 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 --	AVAILABILITY GROUPS
  
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		Exit procedure if not running on the primary node

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