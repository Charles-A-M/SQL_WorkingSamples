  CREATE TABLE SYS.COD_ACTIVELOG 
   (	"SID" NUMBER, 
	"SERIAL#" NUMBER, 
	"USERNAME" VARCHAR2(255 BYTE), 
	"STATUS" VARCHAR2(50 BYTE), 
	"SCHEMANAME" VARCHAR2(255 BYTE), 
	"OSUSER" VARCHAR2(255 BYTE), 
	"MACHINE" VARCHAR2(255 BYTE), 
	"TERMINAL" VARCHAR2(128 BYTE), 
	"PROGRAM" VARCHAR2(255 BYTE), 
	"TYPE" VARCHAR2(128 BYTE), 
	"MODULE" VARCHAR2(255 BYTE), 
	"ACTION" VARCHAR2(255 BYTE), 
	"LOGON_TIME" DATE, 
	"BLOCKING_SESSION_STATUS" VARCHAR2(11 BYTE), 
	"BLOCKING_INSTANCE" NUMBER, 
	"BLOCKING_SESSION" NUMBER, 
	"EVENT" VARCHAR2(255 BYTE), 
	"STATE" VARCHAR2(50 BYTE), 
	"SERVICE_NAME" VARCHAR2(128 BYTE), 
	"EXTERNAL_NAME" VARCHAR2(2000 BYTE), 
	"CPU_TIME" NUMBER, 
	"ELAPSED_TIME" NUMBER, 
	"SQL_TEXT" VARCHAR2(2000 BYTE), 
	"COLLECTDATE" TIMESTAMP (6) DEFAULT CURRENT_TIMESTAMP
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "SYSTEM" ;
/


BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"SYS"."COD_GATHER_STATS"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'begin 
   Insert into sys.cod_activeLog (SID, 	SERIAL#,	USERNAME ,	STATUS,	SCHEMANAME,	OSUSER,	MACHINE,	TERMINAL,	PROGRAM,	TYPE,	MODULE,	ACTION,	LOGON_TIME,	
   BLOCKING_SESSION_STATUS,	BLOCKING_INSTANCE,	BLOCKING_SESSION,	EVENT,	STATE,	SERVICE_NAME,	EXTERNAL_NAME,	CPU_TIME,	ELAPSED_TIME,	SQL_TEXT)
   select  sess.sid, sess.serial#, sess.UserName, sess.status, sess.schemaname, sess.osuser, sess.machine, sess.terminal, 
       sess.program, sess.type, sess.module, sess.action, sess.logon_time, sess.blocking_session_status, sess.blocking_instance, sess.blocking_session,
       sess.event, sess.state, sess.service_name, sess.external_name,
       sqa.cpu_time, sqa.elapsed_time, sqa.sql_text
  from v$session sess
  left join v$sqlarea sqa on sqa.hash_value = sess.sql_hash_value and sqa.address = sess.sql_address
  where sess.username is not null
  order by username, sid;
  delete from sys.cod_activelog where collectdate < sysdate - 90;
  commit;
  end;',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2019-07-29 13:53:09.000000000 AMERICA/NEW_YORK','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MINUTELY;INTERVAL=5;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Charles Moore 01 Dec 2016, gather statistics on user sessions');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"SYS"."COD_GATHER_STATS"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"SYS"."COD_GATHER_STATS"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"SYS"."COD_GATHER_STATS"');
END;
