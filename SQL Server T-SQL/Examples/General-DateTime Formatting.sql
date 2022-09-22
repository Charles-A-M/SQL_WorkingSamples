/*
	Date-time T-Sql stuff...



	DatePart Codes	:		https://docs.microsoft.com/en-us/sql/t-sql/functions/datepart-transact-sql?view=sql-server-2017	
	Format Codes	:		https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings			

*/

Select Convert(VarChar, SYSDATETIME(), 0  ) /* 	= 	Sep 21 2022  9:59AM							*/	Select Convert(VarChar, SYSDATETIME(), 100) /*	= 	Sep 21 2022  9:59AM									*/
Select Convert(VarChar, SYSDATETIME(), 1  ) /* 	= 	09/21/22						US			*/	Select Convert(VarChar, SYSDATETIME(), 101) /*	= 	09/21/2022											*/
Select Convert(VarChar, SYSDATETIME(), 2  ) /* 	= 	22.09.21						ANSI		*/	Select Convert(VarChar, SYSDATETIME(), 102) /*	= 	2022.09.21											*/
Select Convert(VarChar, SYSDATETIME(), 3  ) /* 	= 	21/09/22						UK/France	*/	Select Convert(VarChar, SYSDATETIME(), 103) /*	= 	21/09/2022											*/
Select Convert(VarChar, SYSDATETIME(), 4  ) /* 	= 	21.09.22						German		*/	Select Convert(VarChar, SYSDATETIME(), 104) /*	= 	21.09.2022											*/
Select Convert(VarChar, SYSDATETIME(), 5  ) /* 	= 	21-09-22						Italian		*/	Select Convert(VarChar, SYSDATETIME(), 105) /*	= 	21-09-2022											*/
Select Convert(VarChar, SYSDATETIME(), 6  ) /* 	= 	21 Sep 22									*/	Select Convert(VarChar, SYSDATETIME(), 106) /*	= 	21 Sep 2022											*/
Select Convert(VarChar, SYSDATETIME(), 7  ) /* 	= 	Sep 21, 22									*/	Select Convert(VarChar, SYSDATETIME(), 107) /*	= 	Sep 21, 2022										*/
Select Convert(VarChar, SYSDATETIME(), 8  ) /* 	= 	10:04:10									*/	Select Convert(VarChar, SYSDATETIME(), 108) /*	= 	10:04:10											*/
Select Convert(VarChar, SYSDATETIME(), 9  ) /* 	= 	Sep 21 2022 10:04:10.9722814AM				*/	Select Convert(VarChar, SYSDATETIME(), 109) /*	= 	Sep 21 2022 10:04:10.9722814AM						*/
Select Convert(VarChar, SYSDATETIME(), 10 ) /* 	= 	09-21-22						US			*/	Select Convert(VarChar, SYSDATETIME(), 110) /*	= 	09-21-2022							USA 4-digit yr	*/
Select Convert(VarChar, SYSDATETIME(), 11 ) /* 	= 	22/09/21						Japan		*/	Select Convert(VarChar, SYSDATETIME(), 111) /*	= 	2022/09/21							Japan			*/
Select Convert(VarChar, SYSDATETIME(), 12 ) /* 	= 	220921							ISO			*/	Select Convert(VarChar, SYSDATETIME(), 112) /*	= 	20220921							ISO				*/
Select Convert(VarChar, SYSDATETIME(), 13 ) /* 	= 	21 Sep 2022 10:04:10.9722814	EU			*/	Select Convert(VarChar, SYSDATETIME(), 113) /*	= 	21 Sep 2022 10:04:10.9722814		EU 				*/
Select Convert(VarChar, SYSDATETIME(), 14 ) /* 	= 	10:04:10.9722814				24-Hr		*/	Select Convert(VarChar, SYSDATETIME(), 114) /*	= 	10:04:10.9722814					24-hr 			*/
Select Convert(VarChar, SYSDATETIME(), 20 ) /* 	= 	2022-09-21 10:04:10				ODBC		*/	Select Convert(VarChar, SYSDATETIME(), 120) /*	= 	2022-09-21 10:04:10					ODBC 			*/
Select Convert(VarChar, SYSDATETIME(), 21 ) /* 	= 	2022-09-21 10:04:10.9722814		ODBC		*/	Select Convert(VarChar, SYSDATETIME(), 121) /*	= 	2022-09-21 10:04:10.9722814			ODBC			*/
Select Convert(VarChar, SYSDATETIME(), 22 ) /* 	= 	09/21/22 10:04:10 AM						*/	Select Convert(VarChar, SYSDATETIME(), 126) /*	= 	2022-09-21T10:04:10.9722814			ISO-8601 		*/
Select Convert(VarChar, SYSDATETIME(), 23 ) /* 	= 	2022-09-21									*/	Select Convert(VarChar, SYSDATETIME(), 127) /*	= 	2022-09-21T10:04:10.9722814			ISO-8601 w/ TZ  */
Select Convert(VarChar, SYSDATETIME(), 24 ) /* 	= 	10:04:10									*/
Select Convert(VarChar, SYSDATETIME(), 25 ) /* 	= 	2022-09-21 10:04:10.9722814					*/


Select DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))                                          /* 2022-08-31 23:59:59.000  	Last Day Previous Month	 */		
Select DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0))										 /* 2022-09-30 23:59:59.000  	Last Day Current Month	 */		
Select DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+2,0))                                        /* 2022-10-31 23:59:59.000  	Last Day Next Month		 */		
Select datediff(week, dateadd( month,  datediff( month, 0, SYSDATETIME()), 0),  SYSDATETIME() ) + 1  /*  4 						 	Week of Month			 */		
 

Select SYSDATETIME()			/*  Server Date/Time as datetime2	=	 2022-09-21 10:19:24.8051275			 */
Select SYSDATETIMEOFFSET()		/*  Server time datetime2 w/TZ		=	 2022-09-21 10:19:54.0935915 -04:00   */
Select SYSUTCDATETIME()			/*  Server Time as UTC				=	 2022-09-21 14:20:20.0755320          */
Select CURRENT_TIMESTAMP		/*  ANSI GetDate as datetime		=	 2022-09-21 10:20:32.410              */
Select GETDATE()				/*  Current Time					=	 2022-09-21 10:20:53.477              */
Select GETUTCDATE()				/*  Current UTC Time				=	 2022-09-21 14:21:04.610              */

Select Format(sysdatetime(), 'yyyy') 	-- = 	2022			Year
Select Format(sysdatetime(), 'gg') 		-- = 	A.D.			B.C./A.D.
Select Format(sysdatetime(), 'MMMM') 	-- = 	September		Month Name
Select Format(sysdatetime(), 'MMM') 	-- = 	Sep				Month Abbrev
Select Format(sysdatetime(), 'MM') 		-- = 	09				Month
Select Format(sysdatetime(), 'dddd') 	-- = 	Wednesday		Weekday name
Select Format(sysdatetime(), 'ddd') 	-- = 	Wed				Weekday Abbrev
Select Format(sysdatetime(), 'dd') 		-- = 	21				Day of month
Select Format(sysdatetime(), 'HH') 		-- = 	13				Hour 24
Select Format(sysdatetime(), 'hh') 		-- = 	1				Hour 12
Select Format(sysdatetime(), 'tt') 		-- = 	AM				AM/PM
Select Format(sysdatetime(), 'mm') 		-- = 	27				minute
Select Format(sysdatetime(), 'ss') 		-- = 	24				second
Select Format(sysdatetime(), 'fff') 	-- = 	662				millisecond
Select Format(sysdatetime(), 'ffffff') 	-- = 	662624			microsecond
Select Format(sysdatetime(), 'fffffff') -- = 	6626242			nanosecond
Select Format(sysdatetime(), 'zzz') 	-- = 	-04:00			time zone hr:minute
Select Format(sysdatetime(), 'zz') 		-- = 	-04				time zone hr
 
 
 -- NOTE that there are no quotes around the date parts:
Select DatePart(YEAR, SysDateTime())  			-- = 	2022
Select DatePart(WEEKDAY, SysDateTime())  		-- = 	4
Select DatePart(WEEK, SysDateTime())  			-- = 	39
Select DatePart(SECOND, SysDateTime())  		-- = 	33
Select DatePart(QUARTER, SysDateTime())  		-- = 	3
Select DatePart(NANOSECOND, SysDateTime())  	-- = 	38960100
Select DatePart(MONTH, SysDateTime())  			-- = 	9
Select DatePart(MINUTE, SysDateTime())  		-- = 	37
Select DatePart(MILLISECOND, SysDateTime())  	-- = 	38
Select DatePart(MICROSECOND, SysDateTime())  	-- = 	38960
Select DatePart(ISO_WEEK, SysDateTime())  		-- = 	38
Select DatePart(HOUR, SysDateTime())  			-- = 	10
Select DatePart(DAYOFYEAR, SysDateTime())  		-- = 	264
Select DatePart(DAY, SysDateTime())  			-- = 	21 
Select DatePart(TZ, SysDateTimeOffset())  		-- = 	-240
Select DatePart(TZOFFSET, SysDateTimeOffset())  -- = 	-240
 