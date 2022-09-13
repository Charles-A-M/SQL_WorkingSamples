select *
  from cod_activelog
  where osuser not in ('NT AUTHORITY\SYSTEM', 'charles.moore', 'SYSTEM')
   and module not in ('rman.exe', 'DBMS_SCHEDULER', 'OEM.SystemPool')
   and program not in ('rman.exe')
   
   
   select distinct machine
  from cod_activelog
  where osuser not in ('NT AUTHORITY\SYSTEM', 'charles.moore', 'SYSTEM')
   and module not in ('rman.exe', 'DBMS_SCHEDULER', 'OEM.SystemPool')
   and program not in ('rman.exe')
   order by 1
   
   
   
   select cast('<SERVER>' as varchar2(255)) Server, 'Completed' Status, count(Full_Tape) Full_Tape, 
  count(Full_Disk) Full_Disk, 
  count(Inc_Tape) Inc_Tape, count(Inc_Disk) Inc_Disk, count(log_Tape) log_Tape, count(log_Disk) log_Disk
  from (
    select 
      case when (Input_Type = 'DB FULL' and output_device_type = 'SBT_TAPE') then status else null end Full_Tape,
      case when (Input_Type = 'DB FULL' and output_device_type = 'DISK') then status else null end Full_Disk,
      case when (Input_Type = 'DB INCR' and output_device_type = 'SBT_TAPE') then status else null end Inc_Tape,
      case when (Input_Type = 'DB INCR' and output_device_type = 'DISK') then status else null end Inc_Disk,
      case when (Input_Type = 'ARCHIVELOG' and output_device_type = 'SBT_TAPE') then status else null end log_Tape,
      case when (Input_Type = 'ARCHIVELOG' and output_device_type = 'DISK') then status else null end log_Disk
    from v$rman_backup_job_details 
    where end_time > sysdate - 2
    and input_type <> 'RECVR AREA'
    and status = 'COMPLETED'
   )
 union
 select '<SERVER>', 'Failed', count(Full_Tape), count(Full_Disk), count(Inc_Tape), count(Inc_Disk), count(log_Tape), count(log_Disk)
   from (
     select 
      case when (Input_Type = 'DB FULL' and output_device_type = 'SBT_TAPE') then status else null end Full_Tape,
      case when (Input_Type = 'DB FULL' and output_device_type = 'DISK') then status else null end Full_Disk,
      case when (Input_Type = 'DB INCR' and output_device_type = 'SBT_TAPE') then status else null end Inc_Tape,
      case when (Input_Type = 'DB INCR' and output_device_type = 'DISK') then status else null end Inc_Disk,
      case when (Input_Type = 'ARCHIVELOG' and output_device_type = 'SBT_TAPE') then status else null end log_Tape,
      case when (Input_Type = 'ARCHIVELOG' and output_device_type = 'DISK') then status else null end log_Disk
     from v$rman_backup_job_details 
     where end_time > sysdate - 2
     and input_type <> 'RECVR AREA'
     and status = 'FAILED'
    )
order by 2;







/*
-- collectdate, osuser, machine, terminal, program

       select distinct (machine )
         from sys.cod_activelog
        where lower(machine) <> 'wtrora12ps'   --program not in ('ORACLE.EXE (J001)')
          and to_char(collectdate, 'DAY') not in ('SUNDAY', 'SATURDAY')
        group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24')



select dy, hr, avg(cnt)
  from (
       select to_char(collectdate, 'DAY') Dy, to_char(collectdate, 'HH24') Hr, count(*) Cnt
         from sys.cod_activelog
        where lower(machine) <> 'wtrora12ps'   --program not in ('ORACLE.EXE (J001)')
          and to_char(collectdate, 'DAY') not in ('SUNDAY', 'SATURDAY')
        group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24')
       )
  group by dy, hr
  order by 1, 2
 ;
 */
 --pivot to weekdays as column headers
 Select * From
       (
       select substr(to_char(collectdate, 'DAY'),1,3) Dy, to_char(collectdate, 'HH24') || ':00'  Hr, count(*) Cnt
         from sys.cod_activelog
        where lower(machine) not in ('wtrora12ps', 'wtr320msdncm')   --remove Oracle and system monitoring processes
        group by to_char(collectdate, 'DAY') , to_char(collectdate, 'HH24')
       )
pivot (Avg(Cnt) for Dy in ('MON','TUE', 'WED', 'THU', 'FRI'))
order by hr;