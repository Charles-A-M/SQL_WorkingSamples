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
SELECT <non-pivoted column>,  
    [first pivoted column] AS <column name>,  
    [second pivoted column] AS <column name>,  
    ...  
    [last pivoted column] AS <column name>  
FROM  
    (<SELECT query that produces the data>)   
    AS <alias for the source query>  
PIVOT  
(  
    <aggregation function>(<column being aggregated>)  
FOR   
[<column that contains the values that will become column headers>]   
    IN ( [first pivoted column], [second pivoted column],  
    ... [last pivoted column])  
) AS <alias for the pivot table>  
<optional ORDER BY clause>;  
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   */
 
 USE AdventureWorks2014 ;  
GO  
SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost   
FROM Production.Product  
GROUP BY DaysToManufacture;  

/*
Produces:

DaysToManufacture AverageCost
----------------- -----------
0                 5.0885
1                 223.88
2                 359.1082
4                 949.4105
*/

-- Pivot table with one row and five columns  
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days,   
  [0], [1], [2], [3], [4]  
FROM  
(
  SELECT DaysToManufacture, StandardCost   
  FROM Production.Product
) AS SourceTable  
PIVOT  
(  
  AVG(StandardCost)  
  FOR DaysToManufacture IN ([0], [1], [2], [3], [4])  
) AS PivotTable; 

/*
Results:

Cost_Sorted_By_Production_Days 0           1           2           3           4         
------------------------------ ----------- ----------- ----------- ----------- -----------
AverageCost                    5.0885      223.88      359.1082    NULL        949.4105

*/

SELECT VendorID, [250] AS Emp1, [251] AS Emp2, [256] AS Emp3, [257] AS Emp4, [260] AS Emp5  
FROM   
(SELECT PurchaseOrderID, EmployeeID, VendorID  
FROM Purchasing.PurchaseOrderHeader) p  
PIVOT  
(  
COUNT (PurchaseOrderID)  
FOR EmployeeID IN  
( [250], [251], [256], [257], [260] )  
) AS pvt  
ORDER BY pvt.VendorID; 

/*

VendorID    Emp1        Emp2        Emp3        Emp4        Emp5  
----------- ----------- ----------- ----------- ----------- -----------
1492        2           5           4           4           4
1494        2           5           4           5           4
1496        2           4           4           5           5
1498        2           5           4           4           4
1500        3           4           4           5           4

*/