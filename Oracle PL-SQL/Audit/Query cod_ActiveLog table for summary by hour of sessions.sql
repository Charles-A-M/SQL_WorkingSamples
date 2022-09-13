 select username, osuser, machine, terminal, module, min(logon_time) FirstDate, max(logon_time) LastDate, count(*) LoginCount
  from sys.cod_activelog
  where osuser not in ('NT AUTHORITY\SYSTEM', 'charles.moore', 'SYSTEM')
   and module not in ('rman.exe', 'DBMS_SCHEDULER', 'OEM.SystemPool', 'expdp.exe', 'Data Pump Master', 'Data Pump Worker', 'OEM')
   and userName not in ('DBSNMP')
   and program not in ('rman.exe')
group by username, osuser, machine, terminal, module
order by username, osuser, machine, terminal, module
   ;
 
 
 --   NOTE:  change sys. to system. for OM and PACS
 --pivot to weekdays as column headers, detailed minutes (actual capture time)
 Select *
   From
       (
       select substr(to_char(collectdate, 'DAY'),1,3) Dy, to_char(collectdate, 'HH24:MI')   Hr, count(*) Cnt
         from sys.cod_activelog
        where lower(machine) not in ('wtrora12ps', 'wtr320msdncm', 'wtroracle')   --remove Oracle and system monitoring processes
        group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24:MI')
       )
pivot (Avg(Cnt) for Dy in ('MON','TUE', 'WED', 'THU', 'FRI'))
order by hr;
--
--
-- try to summarize minutes down to hours.
 Select *
   From
       (
       Select Dy, Substr(Hr, 1,2) || ':00' Hr, Round(Avg(Cnt),1) AvgCnt
         From (
              select substr(to_char(collectdate, 'DAY'),1,3) Dy, to_char(collectdate, 'HH24:MI')  Hr, count(*) Cnt
                from sys.cod_activelog
               where lower(machine) not in ('wtrora12ps', 'wtr320msdncm', 'wtroracle')   --remove Oracle and system monitoring processes
               group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24:MI')
              )
        group by Dy, Substr(Hr, 1,2) 
        )
pivot (Avg(AvgCnt) for Dy in ('MON','TUE', 'WED', 'THU', 'FRI'))
order by hr;


/*
--query used to insert into sys.cod_activeLog : 

select  sess.sid, sess.serial#, sess.UserName, sess.status, sess.schemaname, sess.osuser, sess.machine, sess.terminal, 
       sess.program, sess.type, sess.module, sess.action, sess.logon_time, sess.blocking_session_status, sess.blocking_instance, sess.blocking_session,
       sess.event, sess.state, sess.service_name, sess.external_name,
       sqa.cpu_time, sqa.elapsed_time, sqa.sql_text
  from v$session sess
  left join v$sqlarea sqa on sqa.hash_value = sess.sql_hash_value and sqa.address = sess.sql_address
  where sess.username is not null and machine <> 'wtrora12ps'
  order by username, sid;
  
  
  
   select substr(to_char(collectdate, 'DAY'),1,3) Dy, to_char(collectdate, 'HH24:MI')  Hr, count(*) Cnt
         from sys.cod_activelog
        where lower(machine) not in ('wtrora12ps', 'wtr320msdncm')   --remove Oracle and system monitoring processes
        group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24:MI') 
        order by 1, 2;
  
  
  
 select * from sys.cod_activeLog where collectDate > to_date('11-Sep-2017 10:00', 'DD-MON-YYYY HH24:MI')
 order by 2
*/