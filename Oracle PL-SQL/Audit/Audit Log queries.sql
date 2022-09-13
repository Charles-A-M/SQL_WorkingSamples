/*
 select * from dba_fga_audit_trail;
 select * from dba_audit_trail;
 select * from dba_audit_session;
*/

select aud.spare1           /* OS_USERNAME */,
       aud.userid           /* USERNAME */,
       aud.userhost         /* USERHOST */,
       aud.terminal         /* TERMINAL */,
       cast (           /* TIMESTAMP */
           (from_tz(aud.ntimestamp#,'00:00') at local) as date),
       aud.action#      /* ACTION */,
       act.name         /* ACTION_NAME */,
       from_tz(aud.ntimestamp#,'00:00') at local, /* EXTENDED_TIMESTAMP */
       to_nchar(substr(sqlbind,1,2000))       /* SQL_BIND */,
       to_nchar(substr(sqltext,1,2000))       /* SQL_TEXT */
from sys.aud$ aud, audit_actions act
where   aud.action#     = act.action    (+)
  ;
  
  

--1st 50 rows in 3.897 seconds. All 18,024 rows in 5.379 seconds.
audit policy ORA_LOGON_LOGOFF;
select * from v$option where PARAMETER = 'Unified Auditing'


CREATE AUDIT POLICY COD_Audit_Logon
ACTIONS logon;

AUDIT POLICY COD_Audit_Logon;

select * from v$option where PARAMETER = 'Unified Auditing'

grant select on dba_audit_session to sys;
--audit create session;
audit create session whenever successful ;
audit create session whenever not successful;
show parameter audit_file_dest */
  select  dbusername, userhost, terminal, os_username, client_program_name, sum(case when return_code = 0 then 1 else 0 end ) Succeed,  sum(case when return_code <> 0 then 1 else 0 end) Fail, count(*), min(event_timestamp), max(event_timestamp)
from unified_audit_trail
where action_name = 'LOGON'
group by userhost, terminal, dbusername, os_username, client_program_name
order by dbusername, nvl(userhost, terminal), nvl(terminal, userhost), os_username
  
  
  
  
--------------------------------------------------------
--  DDL for View DBA_AUDIT_TRAIL
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "SYS"."DBA_AUDIT_TRAIL" ("OS_USERNAME", "USERNAME", "USERHOST", "TERMINAL", "TIMESTAMP", "OWNER", "OBJ_NAME", "ACTION", "ACTION_NAME", "NEW_OWNER", "NEW_NAME", "OBJ_PRIVILEGE", "SYS_PRIVILEGE", "ADMIN_OPTION", "GRANTEE", "AUDIT_OPTION", "SES_ACTIONS", "LOGOFF_TIME", "LOGOFF_LREAD", "LOGOFF_PREAD", "LOGOFF_LWRITE", "LOGOFF_DLOCK", "COMMENT_TEXT", "SESSIONID", "ENTRYID", "STATEMENTID", "RETURNCODE", "PRIV_USED", "CLIENT_ID", "ECONTEXT_ID", "SESSION_CPU", "EXTENDED_TIMESTAMP", "PROXY_SESSIONID", "GLOBAL_UID", "INSTANCE_NUMBER", "OS_PROCESS", "TRANSACTIONID", "SCN", "SQL_BIND", "SQL_TEXT", "OBJ_EDITION_NAME", "DBID", "RLS_INFO", "CURRENT_USER") AS 
  select spare1           /* OS_USERNAME */,
       userid           /* USERNAME */,
       userhost         /* USERHOST */,
       terminal         /* TERMINAL */,
       cast (           /* TIMESTAMP */
           (from_tz(ntimestamp#,'00:00') at local) as date),
       obj$creator      /* OWNER */,
       obj$name         /* OBJECT_NAME */,
       aud.action#      /* ACTION */,
       act.name         /* ACTION_NAME */,
       new$owner        /* NEW_OWNER */,
       new$name         /* NEW_NAME */,
       decode(aud.action#,
              108 /* grant  sys_priv */, null,
              109 /* revoke sys_priv */, null,
              114 /* grant  role */, null,
              115 /* revoke role */, null,
              auth$privileges)
                        /* OBJ_PRIVILEGE */,
       decode(aud.action#,
              108 /* grant  sys_priv */, spm.name,
              109 /* revoke sys_priv */, spm.name,
              null)
                        /* SYS_PRIVILEGE */,
       decode(aud.action#,
              108 /* grant  sys_priv */, substr(auth$privileges,1,1),
              109 /* revoke sys_priv */, substr(auth$privileges,1,1),
              114 /* grant  role */, substr(auth$privileges,1,1),
              115 /* revoke role */, substr(auth$privileges,1,1),
              null)
                        /* ADMIN_OPTION */,
       auth$grantee     /* GRANTEE */,
       decode(aud.action#,
              104 /* audit   */, aom.name,
              105 /* noaudit */, aom.name,
              null)
                        /* AUDIT_OPTION  */,
       ses$actions      /* SES_ACTIONS   */,
       cast((from_tz(cast(logoff$time as timestamp),'00:00') at local) as date)
                        /* LOGOFF_TIME   */,
       logoff$lread     /* LOGOFF_LREAD  */,
       logoff$pread     /* LOGOFF_PREAD  */,
       logoff$lwrite    /* LOGOFF_LWRITE */,
       decode(aud.action#,
              104 /* audit   */, null,
              105 /* noaudit */, null,
              108 /* grant  sys_priv */, null,
              109 /* revoke sys_priv */, null,
              114 /* grant  role */, null,
              115 /* revoke role */, null,
              aud.logoff$dead)
                         /* LOGOFF_DLOCK */,
       comment$text      /* COMMENT_TEXT */,
       sessionid         /* SESSIONID */,
       entryid           /* ENTRYID */,
       statement         /* STATEMENTID */,
       returncode        /* RETURNCODE */,
       spx.name          /* PRIVILEGE */,
       clientid          /* CLIENT_ID */,
       auditid           /* ECONTEXT_ID */,
       sessioncpu        /* SESSION_CPU */,
       from_tz(ntimestamp#,'00:00') at local,
                                   /* EXTENDED_TIMESTAMP */
       proxy$sid                      /* PROXY_SESSIONID */,
       user$guid                           /* GLOBAL_UID */,
       instance#                      /* INSTANCE_NUMBER */,
       process#                            /* OS_PROCESS */,
       xid                              /* TRANSACTIONID */,
       scn                                        /* SCN */,
       to_nchar(substr(sqlbind,1,2000))      /* SQL_BIND */,
       to_nchar(substr(sqltext,1,2000))      /* SQL_TEXT */,
       obj$edition                   /* OBJ_EDITION_NAME */,
       dbid                                      /* DBID */,
       rls$info                       /* RLS information */,
       current_user                      /* Current User */
from sys.aud$ aud, system_privilege_map spm, system_privilege_map spx,
     STMT_AUDIT_OPTION_MAP aom, audit_actions act
where   aud.action#     = act.action    (+)
  and - aud.logoff$dead = spm.privilege (+)
  and   aud.logoff$dead = aom.option#   (+)
  and - aud.priv$used   = spx.privilege (+);

   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OS_USERNAME" IS 'Operating System logon user name of the user whose actions were audited';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."USERNAME" IS 'Name of the logged in user whose actions were audited';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."USERHOST" IS 'Client host machine name';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."TERMINAL" IS 'Identifier for the user''s terminal';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."TIMESTAMP" IS 'Date/Time of the creation of the audit trail entry (Date/Time of the user''s logon for entries created by AUDIT SESSION) in session''s time zone';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OWNER" IS 'Creator of object affected by the action';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OBJ_NAME" IS 'Name of the object affected by the action';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."ACTION" IS 'Numeric action type code.  The corresponding name of the action type (CREATE TABLE, INSERT, etc.) is in the column ACTION_NAME';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."ACTION_NAME" IS 'Name of the action type corresponding to the numeric code in ACTION';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."NEW_OWNER" IS 'The owner of the object named in the NEW_NAME column';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."NEW_NAME" IS 'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OBJ_PRIVILEGE" IS 'Object privileges granted/revoked by a GRANT/REVOKE statement';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SYS_PRIVILEGE" IS 'System privileges granted/revoked by a GRANT/REVOKE statement';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."ADMIN_OPTION" IS 'If role/sys_priv was granted WITH ADMIN OPTON, A/- or WITH DELEGATE OPTION, D/-';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."GRANTEE" IS 'The name of the grantee specified in a GRANT/REVOKE statement';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."AUDIT_OPTION" IS 'Auditing option set with the audit statement';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SES_ACTIONS" IS 'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."LOGOFF_TIME" IS 'Timestamp for user logoff';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."LOGOFF_LREAD" IS 'Logical reads for the session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."LOGOFF_PREAD" IS 'Physical reads for the session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."LOGOFF_LWRITE" IS 'Logical writes for the session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."LOGOFF_DLOCK" IS 'Deadlocks detected during the session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."COMMENT_TEXT" IS 'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SESSIONID" IS 'Numeric ID for each Oracle session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."ENTRYID" IS 'Numeric ID for each audit trail entry in the session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."STATEMENTID" IS 'Numeric ID for each statement run (a statement may cause many actions)';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."RETURNCODE" IS 'Oracle error code generated by the action.  Zero if the action succeeded';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."PRIV_USED" IS 'System privilege used to execute the action';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."CLIENT_ID" IS 'Client identifier in each Oracle session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."ECONTEXT_ID" IS 'Execution Context Identifier for each action';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SESSION_CPU" IS 'Amount of cpu time used by each Oracle session';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."EXTENDED_TIMESTAMP" IS 'Timestamp of the creation of audit trail entry (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."PROXY_SESSIONID" IS 'Proxy session serial number, if enterprise user has logged through proxy mechanism';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."GLOBAL_UID" IS 'Global user identifier for the user, if the user had logged in as enterprise user';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."INSTANCE_NUMBER" IS 'Instance number as specified in the initialization parameter file ''init.ora''';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OS_PROCESS" IS 'Operating System process identifier of the Oracle server process';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."TRANSACTIONID" IS 'Transaction identifier of the transaction in which the object is accessed or modified';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SCN" IS 'SCN (System Change Number) of the query';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SQL_BIND" IS 'Bind variable data of the query';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."SQL_TEXT" IS 'SQL text of the query';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."OBJ_EDITION_NAME" IS 'Edition containing audited object';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."DBID" IS 'Database Identifier of the audited database';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."RLS_INFO" IS 'RLS predicates along with the RLS policy names used for the object accessed';
   COMMENT ON COLUMN "SYS"."DBA_AUDIT_TRAIL"."CURRENT_USER" IS 'Effective user for the statement execution';
   COMMENT ON TABLE "SYS"."DBA_AUDIT_TRAIL"  IS 'All audit trail entries'
;





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
	
	
/*
CREATE AUDIT POLICY AUDIT_DB_SCHEMA_CHANGES
PRIVILEGES
CREATE EXTERNAL JOB, CREATE JOB, CREATE ANY JOB
ACTIONS 
CREATE PACKAGE, ALTER PACKAGE, DROP PACKAGE, 
CREATE PACKAGE BODY, ALTER PACKAGE BODY, DROP PACKAGE BODY,
CREATE PROCEDURE, DROP PROCEDURE, ALTER PROCEDURE,
CREATE FUNCTION, DROP FUNCTION, ALTER FUNCTION,
CREATE TRIGGER, ALTER TRIGGER, DROP TRIGGER,
CREATE LIBRARY, ALTER LIBRARY, DROP LIBRARY,
CREATE SYNONYM, DROP SYNONYM, ALTER SYNONYM,
CREATE TABLE, ALTER TABLE, DROP TABLE, TRUNCATE TABLE,
CREATE DATABASE LINK, ALTER DATABASE LINK, DROP DATABASE LINK,
CREATE INDEX, ALTER INDEX, DROP INDEX,
CREATE INDEXTYPE, ALTER INDEXTYPE, DROP INDEXTYPE,
CREATE OUTLINE, ALTER OUTLINE, DROP OUTLINE,
CREATE CONTEXT, DROP CONTEXT,
CREATE ATTRIBUTE DIMENSION, ALTER ATTRIBUTE DIMENSION, DROP ATTRIBUTE DIMENSION,
CREATE DIMENSION, ALTER DIMENSION, DROP DIMENSION,
CREATE MINING MODEL, ALTER MINING MODEL, DROP MINING MODEL,
CREATE OPERATOR, ALTER OPERATOR, DROP OPERATOR,
CREATE JAVA, ALTER JAVA, DROP JAVA,
CREATE TYPE BODY, ALTER TYPE BODY, DROP TYPE BODY,
CREATE TYPE, ALTER TYPE, DROP TYPE,
CREATE VIEW, ALTER VIEW, DROP VIEW, 
CREATE MATERIALIZED VIEW, ALTER MATERIALIZED VIEW, DROP MATERIALIZED VIEW,
CREATE MATERIALIZED VIEW LOG, ALTER MATERIALIZED VIEW LOG, DROP MATERIALIZED VIEW LOG,
CREATE MATERIALIZED ZONEMAP, ALTER MATERIALIZED ZONEMAP, DROP MATERIALIZED ZONEMAP,
CREATE ANALYTIC VIEW, ALTER ANALYTIC VIEW, DROP ANALYTIC VIEW,
CREATE SEQUENCE, ALTER SEQUENCE, DROP SEQUENCE,
CREATE CLUSTER, ALTER CLUSTER, DROP CLUSTER, TRUNCATE CLUSTER;
AUDIT POLICY AUDIT_DB_SCHEMA_CHANGES;

audit policy ORA_LOGON_FAILURES;
audit policy ORA_SECURECONFIG;
audit policy ORA_ACCOUNT_MGMT;
audit policy ORA_LOGON_LOGOFF;
commit;

*/