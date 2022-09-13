-- https://mathijsbruggink.com/2013/10/24/sending-mail-from-an-11g-oracle-database-utl_smtp/ 
-- http://amitpawardba.blogspot.com/2015/02/enable-oracle-database-to-send-emails.html
/*
sqlplus /nolog
connect / as sysdba
@?/rdbms/admin/utlmail.sql
@?/rdbms/admin/prvtmail.plb
grant execute on utl_mail to public;
alter system set smtp_out_server = 'smtp.example.com:25' scope=both;
*/



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
    p_sender => 'ora11gtest@example.com',
    p_recipients => 'charles.moore@example.com',
    p_subject => 'This is the subject line!',
    p_message => 'Hello World!');
end;