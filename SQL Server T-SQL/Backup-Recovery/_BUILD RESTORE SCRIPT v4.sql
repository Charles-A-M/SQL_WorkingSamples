USE [DBMonitoring]
GO

/****** Object:  StoredProcedure [dbo].[BuildRestoreScripts]    Script Date: 3/2/2022 9:01:57 AM ******/
DROP PROCEDURE IF EXISTS [dbo].[BuildRestoreScripts]
GO

/****** Object:  StoredProcedure [dbo].[BuildRestoreScripts]    Script Date: 3/2/2022 9:01:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   Procedure [dbo].[BuildRestoreScripts] (
	@inSource_Directory						nvarchar(2000) = null,		/* Base path for backups. Directory in SQL Server Maintenance Solution scripts or source SQL Server's default backup path */
	@inSource_ServerName					nvarchar(2000) = null,		/* required for non-cluster backups using default SQL Server Maintenance Solution DirectoryStructure or FileName (or using SeverName token)  */
	@inSource_InstanceName					nvarchar(2000) = null,		/* required for non-default instances using default SQL Server Maintenance Solution DirectoryStructure or FileName (or using InstanceName token) */
	@inSource_ClusterName					nvarchar(2000) = null,		/* Required for availability group clusters using default SQL Server Maintenance Solution AvailabilityGroupDirectoryStructure or AvailabilityGroupFileName (or using ClusterName token) */
	@inSource_AvailabilityGroupName			nvarchar(2000) = null,		/* Required for Availability group clusters using default SQL Server Maintenance Solution AvailabilityGroupDirectoryStructure or AvailabilityGroupFileName (or using AvailabilityGroupName token) */
	@inSource_DatabaseName as sysname = null,							/* required. DB to restore. */
	/* Required if using a non-default parameter on the Source instance */
	@inSource_DirectoryStructure			nvarchar(2000) = null,	
	/* required if using a non-default parameter on the Source instance */
	@inSource_AvailabilityGroupDirectoryStructure nvarchar(2000) =null,	
	@inDestination_DatabaseName as sysname = null,						/* if you want to change the DB on restore, this is the new DB name, set inRenameFiles to set filenames based on @inDestination_DatabaseName */
	@inDestination_DataFilePath as nvarchar(2000) = null,				/* If supplied, moves data files to a new path, set inRenameFiles to set filenames based on @inDestination_DatabaseName */
	@inDestination_LogFilePath as nvarchar(2000) = null,				/* If supplied, moves log files to a new path, set inRenameFiles to set filenames based on @inDestination_DatabaseName */
	@inStopAtTime as datetime2(1) = '9999-12-31',						/* date of last commited change to restore. Adds STOPAT = parameter to restores commands. */
	@inStartAtTime as datetime2(1) = '1900-01-01',						/* date we expect our backups to be newer than; don't restore anything older than this. */
	@inGetFull as bit = 1,												/* Restore full backups if found? */
	@inGetDiff as bit = 1,												/* Restore Diff backups if found that are newer than the latest full? */
	@inGetLogs as bit = 1,												/* Restore Log backups if found that are newer than the latest full/Diff? */
	@inRenameFiles as bit = 0,											/* If supplied, renames data and log files to match inDestination_DatabaseName_##.ext where ## is file number in order and ext is mdf, ndf, or ldf */
	@inDoRecover as bit = 0,											/* if 1, RESTORE DATABASE [...] WITH RECOVERY;   Otherwise, that line is commented out */
	@inDoChangeOwner as bit = 0,										/* if 1, ALTER AUTHORIZATION ON DATABASE::[' + @DestDBName + '] TO [sa] ';   Otherwise, that line is commented out */
	@inVerboseMode as bit = 0											/* Show more details as the script runs */
	)
as begin
	set nocount on;
    set rowcount 0;
	/*
		===============================================================================================================================
		===============================================================================================================================
			BuildRestoreScripts
		-------------------------------------------------------------------------------------------------------------------------------
		This script will scroll through backup files in a given path, then build a full, differential, and log restore statements
	 
		It is slower than the original script, since it gathers meta-data.
		But it only creates the statements necessary for the most recent Full, most recent Diff, and any logs AFTER the most recent Diff.
			So there's no need to find the necessary logs or deal with errors from unneeded log files.
		It also creates the needed MOVE statements in the Full restore statement (though it isn't smart enough to set them to the destination server values).
		Finally, it is smart enough to do the new database name.
		
		Requirements and Assumptions:
			For now at least, this only works on backups stored on file directories or file shares, no URLs, and using SQL's native backup software, no 3rd party backup software here.
			We assume source, destination, and this machine, are all running the same version or at the very least, the same host platform (win vs linux)
			Must have one and only one of the following combinations of values (in other words if we see serverName and ClusterName, we don't know which to use):
				@inSource_DatabaseName, @inSource_ServerName,
				@inSource_DatabaseName, @inSource_ServerName, @inSource_InstanceName
				@inSource_DatabaseName, @inSource_ClusterName, @inSource_AvailabilityGroupName
			Must enable xp_cmdshell

		TODO: Because this relies on xp_cmdshell and the DIR command, this WILL NOT WORK from Azure or Linux; must run this utility from Windows against a backup destination Windows can browse.
				Not sure how to fix that?

		TODO: Does not support URL backup destinations. 
				Not sure how to fix that.

		TODO: handle file types other than data and log for path resets and filenames?

		TODO: This assumes it is run from the same OS as the backup destination as far as directory separators, etc. go. 
				Not sure how to fix that or if it can/should be fixed? 
	
		2018-06-08, 1		Charles Moore	1st conversion of https://www.mssqltips.com/sqlservertip/1584/auto-generate-sql-server-restore-script-from-backup-files-in-a-directory/
		2019-02-12, 1.1		CM				Set it to allow running just the Full, just the Diff, or just the Log restore commands.
		2020-01-17, 1.2		CM				Added debugMode to reduce deault output and provide more details for fixing issues. Changed inputs for better error checking.
		2020-01-21, 1.3		CM				Added file path test to make sure the base path is there.
		2020-01-22, 1.4		CM				Added check to make sure we had files to restore. No files means exit w/ warning.
		2020-07-28, 1.4.1	CM				fixed counter bug on log restores (file 10000 of 231 just is wrong. WRONG!)
		2020-08-28, 1.4.2	CM				expanded varchar sizes because SharePoint likes GUIDs in database names so much. Thanks Microsoft!
		2020-09-08, 1.4.3	CM				added optional code to change DB owner from user to SA.
		2020-12-31, 1.5		CM				changed default backup path and updated the help text
		2021-11-22, 2.0		CM				rewrite to expand parameters and more closely align with SQL Server Maintenance Solution's options,
											multi-file backup sets, etc.
		2022-03-02          CM              Fixed for really long restore statements at the FULL and DIFF block, where it was cutting off.

		References used to make this:
		-- https://ola.hallengren.com/sql-server-backup.html
		-- https://www.mssqltips.com/sqlservertip/1584/auto-generate-sql-server-restore-script-from-backup-files-in-a-directory/
		-- https://dba.stackexchange.com/questions/218461/how-to-get-the-date-of-a-file-using-xp-cmdshell
		-- https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-headeronly-transact-sql?view=sql-server-ver15
		-- https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-labelonly-transact-sql?view=sql-server-ver15
		-- https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-filelistonly-transact-sql?view=sql-server-ver15
 
		===============================================================================================================================
		===============================================================================================================================
			Declare variables
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	Declare @MyVersion varchar(50) = '2.3 - 2022-03-03';

	declare @actionFlag int;							/* -1,2,5 = excluded backup type, -10 = backup dates outside acceptable range, -100 = wrong database, -1000 = file error  */
	declare @BackupFinishDate datetime;					/* when a backup completed */
	declare @BackupStartDate datetime;					/* this file is part of a backup that began at this datetime */
	declare @BackupType smallint;						/* 1=DB, 2=Log, 4=File, 5=Diff Db, 6=diff file, 7=partial, 8=Diff partial */ 
	declare @checkDate datetime2(1);					/* used to compare date values */
	declare @CheckpointLSN numeric(25,0);				/* Log sequence number of the most recent checkpoint at the time the backup was created */
	declare @DatabaseBackupLSN numeric(25,0);			/* Log sequence number for this backup */
	declare @DatabaseName nvarchar(500);				/* What database name is recorded in this backup file? */				
	declare @DataFileNum tinyint = 1;					/* First data file renames to mdf. later data files rename to ndf extension. */
	Declare @DefaultDirectory nvarchar(2000);			/* where do the backups go on the source server? */
	declare @DiffBackupFiles int = 0;					/* How many valid Diff backup files did we find in the end? */
	declare @diffBackupStartTime datetime2(1) = '0001-01-01';	/* track when the backup began, to rule out older files */
	declare @diffBackupStopTime datetime2(1) = '0001-01-01';	/* track when the backup ended, to rule out older files */
	Declare @DirectorySeparator varchar(1);				/* / or \  */
	declare @FamilyCount int							/* Number of media families in the media set */
	declare @FamilySequenceNumber int					/* Sequence number of this family. */
	declare @fileDate datetime2;						/* when the file was created */
	declare @fileName nvarchar(512);					/* backup file name without path */
	declare @filesCount int = 0;						/* how many files are in the backup file list? */
	declare @fileSize int;								/* size of backup file in bytes */
	declare @fileType char(1);							/* L = SQL log file, D = SQL data file, F = Full Text Catalog, S = FileStream, FileTable, or In-Memory OLTP container */
	declare @FirstLSN numeric(25,0);					/* Log sequence number of the first log record in the backup set */
	declare @FullBackupFiles int = 0;					/* How many valid Full backup files did we find in the end? */
	declare @fullBackupStartTime datetime2(1) = '0001-01-01';	/* track when the backup began, to rule out older files */
	declare @fullBackupStopTime datetime2(1) = '0001-01-01';	/* track when the backup ended, to rule out older files */
	Declare @HostPlatform varchar(20);					/* Windows or Linux? */
	declare @id int;									/* holds ID int values from various selects */
	declare @isDamaged bit;								/* did SQL Server flag the DB as damaged? */
	Declare @isDir bit;									/* flag for whether a row from DIR is a directory or a file */
	declare @lastBackupStartDate datetime;				/* previous file's backup start date */
	declare @LastLSN  numeric(25,0);					/* Log sequence number of the next log record after the backup set */
	declare @logBackupFiles int = 0;					/* How many valid Log backup files did we find in the end? */
	declare @LogFileNum tinyint = 1;					/* count up from 1 */
	declare @logicalName nvarchar(2000);				/* file list logical name */
	declare @pathExists bit = 0;						/* if this is anything but 1, we can't get to the backup destination from here */
	declare @physicalName nvarchar(2000);				/* file list physical name */
	declare @ReplaceWith nvarchar(2000);				/* replace above token with this value */
	declare @RunTimeMilliseconds int;					/* how long did this script take to run? */
	declare @ScriptLine nvarchar(max);					/* build output scripts in this line */
	declare @StartRunTime datetime2 = sysdatetime();	/* when did this script begin running? */
	declare @StopAtText nvarchar(100) = N' ';			/* if user supplied a stop-at time, capture the STOPAT= restore clause here */
	declare @stopRunTime datetime2;						/* when did this script stop running? */
	declare @strData nvarchar(max);						/* string data from the DIR command */
	declare @strFileDate nvarchar(50);					/* file date text before converting to datetime */
	declare @strFileSize nvarchar(100);					/* file size as a string before converting to int */
	declare @strPath nvarchar(4000);					/* string path for backups */
	Declare @subPath nvarchar(2000);					/* where we add in the serverName or ClusterName, etc. from directory structure parameters. */
	declare @token nvarchar(100);						/* a token in a directory structure to be replaced */
	Declare @txtCmd nvarchar(2000);						/* holds cmdShell text to execute */
	Declare @Version numeric(18,10) = 0;				/* What SQL Server version is this running from? */
	DECLARE @printCounter INT;							/* split up print statements for LONG runs */
	DECLARE @TotalPrints INT;							/* number of print chunks */
	/*  default parameter on the Source instance */
	declare @Source_DirectoryStructure nvarchar(2000) = N'{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}';	
	/*  default parameter on the Source instance */
	declare @Source_AvailabilityGroupDirectoryStructure nvarchar(2000) = N'{ClusterName}${AvailabilityGroupName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}';	
	/*
		===============================================================================================================================
		===============================================================================================================================
			Declare table variables
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	declare @OutputTable table (						/* output everything as row data as well as text data */
		id int identity(1,1), 
		insertTime datetime2 not null default sysdatetime(), 
		sortOrder int not null, 
		rowText nvarchar(max) not null );

	declare @Tokens table (								/* Valid tokens for backup directory strings */
		id int identity(1,1),
		token varchar(100),
		replaceWith varchar(2000) not null default ''
	);

	Declare @Files table (								/* this will hold details on all the files we find */
		/* from xp_cmdshell ( DIR ) */
		id int identity(1,1) primary key,
		strData nVarChar(2000),
		isDir bit default 0,
		FilePath nvarchar(2000),
		[fileName] nvarchar(512),
		fileDate datetime2(1),
		fileSize numeric(20,0),
		OrderBy int,									/* backupType shows Full, Log, Diff in order. Let's make that show up as Full, Diff, Log */
		/* from Restore HeaderOnly */
		BackupStartDate datetime,
	    BackupFinishDate datetime,	
	    BackupType smallint null,						/* -99 = Error during Read! 1=DB, 2=Log, 4=File, 5=Diff Db, 6=diff file, 7=partial, 8=Diff partial */ 
	    FirstLSN numeric(25,0),							/* Log sequence number of the first log record in the backup set */
	    LastLSN  numeric(25,0),							/* Log sequence number of the next log record after the backup set */
	    CheckpointLSN numeric(25,0),					/* Log sequence number of the most recent checkpoint at the time the backup was created */
	    DatabaseBackupLSN numeric(25,0),				/* LSN of most recent full backup. "Begin of checkpoint" triggered at backup start. = FirstLSN if taken when db is idle and no replication */
		/* from restore LabelOnly */
		FamilyCount int,								/* Number of media families in the media set */
		FamilySequenceNumber int						/* Sequence number of this family. */
	);
	Declare @Label_Only table(							/*   contents from restore labelonly */
		[MediaName] nvarchar(150),						/* Name of the media */
		MediaSetId uniqueidentifier,					/* Unique identification number of the media set */
		FamilyCount int,								/* Number of media families in the media set */
		FamilySequenceNumber int,						/* Sequence number of this family. */
		MediaFamilyId uniqueidentifier,					/* Unique identification number for the media family */
		MediaSequenceNumber	int,						/* Sequence number of this media in the media family */
		MediaLabelPresent tinyint,						/* Whether the media description contains: 1 = Microsoft Tape Format media label, 0 = Media description */
		[MediaDescription] nvarchar(275),				/* Media description, in free-form text, or the Tape Format media label */
		SoftwareName nvarchar(128),						/* Name of the backup software that wrote the label */
		SoftwareVendorId int,							/* Unique vendor identification number of the software vendor that wrote the backup */
		MediaDate datetime,								/* Date and time the label was written */
		Mirror_Count int,								/* Number of mirrors in the set (1-4). Note: The labels written for different mirrors in a set are identical */
		IsCompressed bit								/* Whether the backup is compressed: 0 = not compressed 1 =compressed */
	);
	Declare @Header_Only table (						/*   contents from restore headeronly  */
	    BackupName nvarchar(150) null,					/* Backup set name */
	    BackupDescription nvarchar(2000) null,
	    BackupType smallint   null,						/* 1=DB, 2=Log, 4=File, 5=Diff Db, 6=diff file, 7=partial, 8=Diff partial */ 
	    ExpirationDate datetime null,
	    Compressed bit null,							/* 1=yes, 2=no */
	    Position smallint null,							/* Position of the backup set in the volume (for use with the FILE = option) */
	    DeviceType tinyInt null,						/* Disk: 2=logical, 102=physical. Tape: 5=logical, 105=physical. Virtual Device 7= L, 107 = P. URL 9=L, 109=P */
	    UserName nvarchar(500)   null,					/* who did the backup */
	    ServerName nvarchar(500)   null,
	    DatabaseName nvarchar(500)   null,
	    DatabaseVersion int,
	    DatabaseCreationDate datetime,
	    BackupSize numeric(20,0),						/* size in bytes */
	    FirstLSN numeric(25,0),							/* Log sequence number of the first log record in the backup set */
	    LastLSN  numeric(25,0),							/* Log sequence number of the next log record after the backup set */
	    CheckpointLSN numeric(25,0),					/* Log sequence number of the most recent checkpoint at the time the backup was created */
	    DatabaseBackupLSN numeric(25,0),				/* LSN of most recent full backup. "Begin of checkpoint" triggered at backup start. = FirstLSN if taken when db is idle and no replication */
	    BackupStartDate datetime,
	    BackupFinishDate datetime,
	    SortOrder smallInt,								/* Server sort order. provided for backward compatibility */
	    [CodePage] smallint,
	    UnicodeLocaleID int,
	    UnicodeComparisonStyle int,
	    CompatibilityLevel tinyint,
	    SoftwareVendorId int,							/* Software vendor identification number. For SQL Server, this number is 4608 (or hexadecimal 0x1200) */
	    SoftwareVersionMajor int,
	    SoftwareVersionMinor int,
	    SoftwareVersionBuild int,
	    MachineName nvarchar(128),						/* Name of the computer that performed the backup operation */
	    Flags int,										/* instead of Flags you use the individual Boolean columns */
	    BindingID uniqueidentifier,						/* Binding ID for the database. This = sys.database_recovery_status database_guid. When DB is restored, a new value is assigned. */
	    RecoveryForkID uniqueidentifier,				/* ID for ending recovery fork. This = last_recovery_fork_guid in the backupset table. for data backups = FirstRecoveryForkID. */
	    Collation nvarchar(500),
	    FamilyGUID uniqueidentifier,					/* ID of the original database when created. This value stays the same when the database is restored. */
	    HasBulkLoggedData bit,							/* 1= Log backup containing bulk-logged operations */
	    IsSnapshot bit,									/* 1= snapshot backup */
	    IsReadOnly bit,
	    IsSingleUser bit,
	    HasBackupChecksums bit,
	    IsDamaged bit,									/* 1 = Database was damaged when backed up, but the backup was requested to continue despite errors */
	    BeginsLogChain bit,								/* 1 = This is the first in a continuous chain of log backups. 
															   A log chain begins with the first log backup taken after the database is created or 
															   when it is switched from the Simple to the Full or Bulk-Logged Recovery Model. */
	    HasIncompleteMetaData bit,						/* 1 = A tail-log backup with incomplete meta-data */
	    IsForceOffline bit,								/* 1 = Backup taken with NORECOVERY; the database was taken offline by backup */
	    IsCopyOnly bit,
	    FirstReoveryForkID uniqueidentifier,			/* ID for starting recovery fork. This = first_recovery_fork_guid in the backupset table. For data backups, = RecoveryForkID */
	    ForkPointLSN numeric(25,0),						/* If FirstRecoveryForkID is not equal to RecoveryForkID, this is the log sequence number of the fork point. Otherwise, this value is NULL */
	    RecoveryModel nvarchar(60),
	    DifferentialBaseLSN numeric(25,0),				/* Null for non-diff backups. For a single-based differential backup, the value equals the FirstLSN of the differential base; 
														   changes with LSNs greater than or equal to DifferentialBaseLSN are included in the differential */
	    DifferentialBaseGUID uniqueidentifier,			/* For a single-based differential backup, the value is the unique identifier of the differential base. */
	    BackupTypeDescription nvarchar(500),			/* DATABASE, TRANSACTION LOG, FILE OR FILEGROUP, DATABASE DIFFERENTIAL, FILE DIFFERENTIAL PARTIAL, PARTIAL DIFFERENTIAL */
	    BackupSetGUID uniqueidentifier,					/* Unique identification number of the backup set, by which it is identified on the media */
	    CompressedBackupSize bigint,					/* Byte count of the backup set. For uncompressed backups, this value is the same as BackupSize.
														   To calculate the compression ratio, use CompressedBackupSize and BackupSize */
	    Containment tinyint,							/* SQL 2012 (11.x)+. 0=containment is off. 1=db in partial containment */
	    KeyAlgorithm nvarchar(32),						/* SQL 2014 (12.x) (CU1)+. Encryption algorithm used for backup */ 
	    EncryptorThumbprint varbinary(20),				/* SQL 2014 (12.x) (CU1)+. The thumbprint of the encryptor which can be used to find certificate or the asymmetric key in the database */
	    EncryptorType nvarchar(32)						/* SQL 2014 (12.x) (CU1)+. The type of encryptor used: Certificate or Asymmetric Key */
	);

	Declare @FileList_Only table (						/*   contents from restore FileListOnly */
		LogicalName nvarchar(128),						/* Logical name of the file. */
		PhysicalName nvarchar(260),						/* Physical or OS name of the file. */
		[Type] char(1),									/* L = SQL log file, D = SQL data file, F = Full Text Catalog, S = FileStream, FileTable, or In-Memory OLTP container */
		FileGroupName nvarchar(128),					/* Name of the filegroup that contains the file. */
		Size numeric(20,0),								/* Current size in bytes. */
		MaxSize numeric(20,0),							/* Maximum allowed size in bytes. */
		FileID bigint,									/* File identifier, unique within the database. */
		CreateLSN numeric(25,0),						/* Log sequence number at which the file was created. */
		DropLSN numeric(25,0),							/* The log sequence number at which the file was dropped. If the file has not been dropped, this value is NULL. */
		UniqueID uniqueidentifier,						/* Globally unique identifier of the file. */
		ReadOnlyLSN numeric(25,0),						/* Log sequence number at which the filegroup containing the file changed from read-write to read-only (the most recent change). */
		ReadWriteLSN numeric(25,0),						/* Log sequence number at which the filegroup containing the file changed from read-only to read-write (the most recent change). */
		BackupSizeInBytes bigint,						/* Size of the backup for this file in bytes. */
		SourceBlockSize int,							/* Block size of the physical device containing the file in bytes (not the backup device). */
		FileGroupID int,								/* ID of the filegroup. */
		LogGroupGUID uniqueidentifier,					/* NULL. */
		DifferentialBaseLSN numeric(25,0),				/* For Diff backups, changes with LSN >= DifferentialBaseLSN are included in the diff. For other backup types, NULL. */
		DifferentialBaseGUID uniqueidentifier,			/* For Diff backups, the unique identifier of the diff base. For other backup types, the value is NULL. */
		IsReadOnly bit,									/* 1 = The file is read-only. */
		IsPresent bit,									/* 1 = The file is present in the backup. */
		TDEThumbprint varbinary(32),					/* Shows the thumbprint of the Database Encryption Key. The encryptor thumbprint is a SHA-1 hash of the certificate with which the key is encrypted. For information about database encryption, see Transparent Data Encryption (TDE). */
		SnapshotURL nvarchar(360),						/* SQL 2016 (13.x) (CU1)+. URL for Azure snapshot of the db file contained in the FILE_SNAPSHOT backup. NULL if no FILE_SNAPSHOT backup */
		FilesID int,									/* FK to @files above, to get path and filename */
	    ID int identity(1,1) not null primary key
	);
	/*
		===============================================================================================================================
		===============================================================================================================================
			declare cursors
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	declare FixFiles cursor for							/* Set the filePath values for files */
	 select id, strData
       from @files
      order by id;

	declare fixTokens cursor for						/* fix the directory tokens with these replacements */
	 select token, replacewith
	   from @Tokens
	  order by id;
	declare @isXpCmdShell bit;							/* is xp_cmdshell enabled? */

	declare allFiles cursor for							/* cycle through all of the files in the @files stack to gather header_only data */
	 select id, FilePath, [FileName]
 	   from @Files
	  where isDir = 0;

	declare allFilesSecondPass cursor for				/* cycle through all of the files in the @files stack to get rest of the metadata */
	 select id, FilePath, [FileName], BackupType
	   from @Files
	  where isDir = 0
	    and BackupType > 0;

	declare GetFullFiles cursor for						/* cycle through the full-backup files to generate restore scripts for all disk= lines */
	 select id, filePath, [FileName], FamilyCount, FamilySequenceNumber
	   from @files
	  where BackupType = 1
	  order by FamilySequenceNumber asc;

	declare GetDiffFiles cursor for						/* cycle through the diff-backup files to generate restore scripts for all disk= lines */
	 select id, filePath, [FileName], FamilyCount, FamilySequenceNumber
	   from @files
	  where BackupType = 5
	  order by FamilySequenceNumber asc;

	declare GetLogFiles cursor for						/* cycle through the log-backup files to generate restore scripts for all disk= lines */
	 select id, filePath, [FileName], FamilyCount, FamilySequenceNumber, BackupStartDate
	   from @files
	  where BackupType = 2
	  order by BackupStartDate, FamilySequenceNumber asc;

	declare getFilesList cursor for
	 select LogicalName, PhysicalName, [Type], FileID
	  from @FileList_Only
	 order by [Type], FileID;
	/*
		===============================================================================================================================
		===============================================================================================================================
			Banner text block
		-------------------------------------------------------------------------------------------------------------------------------
	*/
		set @ScriptLine = 
					  N'/* =============================================================================================================================== ' + char(13) +
					   '   --     BuildRestoreScripts version ' + @MyVersion + '  --  Executed on ' + cast(sysdatetime() as varchar) + char(13) + 
					   '   -------------------------------------------------------------------------------------------------------------------------------' + char(13) +
					   '   Parameters: ' + char(13) +
					   '   --  @inSource_Directory    : Base path in SQL Server Maintenance Solution backup scripts or source SQL Server''s default backup path.' + char(13) +
					   '   --  @inSource_ServerName   : REQUIRED or NULL. Name of the host that generated the backup. Null for failover cluster.' + char(13) +
					   '   --  @inSource_InstanceName : Name of the instance that generated the backup. Null for default MSSQLSERVER or for failover cluster.' + char(13) +
					   '   --  @inSource_ClusterName  : REQUIRED or NULL. Name of the Windows failover cluster name. {ClusterName} token in SQL Server Maintenance Solution backup scripts.' + char(13) +
					   '   --  @inSource_AvailabilityGroupName : REQUIRED or NULL. AlwaysOn Availability group name. {AvailabilityGroupName} token in SQL Server Maintenance Solution. ' + char(13) +
					   '   --  @inSource_DatabaseName : REQUIRED. Name of the database to restore from.' + char(13) +
					   '   --  @inSource_DirectoryStructure : The Directory Structure tokens used in SQL Server Maintenance Solution. REQUIRED if using non-default values.' + char(13) +
					   '   --  @inSource_AvailabilityGroupDirectoryStructure :: The AG Directory Structure tokens used in SQL Server Maintenance Solution. REQUIRED if using non-default values.' + char(13) +
					   '   --  @inDestination_DatabaseName : If you wish to use a different name for the restored database, supply it here. NULL to keep the original name.' + char(13) +
					   '   --  @inDestination_DataFilePath : If you wish to move data files to a new directory during the restore, supply the new path here. (Script does not validate this path.)' + char(13) +
					   '   --  @inDestination_LogFilePath : If you wish to move log files to a new directory during the restore, supply the new path here. (Script does not validate this path.)' + char(13) +
					   '   --  @inStopAtTime          : Supply a date and time value if you wish to use a STOPAT clause to restore the database up to a point in time.' + char(13) +
					   '   --  @inStartAtTime         : If you wish to exclude backups created before a specific date and time, supply that start point via this Parameter.' + char(13) +
					   '   --  @inGetFull			 : 0 to skip any Full backup files while generating restore scripts.' + char(13) +
					   '   --  @inGetDiff             : 0 to skip any Diff backup files while generating restore scripts.' + char(13) +
					   '   --  @inGetLogs             : 0 to skip any transaction log files while generating restore scripts.' + char(13) +
					   '   --  @inRenameFiles         : 1 to rename physical files to DatabaseName_01.mdf, DatabaseName_##.ndf, and DatabaseName_log_##.ldf file names during restore.' + char(13) +
					   '                                This does NOT check to make sure the DatabaseName is valid for filenames and contains no disallowed characters.'+ char(13) +
					   '   --  @inDoRecover           : 1 to Supply RESTORE DATABASE [...] WITH RECOVERY; at the end. Otherwise, this line is commented out.'+ char(13) +
					   '   --  @inDoChangeOwner       : 1 to change the owner from you to SA. This requires @inDoRecover = 1. Otherwise, line is commented out.'+ char(13) +
					   '   --  @inVerboseMode         : 1 to display additional information from the procedure. Helpful to resolve errors.'+ char(13) + 
					   '   ------------------------------------------------------------------------------------------------------------------------------- */'
	insert into @OutputTable (sortOrder, rowText) values (1, @ScriptLine);
	print @ScriptLine;
	set @ScriptLine = '';
 	/*
		===============================================================================================================================
		===============================================================================================================================
			Validate our inputs before we see what's out there
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	set @Version = 
		CAST(
			LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) 
			+ '.' + REPLACE(RIGHT(
				CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), 
				LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 
				CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))))
			,'.','') AS numeric(18,10));
	insert into @tokens (token) values ('_{BackupType}');
	insert into @tokens (token) values ('_{Partial}');
	insert into @tokens (token) values ('_{CopyOnly}');
	insert into @tokens (token) values ('_{Description}');
	insert into @tokens (token) values ('_{MajorVersion}');
	insert into @tokens (token) values ('_{MinorVersion}');
	insert into @tokens (token) values ('{BackupType}');
	insert into @tokens (token) values ('{Partial}');
	insert into @tokens (token) values ('{CopyOnly}');
	insert into @tokens (token) values ('{Description}');
	insert into @tokens (token) values ('{MajorVersion}');
	insert into @tokens (token) values ('{MinorVersion}');

	SELECT @isXpCmdShell = TRY_CONVERT(bit, ISNULL(value, value_in_use))  
      FROM sys.configurations 
     WHERE name = 'xp_cmdshell';
	if @isXpCmdShell <> 1 
	begin
		print ' /* ERROR!  Cannot run this until you enable XP_CmdShell. Uncomment and then Run this: ';
		print '    EXECUTE sp_configure ''show advanced options'', 1;';  
		print '    GO  ';
		print '    RECONFIGURE;  ';
		print '    GO  ';
		print '    EXECUTE sp_configure ''xp_cmdshell'', 1;  ';
		print '    GO  ';
		print '    RECONFIGURE;  ';
		print '    GO';
		print ' */'
		return			/* and we're done here folks! No way to move forward from that. */
	end
	if @inVerboseMode = 1 
	begin		
		insert into @OutputTable (sortOrder, rowText) values (1, ' -- Setting internal values and confirming we have a valid source path.');
		print ' -- Setting internal values and confirming we have a valid source path.';
	end;
	if @inStopAtTime is null 
		set @inStopAtTime = dateadd(minute,5,sysdatetime());
	if @inStartAtTime is null
		set @inStartAtTime = '2000-01-01';

	if @inStartAtTime > @inStopAtTime
	begin
		print '   /* ERROR!  @inStartAtTime (' + cast(@inStartAtTime as varchar) + ') must be before  @inStopAtTime (' + cast( @inStopAtTime as varchar) + ')!  */';
		return			/* and we're done here folks! No way to move forward from that. */
	end

	IF @inSource_Directory IS NULL
	begin
		IF @Version >= 15	
			SET @inSource_Directory = CAST(SERVERPROPERTY('InstanceDefaultBackupPath') AS nvarchar(max))	
	    ELSE
	      EXECUTE [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', @inSource_Directory OUTPUT;
	end
	set @DefaultDirectory = @inSource_Directory;

	IF @Version >= 14
	    SELECT @HostPlatform = host_platform
		  FROM sys.dm_os_host_info;
	ELSE
	    SET @HostPlatform = 'Windows';

	SELECT @DirectorySeparator = CASE
	  WHEN @HostPlatform = 'Windows' THEN '\'
	  WHEN @HostPlatform = 'Linux' THEN '/'
	END;
	
	if right(@DefaultDirectory, 1) = @DirectorySeparator
		Set @DefaultDirectory = LEFT(@DefaultDirectory, LEN(@DefaultDirectory) - 1);
	/*
		Do we have a valid path to the DB's backups?
	 */

	if @inSource_InstanceName = N'MSSQLSERVER'
		set @inSource_InstanceName = null;
	
	set @inSource_DatabaseName = ltrim(rtrim(isnull(@inSource_DatabaseName,'')));
	set @inDestination_DatabaseName = ltrim(rtrim(isnull(@inDestination_DatabaseName, '')));

	if @inSource_DatabaseName = ''
	begin
		print '   /* ERROR! @inSource_DatabaseName must be set to a valid name of a database!  */';
		return /* and we're done here folks! No way to move forward from that. */
	end;

	if left(@inSource_DatabaseName, 1) = '['
		set @inSource_DatabaseName = right(@inSource_DatabaseName, len(@inSource_DatabaseName) -1);

	if right(@inSource_DatabaseName, 1) = ']'
		set @inSource_DatabaseName = left(@inSource_DatabaseName, len(@inSource_DatabaseName) -1);

	if @inDestination_DatabaseName = ''
		set @inDestination_DatabaseName = @inSource_DatabaseName;

	if left(@inDestination_DatabaseName, 1) = '['
		set @inDestination_DatabaseName = right(@inDestination_DatabaseName, len(@inDestination_DatabaseName) -1);

	if right(@inDestination_DatabaseName, 1) = ']'
		set @inDestination_DatabaseName = left(@inDestination_DatabaseName, len(@inDestination_DatabaseName) -1);
	
	if @inDestination_DataFilePath is not null
		set @inDestination_DataFilePath = ltrim(rtrim(@inDestination_DataFilePath));

	if @inDestination_DataFilePath = ''
		set @inDestination_DataFilePath = null;

	if @inDestination_DataFilePath is not null and right(@inDestination_DataFilePath,1) <> @DirectorySeparator
		set @inDestination_DataFilePath = @inDestination_DataFilePath + @DirectorySeparator;

	if @inDestination_LogFilePath is not null
		set @inDestination_LogFilePath = ltrim(rtrim(@inDestination_LogFilePath));

	if @inDestination_LogFilePath = ''
		set @inDestination_LogFilePath = null;

	if @inDestination_LogFilePath is not null and right(@inDestination_LogFilePath,1) <> @DirectorySeparator
		set @inDestination_LogFilePath = @inDestination_LogFilePath + @DirectorySeparator;

	if @inStopAtTime <= sysdatetime()
		set @StopAtText =  N' , STOPAT = ''' + format(@inStopAtTime, 'yyyy-MM-dd HH:mm:ss') + ''' ' ;

	if @inSource_ServerName is null
	begin
		if @inSource_ClusterName is null or @inSource_AvailabilityGroupName is null
		begin
			print '   /* ERROR! either you must supply @inSource_ServerName (and optionally @inSource_InstanceName) ...';
			print '         ... OR you must supply both @inSource_ClusterName and @inSource_AvailabilityGroupName. */';
			return /* and we're done here folks! No way to move forward from that. */
		end
		else
			if @inSource_AvailabilityGroupDirectoryStructure is null or len(@inSource_AvailabilityGroupDirectoryStructure) < 5
				set @subPath = @Source_AvailabilityGroupDirectoryStructure;
			else
				set @subPath = @inSource_AvailabilityGroupDirectoryStructure;
	end
	else
		if @inSource_DirectoryStructure is null or len(@inSource_DirectoryStructure) < 5
			set @subPath = @Source_DirectoryStructure;
		else
			set @subPath = @inSource_DirectoryStructure;

	if @inSource_InstanceName is null
		insert into @tokens (token, replaceWith) values ('${InstanceName}', '');
	else
		insert into @tokens (token, replaceWith) values ('{InstanceName}', isnull(@inSource_InstanceName, ''));

	insert into @tokens (token, replaceWith) values ('{DatabaseName}', @inSource_DatabaseName);
	insert into @tokens (token, replaceWith) values ('{DirectorySeparator}', @DirectorySeparator);
	insert into @tokens (token, replaceWith) values ('{ClusterName}', isnull(@inSource_ClusterName, ''));	
	insert into @tokens (token, replaceWith) values ('{ServerName}', isnull(@inSource_ServerName, ''));
	insert into @tokens (token, replaceWith) values ('{AvailabilityGroupName}', isnull(@inSource_AvailabilityGroupName, ''));

	open FixTokens;
	FETCH NEXT FROM FixTokens INTO  @token, @replaceWith;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @subPath = replace(@subPath, @token, @replaceWith);
		FETCH NEXT FROM FixTokens INTO  @token, @replaceWith;
	end;
	close FixTokens;
	Deallocate FixTokens;
	/*  confirm we can get to this directory  */
	set @DefaultDirectory = @DefaultDirectory + @DirectorySeparator + @subPath
	if @Version > 13
		select @pathExists = file_is_a_directory from sys.dm_os_file_exists ( @DefaultDirectory )
	else
	begin
		declare @pathExistsTbl table (fileExists bit, FileIsDirectory bit, ParentDirectoryExists bit)
		insert into @pathExistsTbl
			exec xp_fileExist @DefaultDirectory ;
		select @pathExists = FileIsDirectory from @pathExistsTbl;
	end
	if @pathExists is null or @pathExists <> 1
	begin
		print '   /* ERROR! The path generated from your parameters does not exist or cannot be reached by this server!';
		print '      Invalid path: ' + @DefaultDirectory;
		print '   */';
		return	/*   and we're done here folks! No way to move forward from that. */
	end
	else
		if @inVerboseMode = 1
		begin
			insert into @OutputTable (sortOrder, rowText) values (1, ' -- This path exists and can be reached: ');
			insert into @OutputTable (sortOrder, rowText) values (1, ' -- ' + @DefaultDirectory );
			print ' -- Finding all files in: ';
			print ' -- ' + @DefaultDirectory ;
		end;

	/*
		===============================================================================================================================
		===============================================================================================================================
			@DefaultDirectory is valid. Time to look for files
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	set @txtCmd = 'dir ' + @DefaultDirectory + ' /S /-C'
	INSERT INTO @files (strData) EXEC xp_cmdshell @txtCmd	/* TODO: is there a built-in or better way to do this? How about URL destinations? */
	Delete From @files 
	 where strData is null
	    or strData like '% Volume %'
	    or strData like '% bytes%'
	    or strData like '%<DIR>%'
		or strData like '%Files Listed%'
		or strData like '%Files Listed%'
		or len(ltrim(rtrim(strData))) < 10;
	if @inVerboseMode = 1
	begin
		select @id = count(*) from @files;
		print ' -- Found ' + cast(@id as varchar) + ' potential backup files in that path.';
		insert into @OutputTable (sortOrder, rowText) values (1, ' -- Found ' + cast(@id as varchar) + ' potential backup files in that path.');
	end;

	open FixFiles;
	FETCH NEXT FROM FixFiles INTO  @id, @strData;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if CharIndex('Directory of', @strData) > 0
		begin
			update @files set isDir = 1 where id = @id;
			set @strPath = ltrim( rtrim( Replace( @strData, 'Directory of','')));
		end
		else 
		begin
			set @fileName = Reverse(@strData);
			set @fileName = ltrim(rtrim(reverse(substring(@fileName, 1, charindex(' ', @fileName)))));
			set @fileDate = try_convert(datetime2,left(@strData, 23));
			set @strFileSize = ltrim(rtrim( substring(replace(@strData, @fileName, ''), 23, 100)));
			set @fileSize = TRY_CONVERT(int, @strFileSize);

			update @files set FilePath = @strPath, [fileName] = @fileName, fileDate = @fileDate, fileSize = @fileSize where id = @id;
		end;
		FETCH NEXT FROM FixFiles INTO  @id, @strData;
	end;
	close FixFiles;
	deallocate FixFiles;
	/*
		basic cleanup of our files list
		smallest log file I've seen is 6,144 bytes
	*/
	delete from @files where isDir = 1;
	update @files set backupType = -5555 where fileSize < 256;
	/*
		we have collected a set of backup files. If there are none, that's a problem.
	*/
	select @id = count(*) from @files;
	if @inVerboseMode = 1
	begin
		select * from @files;
		print '   /* After removing directories from the files list, we have ' + cast(@id as varchar) + ' files to check. */';
		insert into @OutputTable (sortOrder, rowText) values (1, '   /* After removing directories from the files list, we have ' + cast(@id as varchar) + ' files to check. */');
	end
	if @id < 1
		begin
			print '   /* ERROR! I did not find any backup files in the path you supplied. Please check your @inSource_Directory try again? */';
			return /* and we're done here folks! No way to move forward from that. */
		end
	/*
		===============================================================================================================================
		===============================================================================================================================
			show what parameters were used
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	set @ScriptLine = N'   -- exec [dbo].[BuildRestoreScript]  @inSource_Directory = ''' + @inSource_Directory + ''', @inSource_DatabaseName = ''' + @inSource_DatabaseName + '''';
	if @inSource_ServerName is not null
		set @ScriptLine = @ScriptLine + N', @inSource_ServerName = ''' + @inSource_ServerName + '''';
	if @inSource_InstanceName is not null
		set @ScriptLine = @ScriptLine + N', @inSource_InstanceName = ''' + @inSource_InstanceName + '''';
	if @inSource_ClusterName is not null
		set @ScriptLine = @ScriptLine + N', @inSource_ClusterName = ''' + @inSource_ClusterName + '''';
	if @inSource_AvailabilityGroupName is not null
		set @ScriptLine = @ScriptLine + N', @inSource_AvailabilityGroupName = ''' + @inSource_AvailabilityGroupName + '''';
	if @inSource_DirectoryStructure is not null
		set @ScriptLine = @ScriptLine + N', @inSource_DirectoryStructure = ''' + @inSource_DirectoryStructure + '''';
	if @inSource_AvailabilityGroupDirectoryStructure is not null
		set @ScriptLine = @ScriptLine + N', @inSource_AvailabilityGroupDirectoryStructure = ''' + @inSource_AvailabilityGroupDirectoryStructure + '''';
	if @inDestination_DatabaseName is not null
		set @ScriptLine = @ScriptLine + N', @inDestination_DatabaseName = ''' + @inDestination_DatabaseName + '''';
	if @inDestination_DataFilePath is not null
		set @ScriptLine = @ScriptLine + N', @inDestination_DataFilePath = ''' + @inDestination_DataFilePath + '''';
	if @inDestination_LogFilePath is not null
		set @ScriptLine = @ScriptLine + N', @inDestination_LogFilePath = ''' + @inDestination_LogFilePath + '''';
	if @inStopAtTime is not null and @inStopAtTime < sysdatetime()
		set @ScriptLine = @ScriptLine + N', @inStopAtTime = ''' + cast(@inStopAtTime as varchar) + '''';
	if @inStartAtTime is not null and @inStartAtTime > '1980-01-01'
		set @ScriptLine = @ScriptLine + N', @inStartAtTime = ''' + cast(@inStartAtTime as varchar) + '''';
	if @inGetFull is not null
		set @ScriptLine = @ScriptLine + N', @inGetFull = ' + cast(@inGetFull as varchar) ;
	if @inGetDiff is not null
		set @ScriptLine = @ScriptLine + N', @inGetDiff = ' + cast(@inGetDiff as varchar) ;
	if @inGetLogs is not null
		set @ScriptLine = @ScriptLine + N', @inGetLogs = ' + cast(@inGetLogs as varchar);
	if @inRenameFiles is not null and @inRenameFiles = 1
		set @ScriptLine = @ScriptLine + N', @inRenameFiles = 1';
	if @inDoRecover is not null and @inDoRecover = 1
		set @ScriptLine = @ScriptLine + N', @inDoRecover = 1';
	if @inDoChangeOwner is not null and @inDoChangeOwner = 1
		set @ScriptLine = @ScriptLine + N', @inDoChangeOwner = 1';
	if @inVerboseMode is not null and @inVerboseMode = 1
		set @ScriptLine = @ScriptLine + N', @inVerboseMode = 1';
	print @scriptLine;
	insert into @OutputTable (sortOrder, rowText) values (1, @ScriptLine);
	set @ScriptLine = N'';
	/*

		===============================================================================================================================
		===============================================================================================================================
			Gather metadata and eliminate bad files
		-------------------------------------------------------------------------------------------------------------------------------
		If we could guarantee that users had left the {backup_type} token in place, this could go much faster:
			just check file creation dates and search file names for backup type and go on. 
		But that can't be guaranteed; best to do this via restore headeronly. (This also verifies the file is actually a readable backup, too. 
		Slower, but more accurate and less likely to blow up with sites that have custom scripts.
	*/

	if @inVerboseMode = 1
	begin
		print ' -- Gathering header data from files...';
		insert into @OutputTable (sortOrder, rowText) values (1, '-- Gathering header data from files');
	end

	open allFiles;
	FETCH NEXT FROM allFiles INTO @id, @strPath, @fileName ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @actionFlag = 1;
		begin try	
			/*    Get HeaderOnly data! */
			insert into @header_only (BackupName, 	BackupDescription,	BackupType,	ExpirationDate,	Compressed,
    				Position,	DeviceType,	UserName,	ServerName,	DatabaseName,	DatabaseVersion,
	    			DatabaseCreationDate,	BackupSize,	FirstLSN,	LastLSN,	CheckpointLSN,	DatabaseBackupLSN,
		    		BackupStartDate,	BackupFinishDate,	SortOrder,  	[CodePage],	UnicodeLocaleID,
			    	UnicodeComparisonStyle,	CompatibilityLevel,	SoftwareVendorId,	SoftwareVersionMajor,
				    SoftwareVersionMinor,	SoftwareVersionBuild,	MachineName,	Flags,  	BindingID,	RecoveryForkID,
    				Collation,	FamilyGUID,	HasBulkLoggedData,	IsSnapshot,	IsReadOnly,	IsSingleUser,
	    			HasBackupChecksums,	IsDamaged,	BeginsLogChain,	HasIncompleteMetaData,	IsForceOffline,
		    		IsCopyOnly,	FirstReoveryForkID,	ForkPointLSN,	RecoveryModel,	DifferentialBaseLSN,
			    	DifferentialBaseGUID,	BackupTypeDescription,	BackupSetGUID,	CompressedBackupSize,
    				Containment,	KeyAlgorithm,	EncryptorThumbprint,	EncryptorType)
			   exec ('RESTORE HeaderOnly FROM DISK = ''' + @strPath + @DirectorySeparator + @fileName + '''; ');
			select top 1 @isDamaged = isDamaged, @BackupStartDate = BackupStartDate, @BackupFinishDate = BackupFinishDate, @BackupType = BackupType,
				   @FirstLSN = FirstLSN, @LastLSN = LastLSN, @CheckpointLSN = CheckpointLSN, @DatabaseBackupLSN = DatabaseBackupLSN,
				   @DatabaseName = DatabaseName
			  from @Header_Only;
		end try
		begin catch
			print ' /* ERROR: Not a backup file at all, or cannot read header data: ' + @strPath + @DirectorySeparator + @fileName + ' */ ';
			insert into @OutputTable (sortOrder, rowText) values (1, ' /* ERROR: Not a backup file at all, or cannot read header data: ' + @strPath + @DirectorySeparator + @fileName + ' */');
			set @actionFlag = -1000;			
		end catch;

		if @isDamaged = 1
		begin
			print ' -- --------------------------------------------------';
			print ' -- WARNING: this backup is from a damaged database!';
			print ' --          Restore may not succeed or may require extra steps outside the scope of this tool.';
			print ' -- --------------------------------------------------';
			insert into @OutputTable (sortOrder, rowText) values (1, ' -- WARNING: this backup is from a damaged database! Restore may not succeed or may require extra steps outside the scope of this tool.');
		end;

		/* is the user worried about this type of backup file? */
		if @actionFlag > 0 and @BackupType = 1 and @inGetFull = 0
			set @actionFlag = -1;
		if @actionFlag > 0 and @BackupType = 5 and @inGetDiff = 0
			set @actionFlag = -5;
		if @actionFlag > 0 and @BackupType = 2 and @inGetLogs = 0
			set @actionFlag = -2;

		/* valid backup file but wrong database? */
		if @actionFlag > 0 and @DatabaseName <> @inSource_DatabaseName
			set @actionFlag = -100;
		/* valid file, right DB, but outside the user start/stop times? */
		if  @actionFlag > 0 and @BackupFinishDate < @inStartAtTime or @BackupStartDate > @inStopAtTime
			set @actionFlag = -100;
		/* valid file, right db, good user times, but we've found a newer full backup? */
		if @actionFlag > 0 and @BackupType = 1
			if @BackupStartDate < @fullBackupStartTime
				set @actionFlag = -10;
			else
			begin
				set @fullBackupStartTime = @BackupStartDate;
				set @fullBackupStopTime = @BackupFinishDate;
			end;
		/* valid file, right db, good user times, but we've found a newer diff backup? */
		if @actionFlag > 0 and @BackupType = 5
		begin
			if @BackupStartDate < @diffBackupStartTime -- or @BackupStartDate < @fullBackupStopTime or @BackupStartDate < @diffBackupStopTime
				set @actionFlag = -10;
			
			if @actionFlag > 0 and @BackupStartDate < @fullBackupStopTime
				set @actionFlag = -11;

			if @actionFlag > 0 and @BackupStartDate < @diffBackupStartTime
				set @actionFlag = -12;

			if @actionFlag > 0
			begin
				set @diffBackupStartTime = @BackupStartDate;
				set @diffBackupStopTime = @BackupFinishDate;			
			end;
		end;
		/* valid file, right db, good user times, but we've found logs we don't need due to full or diff backups? */
		if @actionFlag > 0 and @BackupType = 2
			if @BackupStartDate < @fullBackupStopTime or @BackupStartDate < @diffBackupStopTime
				set @actionFlag = -10;
		
		if @actionFlag > 0
			set @actionFlag = @BackupType;

		/* DONE checking this file. flag the file as bad or record the things we care about from headeronly data */
		if @actionFlag < -500
			update @files set BackupType = @actionFlag where id = @id;
		else
			Update @files set BackupStartDate = @BackupStartDate, BackupFinishDate = @BackupFinishDate, BackupType = @actionFlag,
						   FirstLSN = @FirstLSN, LastLSN = @LastLSN, CheckpointLSN = @CheckpointLSN, DatabaseBackupLSN = @DatabaseBackupLSN
			 where id = @id;

 		delete from @header_only;
		delete from @Label_Only;
		FETCH NEXT FROM allFiles INTO @id, @strPath, @fileName ;
	end
	close allFiles;
	deallocate allFiles;

	/* close out backups that are still too old for us to bother with */
	update @files set BackupType = BackupType * -10 
	 where BackupType in (1, 2, 5)
	   and (BackupFinishDate < @fullBackupStartTime
			or BackupStartDate > @inStopAtTime
			or BackupFinishDate < @inStartAtTime );
 
	update @files set BackupType = BackupType * -10 
	 where BackupType in (2, 5)
	   and BackupFinishDate < @diffBackupStartTime;

	/*  show the files in the right order */
	update @files set OrderBy = 1 where BackupType = 1;
	update @files set OrderBy = 2 where BackupType = 5;
	update @files set OrderBy = 3 where BackupType = 2;
	update @files set OrderBy = 4 where OrderBy is null;
	/*
		===============================================================================================================================
		===============================================================================================================================
			get labels and one get files list from 1 file
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	open allFilesSecondPass;
	FETCH NEXT FROM allFilesSecondPass INTO @id, @strPath, @fileName, @BackupType ;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* only need to get the list of files once; no need to scan for files every time */
		if @BackupType = 1 and @filesCount < 1
		Begin
			insert into @FileList_Only (LogicalName,			PhysicalName,			[Type],
						FileGroupName,	Size,					MaxSize,				FileID,
						CreateLSN,		DropLSN,				UniqueID,				ReadOnlyLSN,
						ReadWriteLSN,	BackupSizeInBytes,		SourceBlockSize,		FileGroupID,
						LogGroupGUID,	DifferentialBaseLSN,	DifferentialBaseGUID,	IsReadOnly,
						IsPresent,		TDEThumbprint,			SnapshotURL )
				exec ('RESTORE FileListOnly FROM DISK = ''' + @strPath + @DirectorySeparator + @fileName + '''; ');
			update @FileList_Only set FilesID = @id where FilesID is null;
			select @filesCount = count(*) from @FileList_Only where FilesID = @id;
		end;

		/*  Get LabelOnly Data here, in case this is a multi-file set */
		insert into @Label_Only ([MediaName],	MediaSetId,				FamilyCount,
					FamilySequenceNumber,		MediaFamilyId,			MediaSequenceNumber,
					MediaLabelPresent,			[MediaDescription],		SoftwareName,
					SoftwareVendorId,			MediaDate,				Mirror_Count,		IsCompressed)
		   exec ('RESTORE LabelOnly FROM DISK = ''' + @strPath + @DirectorySeparator + @fileName + '''; ');
		select top 1 @FamilyCount = FamilyCount, @FamilySequenceNumber = FamilySequenceNumber 
		  from @Label_Only;
		update @files set FamilyCount = @FamilyCount, FamilySequenceNumber = @FamilySequenceNumber where id = @id;

		delete from @header_only;
		delete from @Label_Only;
		FETCH NEXT FROM allFilesSecondPass INTO @id, @strPath, @fileName, @BackupType ;
	end; 
	close allFilesSecondPass;
	deallocate allFilesSecondPass;

	select @filesCount = count(*) from @files;
	select @FullBackupFiles = count(*) from @files where BackupType = 1;
	select @DiffBackupFiles = count(*) from @files where BackupType = 5;
	select @LogBackupFiles  = count(*) from @files where BackupType = 2;
	if @inVerboseMode = 1
	begin
		set @strData = ' -- Out of ' + cast(@filesCount as varchar) + ' files, found ' + cast(@FullBackupFiles as varchar) + ' Full backup files, ' +
			cast(@DiffBackupFiles as varchar) + ' Diff backup files, ' + cast(@LogBackupFiles as varchar) + ' log files, and ';
		select @filesCount = count(*) from @files where BackupType < 1;
		set @strData = @strData + cast(@filesCount as varchar) + ' other files.';
		print @strData;
		insert into @OutputTable (sortOrder, rowText) values (1, @strData);
	end;
	/*
		===============================================================================================================================
		===============================================================================================================================
			Start with Full restore, if requested 
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	if @inGetFull = 1
	begin
		set @ScriptLine =
		    N' /* =============================================================================================================================== ' + char(13) +
			 '                     FULL Restore Statement...' + char(13) +
			 '    ------------------------------------------------------------------------------------------------------------------------------- */ ' + char(13) + 
			 '    print ''Starting Full Restore of database [' + @inSource_DatabaseName + '] to [' + @inDestination_DatabaseName + '].'';' + char(13);
		print @ScriptLine;
		insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
		if @FullBackupFiles < 1
		begin
			print '  /*  ERROR! You asked to restore Full backup file(s), but none exist!  */';
			insert into @OutputTable (sortOrder, rowText) values (2, ' /*  ERROR! You asked to restore Full backup file(s), but none exist!  */');
		end;
		set @ScriptLine = N'Restore Database [' + @inDestination_DatabaseName + '] FROM ';
		insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
		print @ScriptLine;
		open GetFullFiles
		/* Fetch the backup file(s) */
		FETCH NEXT FROM GetFullFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber;
		WHILE @@FETCH_STATUS = 0
		begin
			if right(@strPath, 1) <> @DirectorySeparator
				set @strPath = @strPath + @DirectorySeparator;

			if @FamilySequenceNumber = 1
				set @ScriptLine = '    DISK = N''' + @strPath + @fileName + ''' ';
			else
				set @ScriptLine = '  , DISK = N''' + @strPath + @fileName + ''' ';
			insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
			print @ScriptLine;
			FETCH NEXT FROM GetFullFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber;
		end
		close GetFullFiles;
		deallocate GetFullFiles;
		set @ScriptLine = '  WITH FILE = 1, NORECOVERY, STATS=10  ' + @StopAtText  + char(13) +
			 '     /* , REPLACE -- remove the / * at the beginning of this line to overwrite an existing database */ ' + char(13) +
			'     /*     Confirm the filenames and paths below are valid for the destination instance    */ ';
		insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
		print @ScriptLine;
		if @FamilySequenceNumber < @FamilyCount
		begin
			set @ScriptLine = '  /*  ERROR! Expected to find ' + cast(@FamilyCount as varchar) + ' Full backup files. Only found ' + cast(@FamilySequenceNumber as varchar) + '.  */';
			insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
			print @ScriptLine;
		end;
		/* 
			Build the MOVE x to y file clauses 
		*/		
		open getFilesList
		FETCH NEXT FROM getFilesList into @logicalName, @physicalName, @fileType, @id;
		WHILE @@FETCH_STATUS = 0
		begin
			-- split path from filename
			set @fileName = REVERSE(@physicalName);
			set @fileName = REVERSE(left(@fileName, CHARINDEX(@directorySeparator, @fileName) -1))
			set @strPath = REPLACE(@physicalName, @fileName, '')
			if @fileType = 'L'
			begin
				if @inDestination_LogFilePath is not null and @inDestination_LogFilePath <> @strPath
					set @strPath = @inDestination_LogFilePath;
			end 
			else 
			begin
				if @inDestination_DataFilePath is not null and @inDestination_DataFilePath <> @strPath
					set @strPath = @inDestination_DataFilePath;
			end
			/* TODO: handle file types other than data and log? */
			if @inRenameFiles = 1 
			begin
				if @fileType = 'L'
				begin
					set @fileName = @inDestination_DatabaseName + '_Log' + '_' + right('00' + cast(@LogFileNum as varchar), 2) + '.ldf';
					set @LogFileNum = @LogFileNum + 1;
				end
				else
				begin
					set @fileName = @inDestination_DatabaseName + '_' + right('00' + cast(@DataFileNum as varchar), 2);
					if @DataFileNum = 1
						set @fileName = @fileName + '.mdf';
					else
						set @fileName = @fileName + '.ndf';
					set @DataFileNum = @DataFileNum + 1;
				end;
			end;
			set @ScriptLine = '  , MOVE N''' + @logicalName + ''' TO N''' + @strPath + @fileName + ''' ' ;
			insert into @OutputTable (sortOrder, rowText) values (2, @scriptLine);
			print @ScriptLine;
			FETCH NEXT FROM getFilesList into @logicalName, @physicalName, @fileType, @id;
		end
		close getFilesList;
		deallocate getFilesList;
		insert into @OutputTable (sortOrder, rowText) values (2,' ; ');
		print ';';		
	/*	SET @printCounter = 0
		SET @TotalPrints = (LEN(@ScriptLine) / 4000) + 1
		WHILE @printCounter < @TotalPrints 
		BEGIN
			-- Do your printing...
			print substring(@ScriptLine, @printCounter * 4000, 4000);
			SET @printCounter = @printCounter + 1
		END 		
		insert into @OutputTable (sortOrder, rowText) values (2, @ScriptLine + ' ;');
	*/	
	end; /* / inGetFull */
	/*
		===============================================================================================================================
		===============================================================================================================================
			Diff restore, if requested 
		-------------------------------------------------------------------------------------------------------------------------------
	*/
	if @inGetDiff = 1
	begin
		set @ScriptLine = N' /* =============================================================================================================================== ' + char(13) +
			 '                     DIFF Restore Statement...' + char(13) +
			 '    ------------------------------------------------------------------------------------------------------------------------------- */ ' + char(13) + 
			 '    print ''Starting DIF Restore to database [' + @inDestination_DatabaseName + '].'';' + char(13);
		print @scriptLine;
		insert into @OutputTable (sortOrder, rowText) values (3, @scriptLine);
		if @DiffBackupFiles < 1
		begin
			print '  /*  ERROR! You asked to restore Diff backup file(s), but none exist! */';
			insert into @OutputTable (sortOrder, rowText) values (3, '  /*  ERROR! You asked to restore Diff backup file(s), but none exist! */');
		end;
		set @ScriptLine = N'Restore Database [' + @inDestination_DatabaseName + '] FROM ';
		print @scriptLine;
		insert into @OutputTable (sortOrder, rowText) values (3, @scriptLine);
		open GetDiffFiles
		FETCH NEXT FROM GetDiffFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber;
		WHILE @@FETCH_STATUS = 0
		begin
			if right(@strPath, 1) <> @DirectorySeparator
				set @strPath = @strPath + @DirectorySeparator;

			if @FamilySequenceNumber = 1
				set @ScriptLine = '    DISK = N''' + @strPath + @fileName + ''' ';
			else
				set @ScriptLine = '  , DISK = N''' + @strPath + @fileName + ''' ';
			print @scriptLine;
			insert into @OutputTable (sortOrder, rowText) values (3, @scriptLine);
			FETCH NEXT FROM GetDiffFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber;
		end
		close GetDiffFiles;
		deallocate GetDiffFiles;
		set @ScriptLine = '  WITH FILE = 1, NORECOVERY, STATS=10 ' +  @StopAtText + ';';
		print @scriptLine;
		insert into @OutputTable (sortOrder, rowText) values (3, @scriptLine);
/*		set @ScriptLine+= ';'; 
		SET @printCounter = 0
		SET @TotalPrints = (LEN(@ScriptLine) / 4000) + 1
		WHILE @printCounter < @TotalPrints 
		BEGIN
			-- Do your printing...
			print substring(@ScriptLine, @printCounter * 4000, 4000);
			SET @printCounter = @printCounter + 1
		END
		insert into @OutputTable (sortOrder, rowText) values (3, @ScriptLine ); */
		if @FamilySequenceNumber < @FamilyCount
		begin
			set @ScriptLine =  ' /* ERROR! Expected to find ' + cast(@FamilyCount as varchar) + ' DIFF backup files. Only found ' + cast(@FamilySequenceNumber as varchar) + '. */';
			print @scriptLine;
			insert into @OutputTable (sortOrder, rowText) values (3, @scriptLine);
		end;
	end; /* / inGetDiff */
	/*
		===============================================================================================================================
		===============================================================================================================================
			Log restore, if requested 
		-------------------------------------------------------------------------------------------------------------------------------
		this is a little trickier, as each log could be a family sequence OR it could be the next log in the chain...
		RESTORE LOG [Titan_Test] FROM DISK = '\\wtr-sql-backup\DB_Backups\SQL\wtrTitanDb-Pd\Titan_Prod\LOG\WTRTitanDB-PD_Titan_Prod_LOG_20211118_022400.trn' WITH NoRecovery, STATS=10 ; 
		Print '   Restoring file 2 of 21 : \\wtr-sql-backup\DB_Backups\SQL\wtrTitanDb-Pd\Titan_Prod\LOG\WTRTitanDB-PD_Titan_Prod_LOG_20211118_025600.trn' ; 
	*/
	if @inGetLogs = 1
	begin
		set @ScriptLine = N' /* =============================================================================================================================== ' + char(13) +
			 '                     LOG Restore Statements...' + char(13) +
			 '    ------------------------------------------------------------------------------------------------------------------------------- */ ' + char(13)+ 
			 '    print ''Starting LOG Restores to database [' + @inDestination_DatabaseName + ']. There are ' + cast(@logBackupFiles as varchar) + ' Log files.'';' + char(13);
		print @scriptLine;
		insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
		if @logBackupFiles < 1
		begin
			print '  /*  ERROR! You asked to restore Log backup file(s), but none exist! */';
			insert into @OutputTable (sortOrder, rowText) values (4, '  /*  ERROR! You asked to restore Log backup file(s), but none exist! */');
		end;

		set @actionFlag = 0;

		open GetLogFiles
		FETCH NEXT FROM GetLogFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber, @BackupStartDate;
		WHILE @@FETCH_STATUS = 0
		begin
			if right(@strPath, 1) <> @DirectorySeparator
				set @strPath = @strPath + @DirectorySeparator;
			if @actionFlag = 0
			begin	/* First run, don't close out a previous restore statement */
				set @ScriptLine = 'Restore Database [' + @inDestination_DatabaseName + '] FROM ' + char(13) +
					'    DISK = N''' + @strPath + @fileName + ''' ' ;
				print @scriptLine;
				insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
				set @lastBackupStartDate = @BackupStartDate;
			end
			else
			begin	/* not the 1st run, add to or close out the previous restore statement before we list this logfile */
				if @BackupStartDate = @lastBackupStartDate
				begin
					set @ScriptLine = '  , DISK = N''' + @strPath + @fileName + ''' ' ;
					print @scriptLine;
					insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
				end
				else
				begin
					set @ScriptLine = '  WITH NORECOVERY, STATS=10 ' + @StopAtText + '; ' ; 
					print @scriptLine;
					insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
					if @actionFlag / 10 = @actionFlag / 10.0
					begin						
						set @ScriptLine = '    print ''  ...Finished ' + cast(@actionFlag as varchar) + ' of ' + cast(@logBackupFiles as varchar) + ' log files...''; ';
						print @scriptLine;
						insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
					end;
					set @ScriptLine = N'Restore Database [' + @inDestination_DatabaseName + '] FROM ' + char(13) + 
						' DISK = N''' + @strPath + @fileName + ''' ' + char(13);
					print @scriptLine;
					insert into @OutputTable (sortOrder, rowText) values (4, @scriptLine);
				end;
			end;
			set @actionFlag = @actionFlag + 1;
			FETCH NEXT FROM GetLogFiles INTO @id, @strPath, @fileName, @FamilyCount, @FamilySequenceNumber, @BackupStartDate;
		end
		close GetLogFiles;
		deallocate GetLogFiles;
		set @ScriptLine =  N' WITH NORECOVERY, STATS=10 ' +  @StopAtText + '; ' + char(13) +
				 N'print ''...Done restoring log files!'';' + char(13) ;	
		print @scriptline;
		insert into @OutputTable (sortOrder, rowText) values (4, @scriptline);
	end; /* / @inGetLogs */
	/*
		===============================================================================================================================
		===============================================================================================================================
			Provide recovery and change owner statements
		-------------------------------------------------------------------------------------------------------------------------------		
	*/
	set @ScriptLine = N'/* =============================================================================================================================== */' + char(13);

	if @inDoRecover = 1
		set @ScriptLine = @ScriptLine + N'Restore Database [' + @inDestination_DatabaseName + ']  WITH RECOVERY; '  + char(13);
	else
		set @ScriptLine = @ScriptLine + N' /*  -- To use the new database run this:' + char(13) +
			'Restore Database [' + @inDestination_DatabaseName + ']  WITH RECOVERY; ' + char(13) + ' */' + char(13);
	
	if @inDoRecover = 1 and @inDoChangeOwner = 1
		set @ScriptLine = @ScriptLine + N'ALTER AUTHORIZATION ON DATABASE::['+ @inDestination_DatabaseName + '] TO [sa] ' + Char(13);
	else
		set @ScriptLine = @ScriptLine + N' /* -- To change the owner from you to SA, run this: ' + char(13) +
			N'ALTER AUTHORIZATION ON DATABASE::['+ @inDestination_DatabaseName + '] TO [sa] ' + Char(13) + ' */' + char(13);
	set @ScriptLine = @ScriptLine +  N'/* =============================================================================================================================== */' + char(13);
	print @scriptline;
	insert into @OutputTable (sortOrder, rowText) values (5, @scriptline);
	/*
		===============================================================================================================================
		===============================================================================================================================
			Provide table-based output results and exit out because we're done folks
		-------------------------------------------------------------------------------------------------------------------------------		
	*/
	select rowText, insertTime, sortOrder, id 
	  from @OutputTable
	 order by sortOrder, id;

	if @inVerboseMode = 1
	begin
		select * 
		  from @Files
		 order by OrderBy, filedate ; 
 		
		select * from @FileList_Only;
	end;
	set @stopRuntime = SYSDATETIME();
	print ' -- Stopping run at ' + cast(@stopRuntime as varchar);
	print ' -- Took ' + cast (datediff(ms, @StartRunTime, @stopRuntime) as varchar) + ' ms to complete.';
	print ' -- If you are copying this text from SSMS to generate your script, remember to delete the completion time seen below: ';
	/*
		-------------------------------------------------------------------------------------------------------------------------------	
			DONE!
		===============================================================================================================================
		===============================================================================================================================
	*/
End;
GO

ALTER AUTHORIZATION ON [dbo].[BuildRestoreScripts] TO  SCHEMA OWNER 
GO


