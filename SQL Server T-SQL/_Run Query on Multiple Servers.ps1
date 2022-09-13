##Import-Module sqlserver

#SQL 2016 SP2 or newer:
$servers1 = @("WTR320SQLDEV", "Wtr320SSRS-PD", "WtrGranitNet-DB", "WtrIpacsDb-Pd", "WtrIpacs-Test", 
	"WtrSpsTest",  "WtrSqlDBpd-1", "WtrSqlDBpd-2", "WtrSqlGisPd-1", "WtrSqlGisPd-2", "WtrSql-Test", "WtrSWsql-PD", "WtrTitanDb-Pd", "WTRWCMPSS")

#older than SQL 2016 SP 2: 
$servers2 = @("wtrcvcommserve\commvault", "WtrSecurity\nexWatch", "WtrSPSQL")

#$query = "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'\\wtrnas\DB_Backups\SQL' "
#$query = "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'\\wtr-sql-backup\DB_Backups\SQL' "
$query1 = @"
DECLARE @TSQL nvarchar(2000) = 'USE [?];
DROP USER IF EXISTS [CODWTR\modern.workplace]; 
DROP USER IF EXISTS [CODWTR\sql.assessment];'
EXEC sp_MSforeachdb @TSQL
USE Master;
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'CODWTR\modern.workplace')
    DROP LOGIN [CODWTR\modern.workplace];
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'CODWTR\sql.assessment')
    DROP LOGIN [CODWTR\sql.assessment];
"@

#$query2 = $query1
$query2 = $query1


Clear-Host
write-host ""
write-host "-------------------------------------------------------------------------------------------------------"
write-host ""
write-host "SQL Server 2016 SP2 or newer:"
write-host $query1	 
write-host "-------------------------------"
foreach ($serv in $servers1) {
	write-host "...$serv"

    Invoke-Sqlcmd -ServerInstance $serv -Database "master" -query $query1
    #Invoke-Sqlcmd -serverInstance $serv -Database "master" -Query "Select  SYSDATETIME(), @@SERVERNAME"
}
write-host ""
write-host "-------------------------------------------------------------------------------------------------------"
write-host ""
write-host "SQL Server 2016 SP2 or older:"
write-host $query2 
write-host "-------------------------------"
foreach ($serv in $servers2) {
	write-host "...$serv"

    Invoke-Sqlcmd -ServerInstance $serv -Database "master" -query $query2
}