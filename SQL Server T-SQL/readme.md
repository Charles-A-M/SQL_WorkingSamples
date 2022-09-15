# SQL Server Links

Below are some useful links for SQL Server / T-SQL concepts.

## T-SQL

 - [Join Types {with chart}](https://www.securesolutions.no/wp-content/uploads/2014/07/joins-1.jpg)
 - [CTEs Common Table Expressions](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Update From](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Deleting Duplicate Rows using ROW_NUMBER](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Numbers (Tally) Table](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [STRING_AGG function](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 


 
		
	https://www.mssqltips.com/sqlservertutorial/9121/sql-server-t-sql-window-functions-tutorial/
		Window Functions
		https://www.mssqltips.com/sqlservertutorial/9122/sql-server-window-functions-examples/
			Calc grand total (SUM) without grouping
			Find top records by Ranks like max sales
			Median value using PERCENTILE_CONT 
		https://www.mssqltips.com/sqlservertutorial/9123/sql-server-window-function-syntax/
			general syntax
			query processing order
				From --> on (used in joins) --> joins --> where --> group by --. having --> select --> calculations/distinct/window functions --> order --> top
		https://www.mssqltips.com/sqlservertutorial/9124/sql-server-window-aggregate-functions-sum-min-max-and-avg/
			running totals
			range vs rows
		https://www.mssqltips.com/sqlservertutorial/9125/sql-server-window-functions-row-number/
			row_number()
				removing duplicates: https://www.mssqltips.com/sqlservertip/4486/find-and-remove-duplicate-rows-from-a-sql-server-table/
									 https://www.mssqltips.com/sqlservertip/1918/different-strategies-for-removing-duplicate-records-in-sql-server/
				pagination: https://www.mssqltips.com/sqlservertip/1175/page-through-sql-server-results-with-the-rownumber-function/
				statistical mode: https://www.mssqltips.com/sqlservertip/3543/calculate-the-statistical-mode-in-sql-server-using-tsql/
		https://www.mssqltips.com/sqlservertutorial/9126/sql-server-window-functions-rank-dense-rank-and-ntile/
			Rank: can have gaps in sequence, but if values are the same, same rank.
			Dense_Rank: like rank, but no gaps
			ntile: divides rows into roughly equal buckets
		https://www.mssqltips.com/sqlservertip/2905/forgotten-sql-server-functions--varp-soundex-and-ntile/
			varp, soundex, and ntile
		https://www.mssqltips.com/sqlservertutorial/9127/sql-server-window-functions-lead-and-lag/
			lag (previous row), lead (next row)
			using lag/lead to find date differences: https://www.mssqltips.com/sqlservertip/3468/sql-servers-lag-and-lead-functions-to-help-identify-date-differences/
			first_value, last_value
		https://www.mssqltips.com/sqlservertutorial/9128/sql-server-statistical-window-functions-percentile-disc-and-percentile-cont/
			PERCENTILE_DISC and PERCENTILE_CONT
				Both functions calculate a percentile based on the discrete and the continuous distribution correspondingly. 
			CUME_DIST and PERCENT_RANK 
				The CUME_DIST function is closely to the PERCENTILE_DIST function: it returns the relative position of a value compared with other values in the data set. 
				In other words, it returns the percentile of a specific value. The PERCENT_RANK function is similar to CUME_DIST.
		https://www.mssqltips.com/sqlservertutorial/9129/sql-server-window-functions-performance-improvement/
			tuning window functions
	https://www.mssqltips.com/sqlservertutorial/9130/sql-server-window-functions-gaps-and-islands-problem/
		Gaps
		Islands
		more details: https://www.red-gate.com/simple-talk/sql/t-sql-programming/the-sql-of-gaps-and-islands-in-sequences/
	
	Numbers table
		https://www.mssqltips.com/sqlservertip/4176/the-sql-server-numbers-table-explained-part-1/
		https://www.mssqltips.com/sqlservertip/6488/how-to-expand-a-range-of-dates-into-rows-using-a-sql-server-numbers-table/
			expand numbres into dates
		









![Join Types](https://www.securesolutions.no/wp-content/uploads/2014/07/joins-1.jpg)