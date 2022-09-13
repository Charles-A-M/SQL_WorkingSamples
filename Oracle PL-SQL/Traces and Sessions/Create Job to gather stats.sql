BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'GatherStats',
   job_type           =>  'PLSQL_BLOCK',
   job_action         =>  'begin 
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
  delete from sys.cod_activelog where collectdate < sysdate - 60;
  commit;
  end;',
   start_date         =>  sysdate,
   repeat_interval    =>  'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI;BYHOUR=5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20; BYMINUTE=0,5,10,15,20,25,30,35,40,45,50,55;', 
   --end_date           =>  '20-NOV-24',
   enabled            => TRUE,
   --job_class          =>  'batch_update_jobs',
   comments           =>  'Charles Moore 01 Dec 2016, gather statistics on user sessions');
END;
/
commit;


/*
select * from all_scheduler_jobs;

select * from cod_activeLog;
*/