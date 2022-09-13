-- http://www.dba-oracle.com/t_sql_redo_log_switch_reports.htm
-- log size and details:
select * from v$log;
select bytes / 1024 / 1024 MB from v$log;

-- Log switch frequency report
set lines 120;
set pages 999;
SELECT
to_char(first_time,'YYYY-MM-DD') day,
to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'99') "00",
to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'99') "01",
to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'99') "02",
to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'99') "03",
to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'99') "04",
to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'99') "05",
to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'99') "06",
to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'99') "07",
to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'99') "0",
to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'99') "09",
to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'99') "10",
to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'99') "11",
to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'99') "12",
to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'99') "13",
to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'99') "14",
to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'99') "15",
to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'99') "16",
to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'99') "17",
to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'99') "18",
to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'99') "19",
to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'99') "20",
to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'99') "21",
to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'99') "22",
to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'99') "23"
from  v$log_history
GROUP by to_char(first_time,'YYYY-MM-DD')
order by 1;

select * from v$log_history order by first_time desc;



-- redo log status, shows when switches occured.
rem
rem Name:     log_stat.sql
rem
rem FUNCTION: Provide a current status for redo logs
rem
rem
COLUMN first_change# FORMAT 9999999999  HEADING Change#
COLUMN group#        FORMAT 9,999     HEADING Grp#
COLUMN thread#       FORMAT 999       HEADING Th#
COLUMN sequence#     FORMAT 999,999   HEADING Seq#
COLUMN members       FORMAT 999       HEADING Mem
COLUMN archived      FORMAT a4        HEADING Arc?
COLUMN first_time    FORMAT a21       HEADING 'Switch|Time'
BREAK ON thread#
SET PAGES 60 LINES 131 FEEDBACK OFF
START title132 'Current Redo Log Status'
SPOOL c:\temp\logStatus.txt
SELECT thread#,group#,sequence#,bytes,bytes/1024/1024 MB,
       members,archived,
       status,first_change#,
       TO_CHAR(first_time, 'DD-MM-YYYY HH24:MI:SS') first_time
  FROM
       sys.v_$log
  ORDER BY
       thread#,
       group#;
SPOOL OFF
PAUSE Press Enter to continue
SET PAGES 22 LINES 80 FEEDBACK ON
CLEAR BREAKS
CLEAR COLUMNS
TTILE OFF


REM NAME         :log_hist.sql
REM PURPOSE      :Provide info on logs for last 24 hours since last
REM PURPOSE      :log switch
REM USE          :From SQLPLUS
REM Limitations  : None
REM MRA 10/14/01 Updated for Oracle9i
REM
COLUMN thread#             FORMAT 999      HEADING 'Thrd#'
COLUMN sequence#           FORMAT 99999    HEADING 'Seq#'
COLUMN first_change#                       HEADING 'SCN Low#'
COLUMN next_change#                        HEADING 'SCN High#'
COLUMN archive_name        FORMAT a50      HEADING 'Log File'
COLUMN first_time          FORMAT a20      HEADING 'Switch Time'
COLUMN name                FORMAT a30      HEADING 'Archive Log'

SET LINES 132 FEEDBACK OFF VERIFY OFF
START title132 "Log History Report"
SPOOL c:\temp\log_hist.txt
REM
SELECT
     X.recid,a.thread#,
     a.sequence#,a.first_change#,
     a.switch_change#,
     TO_CHAR(a.first_time,'DD-MON-YYYY HH24:MI:SS') first_time,x.name
FROM
v$loghist a, v$archived_log x
WHERE
  a.first_time>
   (SELECT b.first_time-1
   FROM v$loghist b WHERE b.switch_change# =
    (SELECT MAX(c.switch_change#) FROM v$loghist c)) AND
     x.recid(+)=a.sequence#;
SPOOL OFF
SET LINES 80 VERIFY ON FEEDBACK ON
CLEAR COLUMNS
TTITLE OFF
PAUSE Press Enter to continue


REM
REM NAME          : rdo_stat.sql
REM PURPOSE       : Show REDO latch statistics
REM USE           : from SQLPlus
REM Limitations   : Must have access to v$_ views
REM
SET PAGES 56 LINES 78 VERIFY OFF FEERemote DBACK OFF
START title80 "Redo Latch Statistics"
SPOOL c:\temp\redo_stats.txt
rem
COLUMN name      FORMAT a30          HEADING Name
COLUMN percent   FORMAT 999.999      HEADING Percent
COLUMN total                         HEADING Total
rem
SELECT
     l2.name,
     immediate_gets+gets Total,
     immediate_gets "Immediates",
     misses+immediate_misses "Total Misses",
     DECODE (100.*(GREATEST(misses+immediate_misses,1)/
     GREATEST(immediate_gets+gets,1)),100,0) Percent
FROM
  v$latch l1,
     v$latchname l2
WHERE
     l2.name like '%redo%'
     and l1.latch#=l2.latch# ;
rem
PAUSE Press Enter to continue
rem
rem Name: Redo_stat.sql
rem
rem Function: Select redo statistics from v$sysstat

COLUMN name    FORMAT a30         HEADING 'Redo|Statistic|Name'
COLUMN value   FORMAT 999,999,999 HEADING 'Redo|Statistic|Value'
SET PAGES 80 LINES 60 FEERemote DBACK OFF VERIFY OFF
START title80 'Redo Log Statistics'
SPOOL c:\temp\redo_stat2.txt
SELECT
     name,
     value
FROM
     v$sysstat
WHERE
     name LIKE '%redo%'
ORDER BY statistic#;
SPOOL OFF
SET LINES 24 FEERemote DBACK ON VERIFY ON
TTITLE OFF
CLEAR COLUMNS
CLEAR BREAKS