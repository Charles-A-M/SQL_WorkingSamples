--https://oracle-base.com/articles/8i/tkprof-and-oracle-trace

--turn on timed stats.
ALTER SYSTEM SET TIMED_STATISTICS = TRUE scope=both;

--Start the trace.
select systimestamp from dual;
ALTER SYSTEM SET SQL_TRACE = TRUE;   --started 23-OCT-18 11.20.04.482000000 AM -04:00

--Stop the trace.
ALTER SYSTEM SET SQL_TRACE = FALSE;  --stopped 23-OCT-18 11.35.12.585000000 AM -04:00
select systimestamp from dual;

/*
CMD.
Go to the DB's trace folder.
cd C:\Oracle\diag\rdbms\IPSDev01\ipsdev01\trace
make a folder and copy all .trc and .trm files generated between the above two dates into this folder.
CD to that folder.

-- Convert trace files to sql files
forfiles /m *.trc /c "cmd /c tkprof @file @file.txt insert=@file.sql"

--merge sql files
forfiles /m *.sql /c "cmd /c type @file >> all.sql"


edit the all.sql file to remove duplicate Create Table blocks.
Execute SQL to insert the rows into tkprof_table

 */
 


/*
 -- list events that are actively being traced? Maybe?
declare
  event_level number;
begin
  for i in 100..10999 loop
     sys.dbms_system.read_ev (i, event_level);
     if ( event_level > 0 ) then
        dbms_output.put_line ('Event '||to_char(i)||' set at level '||
                              to_char(event_level));
     end if;
 end loop;
end;
/
*/
