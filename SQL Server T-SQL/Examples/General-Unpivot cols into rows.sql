 THROW 51000, 'Why are you here?', 1;  
 /*  ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --			Unpivot turns columns into rows.
 
			https://docs.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver16
			You can use the PIVOT and UNPIVOT relational operators to change a table-valued expression into another table. 
			PIVOT rotates a table-valued expression by turning the unique values from one column in the expression into multiple columns in the output. 
			And PIVOT runs aggregations where they're required on any remaining column values that are wanted in the final output. 
			UNPIVOT carries out the opposite operation to PIVOT by rotating columns of a table-valued expression into column values.
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   */
 
			CREATE OR ALTER FUNCTION dbo.GenerateUnpivotSql (@Sql NVARCHAR(MAX))
			RETURNS NVARCHAR(MAX) AS
				/* https://michaeljswart.com/2022/09/this-function-generates-unpivot-syntax/
					declare @sql nvarchar(max) ='SELECT * FROM sys.databases WHERE database_id = 2';
					declare @newsql nvarchar(max) = dbo.GenerateUnpivotSql (@sql);
					exec sp_executesql @sql;
					exec sp_executesql @newsql;
				*/
			BEGIN 
				RETURN '
					WITH Q AS (
						SELECT TOP (1) ' + 
						(
							SELECT 
							STRING_AGG(
								CAST(	'CAST(' + QUOTENAME(NAME) + ' AS sql_variant) AS ' + QUOTENAME(NAME)  AS NVARCHAR(MAX)	), ', '
							)
							FROM sys.dm_exec_describe_first_result_set(@sql, DEFAULT, DEFAULT)
						) + '
						FROM ( ' + @sql + ' ) AS O 
					)
					SELECT U.FieldName, U.FieldValue
					FROM Q
					UNPIVOT (FieldValue FOR FieldName IN (' +	(		
						SELECT STRING_AGG( CAST( QUOTENAME(name) AS NVARCHAR(MAX) ), ', ' ) 
						FROM sys.dm_exec_describe_first_result_set(@sql, DEFAULT, DEFAULT)
					) + ' )) AS U';
			END
			GO

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   */
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   */
 




-- Create the table and insert values as portrayed in the PIVOT example.  
CREATE TABLE pvt (VendorID INT, Emp1 INT, Emp2 INT,  
    Emp3 INT, Emp4 INT, Emp5 INT);  
GO  
INSERT INTO pvt VALUES (1,4,3,5,4,4);  
INSERT INTO pvt VALUES (2,4,1,5,5,5);  
INSERT INTO pvt VALUES (3,4,3,5,4,4);  
INSERT INTO pvt VALUES (4,4,2,5,5,4);  
INSERT INTO pvt VALUES (5,5,1,5,5,5);  
GO  
-- Unpivot the table.  
SELECT VendorID, Employee, Orders  
FROM   
   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5  
   FROM pvt) p  
UNPIVOT  
   (Orders FOR Employee IN   
      (Emp1, Emp2, Emp3, Emp4, Emp5)  
)AS unpvt;  
GO  

/*

Results:

VendorID    Employee    Orders
----------- ----------- ------
1            Emp1       4
1            Emp2       3 
1            Emp3       5
1            Emp4       4
1            Emp5       4
2            Emp1       4
2            Emp2       1
2            Emp3       5
2            Emp4       5
2            Emp5       5
...

*/