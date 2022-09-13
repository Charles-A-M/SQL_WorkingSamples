set head off;
set pages 50000;
set long 999999;
select 'set head off;           --', 1 from dual
union select 'set pages 50000;  --', 2 from dual
union select 'set long 999999;  --', 3 from dual
union
select  'select dbms_metadata.get_ddl(''USER'', ''' ||  username || ''') || '' container=current;'' from dual;  -- ', 10 from all_users where Oracle_maintained='N'
--union select  'select ''Commit ;'' from dual;   -- ', 15 from dual
union
select  'select dbms_metadata.get_ddl(''ROLE'', ''' ||  role || ''') || '' container=current;'' from dual;      -- ', 20 from dba_roles where Oracle_maintained='N'
--union select  'select ''Commit ;'' from dual;   -- ', 25 from dual
union
select  'SELECT DBMS_METADATA.GET_GRANTED_DDL(''ROLE_GRANT'',''' || username || ''') || '';'' FROM DUAL;        -- ', 30 from all_users where Oracle_maintained='N'
--union select  'select ''Commit ;'' from dual;   -- ', 35 from dual
union
select  'SELECT DBMS_METADATA.GET_GRANTED_DDL(''SYSTEM_GRANT'',''' || username || ''') || '';'' FROM DUAL;      -- ', 40 from all_users where Oracle_maintained='N'
--union select  'select ''Commit ;'' from dual;   -- ', 45 from dual
union
select  'SELECT DBMS_METADATA.GET_GRANTED_DDL(''OBJECT_GRANT'',''' || username || ''') || '';'' FROM DUAL;      -- ', 50 from all_users where Oracle_maintained='N'
--union select  'select ''Commit ;'' from dual;   -- ', 55 from dual
order by 2, 1 ;
/*


*/
--select dbms_metadata.get_ddl('USER', 'WRSINTERFACE') || ';' from dual;
/* */

