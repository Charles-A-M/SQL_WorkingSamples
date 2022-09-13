select *
  from system.cod_activelog
  where osuser not in ('NT AUTHORITY\SYSTEM', 'charles.moore', 'SYSTEM')
   and module not in ('rman.exe', 'DBMS_SCHEDULER', 'OEM.SystemPool')
   and program not in ('rman.exe')