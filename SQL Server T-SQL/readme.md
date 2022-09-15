# SQL Server Links

Below are some useful links for SQL Server / T-SQL concepts.
[//]: # (https://github.com/Charles-A-M/SQL_WorkingSamples)
[//]: # (https://www.markdownguide.org/cheat-sheet)

## T-SQL

 - [Join Types {with chart}](https://www.securesolutions.no/wp-content/uploads/2014/07/joins-1.jpg) See image below.
 - [CTEs Common Table Expressions](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Update From](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Deleting Duplicate Rows using ROW_NUMBER](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [STRING_AGG function](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Select statement processing order](https://www.mssqltips.com/sqlservertutorial/9123/sql-server-window-function-syntax/) From --> on (used in joins) --> joins --> where --> group by --. having --> select --> calculations/distinct/window functions --> order --> top
 - [Numbers Table](https://www.mssqltips.com/sqlservertip/4176/the-sql-server-numbers-table-explained-part-1/)
   - [Expand numbers into range of dates](https://www.mssqltips.com/sqlservertip/6488/how-to-expand-a-range-of-dates-into-rows-using-a-sql-server-numbers-table/)
 - [Pivot](https://www.mssqltips.com/sqlservertip/1019/crosstab-queries-using-pivot-in-sql-server/) to turn rows into columns
   - [Dynamic Pivot](https://www.mssqltips.com/sqlservertip/2783/script-to-create-dynamic-pivot-queries-in-sql-server/)
 - [HTML](https://www.red-gate.com/simple-talk/blogs/generating-html-sql-server-queries/) from SQL results via For Xml
 
### Dates/Times
 - [Best practices](https://www.mssqltips.com/sqlservertip/5206/sql-server-datetime-best-practices/) Avoid regional date formats, avoid shorthand, avoid between with date/times
 - [DATEADD](https://www.mssqltips.com/sqlservertip/2509/add-and-subtract-dates-using-dateadd-in-sql-server/)
 - [other](https://www.mssqltips.com/sql-server-tip-category/121/dates/) date/time tips
 - [Fun with DATETIME](https://eitanblumin.com/2021/04/27/fun-with-datetime-arithmetics/) zeroth value, strange dateAdd results, durations
 - [Rounding dates](https://eitanblumin.com/2021/06/17/even-more-fun-with-datetime-arithmetics/)

### Window Functions

 - [Intro to Window Functions](https://www.mssqltips.com/sqlservertutorial/9121/sql-server-t-sql-window-functions-tutorial/)
 - [Basic examples](https://www.mssqltips.com/sqlservertutorial/9122/sql-server-window-functions-examples/) (Grand totals, top X by rank, medians)
 - [General syntax](https://www.mssqltips.com/sqlservertutorial/9123/sql-server-window-function-syntax/) and query processing order
 - [Running Totals, Range vs Rows](https://www.mssqltips.com/sqlservertutorial/9124/sql-server-window-aggregate-functions-sum-min-max-and-avg/)
 - [ROW_NUMBER](https://www.mssqltips.com/sqlservertutorial/9125/sql-server-window-functions-row-number/)
   - [Removing Duplicates 1](https://www.mssqltips.com/sqlservertip/4486/find-and-remove-duplicate-rows-from-a-sql-server-table/)
   - [Other strategies](https://www.mssqltips.com/sqlservertip/1918/different-strategies-for-removing-duplicate-records-in-sql-server/) for removing duplicates
 - [Rank, Dense_Rank, NTILE](https://www.mssqltips.com/sqlservertutorial/9126/sql-server-window-functions-rank-dense-rank-and-ntile/) **Rank:** can have gaps in sequence, but if values are the same, same rank. **Dense_Rank:** like rank, but no gaps. **ntile:** divides rows into roughly equal buckets
 - [VARP, SOUNDEX, and ranking](https://www.mssqltips.com/sqlservertip/2905/forgotten-sql-server-functions--varp-soundex-and-ntile/) **VARP** calculates ariance STDEV is better. **SOUNDEX** uses a 1918 algorithm to decide if words sound similar. **Rank**, **Dense_Rank** and **NTILE**
 - [LAG, LEAD, FIRST_VALUE, LAST_VALUE](https://www.mssqltips.com/sqlservertutorial/9127/sql-server-window-functions-lead-and-lag/) **LAG** gets previous row. **LEAD** gets next row.
   - [Date Differences](https://www.mssqltips.com/sqlservertip/3468/sql-servers-lag-and-lead-functions-to-help-identify-date-differences/) using Lag and Lead.
 - [PERCENTILE_DISC and PERCENTILE_CONT](https://www.mssqltips.com/sqlservertutorial/9128/sql-server-statistical-window-functions-percentile-disc-and-percentile-cont/) Both functions calculate a percentile based on the discrete and the continuous distribution correspondingly. 
   - **CUME_DIST** and **PERCENT_RANK** The CUME_DIST function returns the relative position of a value compared with other values in the data set. In other words, it returns the percentile of a specific value. The PERCENT_RANK function is similar to CUME_DIST.
 - [Tuning Window Functions](https://www.mssqltips.com/sqlservertutorial/9129/sql-server-window-functions-performance-improvement/)
 - [Gaps and Islands](https://www.mssqltips.com/sqlservertutorial/9130/sql-server-window-functions-gaps-and-islands-problem/) **Gaps** are missing elements in sequences. **Islands** are clumps within sequences.
   - [More on Gaps and Islands problems](https://www.red-gate.com/simple-talk/sql/t-sql-programming/the-sql-of-gaps-and-islands-in-sequences/)
 
### Tools
 - [Random text](https://stackoverflow.com/questions/1324063/generating-random-strings-with-t-sql/1324390#1324390) this gives reproduceable, but random, text.
 - [CSV splitter](https://www.sqlservercentral.com/articles/tally-oh-an-improved-sql-8k-%E2%80%9Ccsv-splitter%E2%80%9D-function)
 - [Numbers (Tally) Table](https://www.mssqltips.com/sqlservertip/6727/tsql-tips-tricks/)
 - [Calendar table](https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/)




![Join Types](https://www.securesolutions.no/wp-content/uploads/2014/07/joins-1.jpg)
(https://www.securesolutions.no/wp-content/uploads/2014/07/joins-1.jpg)



### Date Formatting

| Num | Convert(VarChar, <DATE>),<NUM>) |
| --- | ------------------------------- |
| 0   | Sep 15 2022  1:54PM |
| 1   | 09/15/22 |
| 2   | 22.09.15 |
| 3   | 15/09/22 |
| 4   | 15.09.22 |
| 5   | 15-09-22 |
| 6   | 15 Sep 22 |
| 7   | Sep 15, 22 |
| 8   | 13:54:43 |
| 9   | Sep 15 2022  1:54:43.8320428PM |
| 10  | 09-15-22 |
| 11  | 22/09/15 |
| 12  | 220915 |
| 13  | 15 Sep 2022 13:54:43.8320428 |
| 14  | 13:54:43.8320428 |
| 20  | 2022-09-15 13:54:43 |
| 21  | 2022-09-15 13:54:43.8320428 |
| 22  | 09/15/22  1:54:43 PM |
| 23  | 2022-09-15 |
| 24  | 13:54:43 |
| 25  | 2022-09-15 13:54:43.8320428 |
| 100 | Sep 15 2022  1:54PM |
| 101 | 09/15/2022 |
| 102 | 2022.09.15 |
| 103 | 15/09/2022 |
| 104 | 15.09.2022 |
| 105 | 15-09-2022 |
| 106 | 15 Sep 2022 |
| 107 | Sep 15, 2022 |
| 108 | 13:54:43 |
| 109 | Sep 15 2022  1:54:43.8320428PM |
| 110 | 09-15-2022 |
| 111 | 2022/09/15 |
| 112 | 20220915 |
| 113 | 15 Sep 2022 13:54:43.8320428 |
| 114 | 13:54:43.8320428 |
| 120 | 2022-09-15 13:54:43 |
| 121 | 2022-09-15 13:54:43.8320428 |
| 126 | 2022-09-15T13:54:43.8320428 |
| 127 | 2022-09-15T13:54:43.8320428 |
