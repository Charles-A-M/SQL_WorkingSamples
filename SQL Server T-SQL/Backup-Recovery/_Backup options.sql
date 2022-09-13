EXEC   xp_instance_regwrite
       N'HKEY_LOCAL_MACHINE',
       N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
       N'BackupDirectory',
       REG_SZ,
       N'\\<SERVER>\db_backups\SQL\';
	   
EXEC sp_configure 'backup compression default', 1 ;  
RECONFIGURE;  
GO 

EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE ;  
GO  
EXEC sp_configure 'media retention', 14;  
GO  
RECONFIGURE;  
GO 
EXEC sp_configure 'backup checksum default', 1;  
GO 
RECONFIGURE;  
GO 
