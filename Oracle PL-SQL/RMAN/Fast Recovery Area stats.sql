-- https://logbuffer.wordpress.com/2011/05/30/oracle-how-to-tell-db-about-manually-freed-space-in-fra/
-- summary:
-- path, limit, used, % used.
SELECT name Path,
  ROUND(space_limit/1024/1024/1024,0) limit_gb,
  ROUND(space_used /1024/1024/1024,0) used_gb,
  ROUND(space_used /space_limit,4)*100 AS pct_used
FROM V$RECOVERY_FILE_DEST;

--Details
--select * from v$flash_recovery_area_usage;
select file_type, percent_space_used, percent_space_reclaimable, number_of_files 
from v$flash_recovery_area_usage
where percent_space_used > 0 
   or percent_space_reclaimable > 0
   or number_of_files > 0 ;
 

/*
CROSSCHECK ARCHIVELOG ALL;
DELETE EXPIRED ARCHIVELOG ALL;
DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-3';
*/

show parameter DB_RECOVERY_FILE_DEST_SIZE ;
--alter system set DB_RECOVERY_FILE_DEST_SIZE =XXg scope=both;

