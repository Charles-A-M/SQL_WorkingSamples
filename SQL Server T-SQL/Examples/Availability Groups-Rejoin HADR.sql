 THROW 51000, 'Why are you here?', 1;  
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