--users seen in tkprof data:
select distinct tt.user_id, username
from tkprof_table2 tt
inner join dba_users du on du.user_id = tt.user_id
order by 2;

--slowest
Select parse_elap * 0.000001 "Parse", 
       exe_elap * 0.000001 "Exec", 
       fetch_elap * 0.000001 "Fetch", 
       (parse_elap + exe_elap + fetch_elap) * 0.000001 "Total", 
       du.username, 
       replace(replace(to_char(dbms_lob.substr(sql_statement, 4000)), chr(13), ' '), chr(10), ' ') SqlStatement, 
       length(sql_statement) "Sql Length"
 from tkprof_table2 tt
 inner join dba_users du on du.user_id = tt.user_id
where tt.user_id not in (134, 131, 0) --SRVCSOLARWINDS, BACKUPUSER, sys
order by 4 desc
fetch next 100 rows only;

--most run
Select avg(parse_elap) * 0.000001 "AvgParse", 
       avg(exe_elap) * 0.000001   "AvgExec", 
       avg(fetch_elap) * 0.000001 "AvgFetch", 
       avg(Total_elap) * 0.000001 "AvgTotal",
       Username,
       sql_statement,
       count(*) "Sql Count"
    from (
        Select parse_elap,
            exe_elap,
            fetch_elap, 
            parse_elap + exe_elap + fetch_elap Total_elap, 
            UserName,
            replace(replace(to_char(dbms_lob.substr(sql_statement, 4000)), chr(13), ' '), chr(10), ' ')  sql_statement
         from tkprof_table2 tt
        inner join dba_users du on du.user_id = tt.user_id
        where tt.user_id not in (134, 131, 0) --SRVCSOLARWINDS, BACKUPUSER, sys
    ) n
 group by username, sql_statement
order by 7 desc
fetch next 100 rows only;

--longest query length
Select avg(parse_elap) * 0.000001 "Parse", 
       avg(exe_elap) * 0.000001 "Exec", 
       avg(fetch_elap) * 0.000001 "Fetch", 
       avg(Total_elap) * 0.000001 "Total",
       avg(sqlLength) AvgSqlLength,
       username,
       sql_statement,
       count(*) "SqlCount"
  from (
        Select parse_elap,
            exe_elap,
            fetch_elap, 
            parse_elap + exe_elap + fetch_elap Total_elap, 
            length(sql_statement) SqlLength,
            Username,
            replace(replace(to_char(dbms_lob.substr(sql_statement, 4000)), chr(13), ' '), chr(10), ' ')  sql_statement
        from tkprof_table2 tt
        inner join dba_users du on du.user_id = tt.user_id
        where tt.user_id not in (134, 131, 0) --SRVCSOLARWINDS, BACKUPUSER, sys
    ) n
 group by username, sql_statement
 order by  avg(sqlLength) desc
 fetch next 100 rows only;
