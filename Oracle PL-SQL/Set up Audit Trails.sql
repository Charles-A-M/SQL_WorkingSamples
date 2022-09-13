--configure audit trails.
--done in dev01, dev02, dev03, IMSP
alter system set audit_trail='DB','EXTENDED' scope=spfile;
show parameter audit_trail;

audit create session;
audit create session whenever  successful;
audit create session whenever not successful;

SELECT owner, table_name, tablespace_name FROM dba_tables WHERE table_name IN ('AUD$', 'FGA_LOG$') ORDER BY table_name;

--audit space size
SELECT 
    owner, segment_name, segment_type, tablespace_name, bytes/1048576 MB, initial_extent,
    next_extent, extents, pct_increase 
FROM DBA_SEGMENTS
WHERE OWNER = 'SYS' 
AND SEGMENT_NAME in ( 'AUD$', 'FGA_LOG$') 
AND SEGMENT_TYPE = 'TABLE'
;


--create an audit trail tablespace so this data isn't stored in SYSTEM or SYSAUX;
--		on wtrOracle
create tablespace AuditTrails 
	datafile 'F:\ORADATA\...\AuditTrails_01.dbf' size 1g autoextend on next 24m maxsize 24g,
			 'F:\ORADATA\...\AuditTrails_02.dbf' size 1g autoextend on next 24m maxsize 24g,
			 'F:\ORADATA\...\AuditTrails_03.dbf' size 1g autoextend on next 24m maxsize 24g
extent management local uniform size  64K;
--		on WtrOra12ps
create tablespace AuditTrails 
	datafile 'o:\ORADATA\...\AuditTrails_01.dbf' size 1g autoextend on next 24m maxsize 24g,
			 'o:\ORADATA\...\AuditTrails_02.dbf' size 1g autoextend on next 24m maxsize 24g,
			 'o:\ORADATA\...\AuditTrails_03.dbf' size 1g autoextend on next 24m maxsize 24g
extent management local uniform size  64K;


--move aud$ table to new Tablespace.
begin
 dbms_audit_mgmt.set_audit_trail_location(
  audit_trail_type            => dbms_audit_mgmt.audit_trail_aud_std,
  audit_trail_location_value  => 'AUDITTRAILS');
end;
/

--set cleanup interval to 14 days
BEGIN
  DBMS_AUDIT_MGMT.INIT_CLEANUP(
    AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
    DEFAULT_CLEANUP_INTERVAL => (24 * 14) /*hours*/
  );
END;
/

--set last archive timestamp to 14 days ago.
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name   => 'DAILY_AUDIT_ARCHIVE_TIMESTAMP',
    job_type   => 'PLSQL_BLOCK',
    job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                   DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,LAST_ARCHIVE_TIME => sysdate-14); END;', 
    start_date => sysdate, 
    repeat_interval => 'FREQ=HOURLY;INTERVAL=12', 
    enabled    =>  TRUE,
    comments   => 'Create an archive timestamp'
  );
END;
/

--purge old audit trail data < last archive timestamp
BEGIN
  DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
    AUDIT_TRAIL_TYPE           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
    AUDIT_TRAIL_PURGE_INTERVAL => 24 /* hours */,
    AUDIT_TRAIL_PURGE_NAME     => 'Daily_Audit_Purge_Job',
    USE_LAST_ARCH_TIMESTAMP    => TRUE
  );
END;
/


SELECT JOB_NAME,JOB_STATUS,AUDIT_TRAIL,JOB_FREQUENCY FROM DBA_AUDIT_MGMT_CLEANUP_JOBS;
SELECT job_name, next_run_date, state, enabled FROM dba_scheduler_jobs WHERE job_name LIKE '%AUDIT%';


--manually purge everything older than 14 days:

BEGIN
  DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
   AUDIT_TRAIL_TYPE     =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
   LAST_ARCHIVE_TIME    =>  sysdate - 14,
   RAC_INSTANCE_NUMBER  =>  1,
   CONTAINER            => DBMS_AUDIT_MGMT.CONTAINER_CURRENT);
END;
/


BEGIN
  DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
   AUDIT_TRAIL_TYPE           =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
   USE_LAST_ARCH_TIMESTAMP    =>  TRUE,
   CONTAINER                  =>  DBMS_AUDIT_MGMT.CONTAINER_CURRENT );
END;
/


commit;
