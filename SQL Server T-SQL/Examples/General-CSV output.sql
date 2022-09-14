 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --		1.	Generate comma-separated list as output from Select statement
			-- https://dba.stackexchange.com/questions/207371/please-explain-what-does-for-xml-path-type-value-nvarcharmax

			-- a.	Older method
			Select STUFF(
				/* The STUFF function inserts a string into another string.  */
				(
					/*	-- t.Name TableName, c.column_id, c.name ColumnName, ty.name TypeName
							Base query that returns columns and rows.
							Convert it such that it's a single column, comma separated.
							prepend an extra ,.
					*/
					select top 20	
						', ' + t.Name + ',' + cast(c.column_id as varchar) + ',' + c.name + ',' + ty.name
					from sys.tables				t
					inner join sys.all_columns	c	on c.object_id = t.object_id
					inner join sys.types		ty	on ty.user_type_id = c.user_type_id
					where is_ms_shipped = 0
					order by t.Name, c.column_id
					FOR XML PATH (''), TYPE
					/* For XML Path converts rows/cols into XMLfragment of <column name>column value</column name>. 
						The ('') is the row XML key, so no row elements. Change '' to ('Fred') to enclose each row in <Fred></Fred> elements.
						change ", TYPE" to "root('Bob')" to enclose the XML in <Bob></Bob> element.
						<TableName>Alerts</TableName><column_id>1</column_id><ColumnName>AlertID</ColumnName><TypeName>numeric</TypeName>
						<TableName>Alerts</TableName><column_id>2</column_id><ColumnName>AlertTime</ColumnName><TypeName>datetime2</TypeName>
					*/
			).value('.', 'NVARCHAR(MAX)'), 1, 2, '');
			/*   the . is an xQuery expression representing current node (the only node here).
				'(./text())[1]'     is faster for larger data sets. 
				The 1, 2, '' strips the leading , from the string.
			*/
				
			-- b. Newer method.
				/* in SQL 2017+, use STRING_AGG instead. Easier to read. */
				with cte as (
					/* Need a CTE, because we can't sort without it. */
					select top 20	
						t.Name + ',' + cast(c.column_id as varchar) + ',' + c.name + ',' + ty.name col1
					from sys.tables				t
					inner join sys.all_columns	c	on c.object_id = t.object_id
					inner join sys.types		ty	on ty.user_type_id = c.user_type_id
					where is_ms_shipped = 0
					order by t.Name, c.column_id
				)
				Select STRING_AGG(col1, ',')
				from cte;
