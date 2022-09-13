--Trace activity from IMSP

select distinct action, action_name from dba_audit_trail order by 2;
select * from dba_audit_trail fetch next 50 rows only;

select min(timestamp) from dba_audit_trail;
/*
select os_username, username, userhost, terminal --, count(*)
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 15) "Alter Table"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 7) "Delete"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 116) "Execute Proc"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 2) "Insert"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 100) "Logon"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 47) "Execute PL/SQL"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 3) "Select"
    , (select count(*) from dba_audit_trail
    where os_username = dat.os_username and username = dat.username 
    and userhost = dat.userhost         and terminal = dat.terminal 
    and timestamp > sysdate - 7         and action = 6) "Update"
from dba_audit_trail dat
where timestamp > sysdate - 1
--group by os_username, username, userhost, terminal;
order by  1, 2, 3;
*/
/*
15	ALTER TABLE
44	COMMIT
101	LOGOFF
102	LOGOFF BY CLEANUP
desc dba_audit_trail
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
*/
select min (from_tz(ntimestamp#,'00:00') at local) from sys.aud$;
select counT(*) from sys.aud$;
--create index 

select * 
  from dba_audit_trail 
 where timestamp between to_date('19-Jun-2019 23:20:00', 'DD-Mon-yyyy HH24:mi:ss') and to_date('19-Jun-2019 23:25:00', 'DD-Mon-yyyy HH24:mi:ss') 
;


select aud.spare1       "OS Username",
       aud.userid       "Username" ,
       aud.userhost     "User Host",
       aud.terminal     "Terminal",
        aud.action#     "Action #",
        act.name        "Action Name"
        , count(*)      "Act Count"
from sys.aud$ aud, audit_actions act
where  from_tz(ntimestamp#,'00:00') at local between to_date('12-Jun-2019 14:40:00', 'DD-MON-YYYY HH24:MI:SS') and to_date('12-Jun-2019 14:45:00', 'DD-MON-YYYY HH24:MI:SS')
--> ntimestamp# > sysdate -1
and aud.action#     = act.action    (+)
group by 
aud.spare1      ,
       aud.userid        ,
       aud.userhost     ,
       aud.terminal     ,
        aud.action#     ,
        act.name
order by 1, 2;