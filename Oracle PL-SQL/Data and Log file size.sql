SELECT  'Data' FileType, sum( bytes) /1024/1024 Mb
   FROM DBA_DATA_FILES
union 
select 'Log', sum(bytes)/1024/1024 from v$log
order by 1;

select sysdate from dual;