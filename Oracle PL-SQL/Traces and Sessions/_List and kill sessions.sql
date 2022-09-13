-- 							SID, Serial#
--alter system kill session '73,	47145' immediate;

select sid, serial#, user#, username, status, schemaname, osuser process, machine, module, logon_time
  from v$session 
  where type <> 'BACKGROUND'
order by username;


select  'Alter System kill session ''' || to_char(sid) || ', ' || to_char(serial#) || ''' immediate; ',  s.*
from v$session s where type <> 'BACKGROUND' order by logon_time;