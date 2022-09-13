/*
-- https://mathijsbruggink.com/2013/10/24/sending-mail-from-an-11g-oracle-database-utl_smtp/ 
-- http://amitpawardba.blogspot.com/2015/02/enable-oracle-database-to-send-emails.html

sqlplus /nolog
connect / as sysdba
@?/rdbms/admin/utlmail.sql
@?/rdbms/admin/prvtmail.plb
grant execute on utl_mail to public;
alter system set smtp_out_server = 'smtp.daytonohio.gov:25' scope=both;

-- Create an ACL with one database user in Oracle database
BEGIN
   DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl          => 'mail_access.xml',
    description  => 'Permissions to access e-mail server.',
    principal    => 'PUBLIC',
    is_grant     => TRUE,
    privilege    => 'connect');
   COMMIT;
END;
 
 -- Assign an ACL to one or more network hosts
BEGIN
   DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl          => 'mail_access.xml',
    host         => 'smtp@example.com',
    lower_port   => 25,
    upper_port   => 25
    );
   COMMIT;
END;
 
-- Confirm the created ACL is correct
SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls
/
 
SELECT acl,
principal,
privilege,
is_grant,
TO_CHAR(start_date, 'DD-MON-YYYY HH24:MI') AS start_date,
TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM   dba_network_acl_privileges
/


CREATE OR REPLACE PROCEDURE SEND_MAIL (
   p_sender       IN   VARCHAR2,
   p_recipients   IN   VARCHAR2,
   p_cc           IN   VARCHAR2 DEFAULT NULL,
   p_bcc          IN   VARCHAR2 DEFAULT NULL,
   p_subject      IN   VARCHAR2,
   p_message      IN   VARCHAR2,
   p_mime_type    IN   VARCHAR2 DEFAULT 'text/plain; charset=us-ascii'
)
IS
 BEGIN
   UTL_MAIL.SEND (sender          => p_sender,
                  recipients      => p_recipients,
                  cc              => p_cc,
                  bcc             => p_bcc,
                  subject         => p_subject,
                  message         => p_message,
                  mime_type       => p_mime_type
                 );
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END send_mail;
/

Begin
  send_mail(
    p_sender => 'ora11gtest@daytonohio.gov',
    p_recipients => 'charles.moore@daytonohio.gov',
    p_subject => 'This is the subject line!',
    p_message => 'Hello World!');
end;


ALTER DATABASE  SET TIME_ZONE = 'US/Eastern' 



Create Tablespace StatsPack_Data
 datafile 'O:\ORADATA\IMSP\statspack_data_01.dbf' size 500M
  autoextend on maxsize 2G
  extent management local uniform size 1M
  segment space management auto;
  

BEGIN
  DBMS_SCHEDULER.CREATE_SCHEDULE(
    schedule_name => 'perfstat.statspack_every_20_min',
    repeat_interval => 'FREQ=MINUTELY;BYMINUTE=10,30,50' );
    
    DBMS_SCHEDULER.CREATE_JOB (
      job_name => 'perfstat.sp_snapshot',
      job_type => 'STORED_PROCEDURE',
      job_action => 'perfstat.statspack.snap',
      schedule_name => 'perfstat.statspack_every_20_min',
      comments => 'Statspack collection. http://www.oracledistilled.com/oracle-database/performance/installing-and-configuring-statspack/');
    
    DBMS_SCHEDULER.ENABLE('perfstat.sp_snapshot');
 END;
 /
 -- scheduler help: http://www.apex-at-work.com/2009/06/dbmsscheduler-examples.html
 BEGIN
  DBMS_SCHEDULER.CREATE_SCHEDULE(
    schedule_name => 'perfstat.sunday',
    start_date=> trunc(sysdate)+18/24,
    repeat_interval=> 'FREQ=DAILY; BYDAY=SUN; BYHOUR=20;',
    comments=>'Runtime: Run at 8pm every Sunday');

    DBMS_SCHEDULER.CREATE_JOB (
      job_name => 'perfstat.purge_old_data',
      job_type => 'PLSQL_BLOCK',
      job_action => 'exec perfstat.statspack.purge(i_num_days=>;28,i_extended_purge=>;TRUE);',
      schedule_name => 'perfstat.sunday',
      comments => 'Statspack collection. http://www.thebambers.me.uk/oracle/?p=175');
    
    DBMS_SCHEDULER.ENABLE('perfstat.purge_old_data');
 END;
 /
 
 */
 
 
 select 
   (select username from v$session where sid=a.sid) blocker,
   a.sid,
   ' is blocking ',
   (select username from v$session where sid=b.sid) blockee,
   b.sid
from 
   v$lock a, 
   v$lock b
where 
   a.block = 1
and 
   b.request > 0
and 
   a.id1 = b.id1
and 
   a.id2 = b.id2;
   


select
   c.owner,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.osuser,
   b.machine
from
--  see code depot for full locking script 
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;





select * from v$locked_object;