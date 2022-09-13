-- https://www.brentozar.com/blitz/slow-storage-reads-writes/
	--Details
	SELECT  DB_NAME(a.database_id) AS [Database Name] ,
        b.name + N' [' + b.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS + N']' AS [Logical File Name] ,
        UPPER(SUBSTRING(b.physical_name, 1, 2)) AS [Drive] ,
        CAST(( ( a.size_on_disk_bytes / 1024.0 ) / (1024.0*1024.0) ) AS DECIMAL(9,2)) AS [Size (GB)] ,
        a.io_stall_read_ms AS [Total IO Read Stall] ,
        a.num_of_reads AS [Total Reads] ,
        CASE WHEN a.num_of_bytes_read > 0 
            THEN CAST(a.num_of_bytes_read/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
            ELSE 0 
        END AS [GB Read],
        CAST(a.io_stall_read_ms / ( 1.0 * a.num_of_reads ) AS INT) AS [Avg Read Stall (ms)] ,
        CASE 
            WHEN b.type = 0 THEN 30 /* data files */
            WHEN b.type = 1 THEN 5 /* log files */
            ELSE 0
        END AS [Max Recommended ARS],
        a.io_stall_write_ms AS [Total IO Write Stall] ,
        a.num_of_writes [Total Writes] ,
        CASE WHEN a.num_of_bytes_written > 0 
            THEN CAST(a.num_of_bytes_written/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
            ELSE 0 
        END AS [GB Written],
        CAST(a.io_stall_write_ms / ( 1.0 * a.num_of_writes ) AS INT) AS [Avg Write Stall (ms)] ,
        CASE 
            WHEN b.type = 0 THEN 30 /* data files */
            WHEN b.type = 1 THEN 2 /* log files */
            ELSE 0
        END AS [Max Recommended AWS] ,
        b.physical_name AS [Physical File Name],
        CASE
            WHEN b.name = 'tempdb' THEN 'N/A'
            WHEN b.type = 1 THEN 'N/A' /* log files */
            ELSE 'PAGEIOLATCH*'
        END AS [Read-Related Wait Stat],
        CASE
            WHEN b.type = 1 THEN 'WRITELOG' /* log files */
            WHEN b.name = 'tempdb' THEN 'xxx' /* tempdb data files */
            WHEN b.type = 0 THEN 'ASYNC_IO_COMPLETION' /* data files */
            ELSE 'xxx'
        END AS [Write-Related Wait Stat],
        GETDATE() AS [Sample Time],
        b.type_desc
	FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS a
			INNER JOIN sys.master_files AS b ON a.file_id = b.file_id
												AND a.database_id = b.database_id
	WHERE   a.num_of_reads > 0
			AND a.num_of_writes > 0
	ORDER BY  CAST(a.io_stall_read_ms / ( 1.0 * a.num_of_reads ) AS INT) DESC;



--Summarized down drive, DB, filetype 

Select [Drive], [Database Name],  [FileType], 
	sum( [Size (GB)])  [Size (GB)],						--file sizes converted to GB
	--read operations
	sum([Total IO Read Stall]) [Total IO Read Stall],	--total time spent waiting on all files
	sum([Total Reads]) [Total Reads],					--total # of reads from all files
	sum([GB Read]) [GB Read],							--total GB read from all files
	Cast(sum([Total IO Read Stall]) / (1.0 * sum([Total Reads]) ) as INT)  as [Avg Read Stall (ms)], --overall avg time spent waiting on disk
	CASE 
		WHEN [FileType] = 'ROWS' THEN 30 /* data files */
        WHEN [FileType] = 'LOG' THEN 5 /* log files */
        ELSE 0
	END AS [Max Recommended ARS],
	--write operations
	sum([Total IO Write Stall]) [Total IO Write Stall],
	sum([Total Writes]) [Total Writes],
	sum([GB Written]) [GB Written],
	cast(sum([Total IO Write Stall]) / (1.0 * sum([Total Writes]) ) as Int) as  [Avg Write Stall (ms)],
	CASE 
		WHEN [FileType] = 'ROWS' THEN 30 /* data files */
        WHEN [FileType] = 'LOG' THEN 2 /* log files */
        ELSE 0
	END AS [Max Recommended AWS]
From (
		SELECT  DB_NAME(a.database_id) AS [Database Name] ,
			b.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS As [FileType],
			UPPER(SUBSTRING(b.physical_name, 1, 2)) AS [Drive] ,
			CAST(( ( a.size_on_disk_bytes / 1024.0 ) / (1024.0*1024.0) ) AS DECIMAL(9,2)) AS [Size (GB)] ,
			a.io_stall_read_ms AS [Total IO Read Stall] ,
			a.num_of_reads AS [Total Reads] ,
			CASE WHEN a.num_of_bytes_read > 0 
	            THEN CAST(a.num_of_bytes_read/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
				ELSE 0 
			END AS [GB Read],
			a.io_stall_write_ms AS [Total IO Write Stall] ,
			a.num_of_writes [Total Writes] ,
			CASE WHEN a.num_of_bytes_written > 0 
	            THEN CAST(a.num_of_bytes_written/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
				ELSE 0 
			END AS [GB Written],
			CAST(a.io_stall_write_ms / ( 1.0 * a.num_of_writes ) AS INT) AS [Avg Write Stall (ms)] 
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS a
		INNER JOIN sys.master_files AS b ON a.file_id = b.file_id  AND a.database_id = b.database_id
		WHERE a.num_of_reads > 0
		  AND a.num_of_writes > 0
	) a
Group by  [Drive], [Database Name], [FileType]
Having sum( [Size (GB)]) > 0.25 -- ignore rows smaller than this.
  -- remove rows that are fast enough already
  and (
		Cast(sum([Total IO Read Stall]) / (1.0 * sum([Total Reads]) ) as INT)  >
		CASE 
			WHEN [FileType] = 'ROWS' THEN 30 /* data files */
			WHEN [FileType] = 'LOG' THEN 5 /* log files */
			ELSE 2
		END 
	OR
		cast(sum([Total IO Write Stall]) / (1.0 * sum([Total Writes]) ) as Int) >
		CASE 
			WHEN [FileType] = 'ROWS' THEN 30 /* data files */
			WHEN [FileType] = 'LOG' THEN 2 /* log files */
			ELSE 2
		END 
	)
Order by 1, 2


--summarize by drive and file type
Select [Drive],   [FileType], 
	sum( [Size (GB)])  [Size (GB)],						--file sizes converted to GB
	--read operations
	sum([Total IO Read Stall]) [Total IO Read Stall],	--total time spent waiting on all files
	sum([Total Reads]) [Total Reads],					--total # of reads from all files
	sum([GB Read]) [GB Read],							--total GB read from all files
	Cast(sum([Total IO Read Stall]) / (1.0 * sum([Total Reads]) ) as INT)  as [Avg Read Stall (ms)], --overall avg time spent waiting on disk
	CASE 
		WHEN [FileType] = 'ROWS' THEN 30 /* data files */
        WHEN [FileType] = 'LOG' THEN 5 /* log files */
        ELSE 0
	END AS [Max Recommended ARS],
	--write operations
	sum([Total IO Write Stall]) [Total IO Write Stall],
	sum([Total Writes]) [Total Writes],
	sum([GB Written]) [GB Written],
	cast(sum([Total IO Write Stall]) / (1.0 * sum([Total Writes]) ) as Int) as  [Avg Write Stall (ms)],
	CASE 
		WHEN [FileType] = 'ROWS' THEN 30 /* data files */
        WHEN [FileType] = 'LOG' THEN 2 /* log files */
        ELSE 0
	END AS [Max Recommended AWS]
From (
		SELECT  DB_NAME(a.database_id) AS [Database Name] ,
			b.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS As [FileType],
			UPPER(SUBSTRING(b.physical_name, 1, 2)) AS [Drive] ,
			CAST(( ( a.size_on_disk_bytes / 1024.0 ) / (1024.0*1024.0) ) AS DECIMAL(9,2)) AS [Size (GB)] ,
			a.io_stall_read_ms AS [Total IO Read Stall] ,
			a.num_of_reads AS [Total Reads] ,
			CASE WHEN a.num_of_bytes_read > 0 
	            THEN CAST(a.num_of_bytes_read/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
				ELSE 0 
			END AS [GB Read],
			a.io_stall_write_ms AS [Total IO Write Stall] ,
			a.num_of_writes [Total Writes] ,
			CASE WHEN a.num_of_bytes_written > 0 
	            THEN CAST(a.num_of_bytes_written/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
				ELSE 0 
			END AS [GB Written],
			CAST(a.io_stall_write_ms / ( 1.0 * a.num_of_writes ) AS INT) AS [Avg Write Stall (ms)] 
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS a
		INNER JOIN sys.master_files AS b ON a.file_id = b.file_id  AND a.database_id = b.database_id
		WHERE a.num_of_reads > 0
		  AND a.num_of_writes > 0
	) a
Group by  [Drive],   [FileType]
Having sum( [Size (GB)]) > 0.25 -- ignore rows smaller than this.
  -- remove rows that are fast enough already
  and (
		Cast(sum([Total IO Read Stall]) / (1.0 * sum([Total Reads]) ) as INT)  >
		CASE 
			WHEN [FileType] = 'ROWS' THEN 30 /* data files */
			WHEN [FileType] = 'LOG' THEN 5 /* log files */
			ELSE 2
		END 
	OR
		cast(sum([Total IO Write Stall]) / (1.0 * sum([Total Writes]) ) as Int) >
		CASE 
			WHEN [FileType] = 'ROWS' THEN 30 /* data files */
			WHEN [FileType] = 'LOG' THEN 2 /* log files */
			ELSE 2
		END 
	)
Order by 1, 2