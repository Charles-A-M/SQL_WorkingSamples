--fix Ola Script Steps
exec msdb.dbo.sp_update_jobstep @job_name = 'DatabaseBackup - SYSTEM_DATABASES - FULL' , @step_id = 1, @command =N'EXECUTE [dbo].[DatabaseBackup]  @Databases = ''SYSTEM_DATABASES'',  @Directory = N''\\<SERVER>\DB_Backups\SQL\'',  @BackupType = ''FULL'',  @Verify = ''Y'',  @CleanupTime = 336,  @Compress = ''Y'',  @CheckSum = ''Y'',  @LogToTable = ''N'' ';
exec msdb.dbo.sp_update_jobstep @job_name = 'DatabaseBackup - USER_DATABASES - DIFF' , @step_id = 1, @command =N'EXECUTE [dbo].[DatabaseBackup]  @Databases = ''USER_DATABASES'',  @Directory = N''\\<SERVER>\DB_Backups\SQL\'',  @BackupType = ''DIFF'',  @Verify = ''Y'',  @CleanupTime = 336,  @Compress = ''Y'',  @CheckSum = ''Y'',  @ModificationLevel = 50,  @LogToTable = ''N'' ';
exec msdb.dbo.sp_update_jobstep @job_name = 'DatabaseBackup - USER_DATABASES - FULL' , @step_id = 1, @command =N'EXECUTE [dbo].[DatabaseBackup]  @Databases = ''USER_DATABASES'',  @Directory = N''\\<SERVER>\DB_Backups\SQL\'',  @BackupType = ''FULL'',  @Verify = ''Y'',  @CleanupTime = 336,  @CheckSum = ''Y'',  @Compress = ''Y'',  @LogToTable = ''N'' ';
exec msdb.dbo.sp_update_jobstep @job_name = 'DatabaseBackup - USER_DATABASES - LOG' , @step_id = 1, @command =N'EXECUTE [dbo].[DatabaseBackup]  @Databases = ''USER_DATABASES'',  @Directory = N''\\<SERVER>\DB_Backups\SQL\'',  @BackupType = ''LOG'',  @Verify = ''Y'',  @CleanupTime = 336,  @CheckSum = ''Y'',  @Compress = ''Y'',  @LogSizeSinceLastLogBackup = 128,  @TimeSinceLastLogBackup = 1000,  @LogToTable = ''N'' ';

-- '

--Set operator for all jobs
select name, 'EXEC msdb.dbo.sp_update_job @job_name = N''' + name +
	''', @notify_level_email = 2, @notify_level_page=2, @notify_email_operator_name=N''DBA Team''; ' Oper
from msdb.dbo.sysjobs
order by 1


 