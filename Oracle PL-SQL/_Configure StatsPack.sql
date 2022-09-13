-- http://www.oracledistilled.com/oracle-database/performance/installing-and-configuring-statspack/


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
 
 
 /*
 https://www.akadia.com/services/ora_statspack_survival_guide.html
 */