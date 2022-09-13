--
-- Find schema information based on Column names
--
select owner, table_name, column_name, data_type 
from all_tab_cols
where column_name like '%INSTDATE%'
and owner  in (
    select username from all_users
    where oracle_maintained='N'
    and username not in ('PERFSTAT', 'SCOTT', 'TSMSYS', 'OWBSYS', 'SYSMAN', 'AUDSYS' ,'CTXSYS', 'OWBSYS_AUDIT'))
order by owner, table_name, column_name

--
-- find schema information based on table names
--
select tablespace_name, owner, table_name 
from all_tables where owner in (
    select username from all_users
     where oracle_maintained='N'
       and username not in ('PERFSTAT', 'SCOTT', 'TSMSYS', 'OWBSYS', 'SYSMAN', 'AUDSYS' ,'CTXSYS', 'OWBSYS_AUDIT'))
--where TABLE_NAME like '%PIPE%'
order by owner, table_name

--
-- Find non-Oracle users
--
select username from all_users
 where oracle_maintained='N'
   and username not in ('PERFSTAT', 'SCOTT', 'TSMSYS', 'OWBSYS', 'SYSMAN', 'AUDSYS', 'CTXSYS', 'OWBSYS_AUDIT')
 order by 1
 
 --
 -- Find Foreign Key references
 --
     
select * 
from all_constraints 
where r_constraint_name in
    (select constraint_name
    from all_constraints
    where table_name='%BLAH%') ;