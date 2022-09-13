-- https://dba.stackexchange.com/questions/129471/availability-group-database-stuck-in-not-synchronizing-recovery-pending-mode

-- For when the DB is stuck in Not Synchronizing / Recovery Pending.


-- Remove database from Availability Group:    
Alter Database [StackExchange.Bicycles.Meta] SET HADR OFF;

-- Apply t-logs to catch up. This can be done manually in SSMS or via:
RESTORE LOG [StackExchange.Bicycles.Meta] FROM DISK = '\\ny-back01\backups\SQL\_Trans\SENetwork_AG\StackExchange.Bicycles.Meta\StackExchange.Bicycles.Meta_LOG_20160217_033201.trn' WITH NORECOVERY;

-- Re-join database to availability group
ALTER DATABASE [StackExchange.Bicycles.Meta] SET HADR AVAILABILITY GROUP = [SENetwork_AG];
ALTER DATABASE [StackExchange.Bicycles.Meta] SET HADR RESUME;
