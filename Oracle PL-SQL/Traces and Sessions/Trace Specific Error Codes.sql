--http://www.oracle-scripts.net/trace-a-specific-ora-error/
alter system set events '900 trace name ERRORSTACK level 3';
alter system set events '946 trace name ERRORSTACK level 3';
alter system set events '942 trace name ERRORSTACK off'
--alter system set events '900 trace name ERRORSTACK off';
