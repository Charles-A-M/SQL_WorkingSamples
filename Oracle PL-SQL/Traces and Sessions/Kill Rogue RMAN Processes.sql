/*
select 
   count(*) 
from 
   v$rman_output;


select 
   session_key, 
   input_type, 
   status,
   to_char(start_time,'dd/mm/yy hh24:mi') start_time,
   to_char(end_time,'dd/mm/yy hh24:mi')   end_time,
   round((end_time-start_time)*1440,2)    "minutes"
from 
   v$rman_backup_job_details
where 
   input_type='DB INCR'
order by 
   session_key desc;

-- ***********************************************

select 
   sid,
   recid,
   command_id,    operation,   status,   start_time,   end_time 
from 
   v$rman_status 
where   STATUS not like 'COMPLETED%'
  and STart_Time < sysdate -1; --  recid=nnn;
*/

--Run this on the database being backed up.
Select sid, serial#, logon_time, Status,
    'Alter System Kill Session ''' || sid || ',' || serial# || ''';   -- ' || to_char(logon_time)
  From v$session
  where Logon_Time < sysdate -1 and
   program = 'rman.exe'
   and status <> 'KILLED'
  order by logon_time 
  ;


--see any session more than X hours old.
select *
  from v$session
  where  (sysdate - logon_time ) * 24 > 20 --hours
  and type <> 'BACKGROUND'
  and status <> 'KILLED'
  order by logon_time
  ;
 
