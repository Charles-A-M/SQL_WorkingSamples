--https://stackoverflow.com/questions/41976094/oracle-audit-trail-for-a-specific-user

select * from all_users; --SRVCCITYOFDAYTON, SRVCHANSEN, WRSINTERFACE
--WtrHansen-Test 

Audit all by WRSINTERFACE by access;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE, DELETE TABLE BY WRSINTERFACE BY ACCESS;
AUDIT EXECUTE PROCEDURE BY WRSINTERFACE BY ACCESS;

--Audit records can be found in DBA_AUDIT_TRAIL view.Following query list all audit related views.

--SQL>SELECT view_name FROM dba_views WHERE view_name LIKE 'DBA%AUDIT%';

select * from dba_audit_trail;

