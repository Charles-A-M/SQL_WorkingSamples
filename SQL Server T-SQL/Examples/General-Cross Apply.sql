/*
CROSS APPLY

	Works similar to a join, but lets you join a table to a "table-valued function" 
	or to a subquery that refers to the outer query

OUTER APPLY
	Like an outer join to a table

	Table-Valued function is a functionat that returns a single set of data.
https://sqlhints.com/tag/examples-of-cross-apply/
*/

-- here we only want the 1st 2 columns for each table, so we apply a top 2 onto the cross applied table
--  making it a join of tables to a table expression for the columns.
Select SCHEMA_NAME(t.schema_id) SchemaName, t.name TableName, 
	   c.name ColName
  from sys.tables t
 cross apply (
		select top 2 *
		  from sys.all_columns col
		 where col.object_id = t.object_id
		   and col.is_hidden = 0
		 order by col.column_id) c
  where t.type = 'U'
 order by 1, 2, 3;

-- taking that 1 step further, here we get 1 row for each table,
-- and then the 1st two columns on that table.
Select SCHEMA_NAME(t.schema_id) SchemaName,t.name TableName, 
	   c1.name ColName1, c2.name ColName2
  from sys.tables t
 cross apply (
		select top 1 *
		  from sys.all_columns col1
		 where col1.object_id = t.object_id
		   and col1.is_hidden = 0
		 order by col1.column_id) c1
  cross apply (
		select top 1 *
		  from sys.all_columns col2
		 where col2.object_id = t.object_id
		   and col2.is_hidden = 0
		   and col2.column_id <> 1
		 order by col2.column_id) c2
  where t.type = 'U'
 order by 1, 2