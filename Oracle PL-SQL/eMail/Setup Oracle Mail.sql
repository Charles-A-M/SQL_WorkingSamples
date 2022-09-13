-- set up Oracle Mail:

ALTER SYSTEM SET smtp_out_server='smtp.example.com' SCOPE=both;
@$ORACLE_HOME/rdbms/admin/utlmail.sql
@$ORACLE_HOME/rdbms/admin/prvtmail.plb

	exec DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('send_mail.xml','Allow mail to be send', 'OLDSYSTEM', TRUE, 'connect');
	commit;
	-- Grant the connect and resource privilege as below
	exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('send_mail.xml','OLDSYSTEM',TRUE, 'connect');
	exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('send_mail.xml','OLDSYSTEM',TRUE, 'resolve');
	exec DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('send_mail.xml','*',25);
	
	
--test oracle mail
begin
  utl_mail.send( sender => 'imsp@daytonohio.gov',
        recipients => 'charles.moore@daytonohio.gov',
        subject => 'Testing Oracle Mail',
        message => 'If you get this message, then Oracle mail system is working.');
end;
/


BEGIN
      DBMS_SCHEDULER.set_scheduler_attribute('email_server', 'smtp.example.com:25');
      DBMS_SCHEDULER.set_scheduler_attribute('email_sender', 'me@example.com');
END;
/