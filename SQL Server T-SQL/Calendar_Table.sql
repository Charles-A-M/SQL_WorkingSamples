
/* 
	Creating a date dimension or calendar table in SQL Server
	based on:
	https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/  
*/
drop table if exists dbo.HolidayDimension;
drop table if exists dbo.CalendarDimension;
drop table if exists dbo.DateDimension;
go

/* prevent set or regional settings from interfering with interpretation of dates / literals */
SET DATEFIRST  7,  /* 1 = Monday, 7 = Sunday  */
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH;

/*	assign our minimum and maximum dates for the table:		*/
DECLARE @StartDate  date = '20000101';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 75, @StartDate));

print @startDate;
print @CutoffDate;


/*	===============================================================================================
	a recursive CTE that returns a sequence representing the number of days 
	between our start date and x years later less a day (xxxx-12-31) 
*/
;WITH seq(n) AS (
	SELECT 0 
	 UNION ALL 
	SELECT n + 1 
	  FROM seq
	 WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
), d AS (	/*	Next, we can add a second CTE that translates those numbers into all the dates in our range: */
	SELECT DATEADD(DAY, n, @StartDate) d
	  FROM seq
),src AS (	/*	Now, we can start extending those dates with information commonly vital to calendar tables / date dimensions. */
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
), dim AS (	/*	Whatever my source data is, I can build on those parts and get much more detail about each date:  */
  SELECT
    TheDate, 
    TheDay,
    TheDaySuffix        = CONVERT(char(2), 
							CASE WHEN TheDay / 10 = 1 THEN 'th' 
								 ELSE 
									CASE RIGHT(TheDay, 1) WHEN '1' THEN 'st' 
														  WHEN '2' THEN 'nd' 
														  WHEN '3' THEN 'rd' 
														  ELSE 'th' 
									END 
							END),
    TheDayName,
	TheDayAbbreviation = Format(TheDate, 'ddd'),
    TheDayOfWeek,
    TheDayOfWeekInMonth = CONVERT(tinyint, ROW_NUMBER() OVER 
                            (PARTITION BY TheFirstOfMonth, TheDayOfWeek ORDER BY TheDate)),
    TheDayOfYear,
    IsWeekend           = CASE WHEN TheDayOfWeek IN (
									CASE @@DATEFIRST 
									WHEN 1 THEN 6 
									WHEN 7 THEN 1 END,7) 
                              THEN 1 
							  ELSE 0 END,
    TheWeek,
    TheISOweek,
    TheFirstOfWeek      = DATEADD(DAY, 1 - TheDayOfWeek, TheDate),
    TheLastOfWeek       = DATEADD(DAY, 6, DATEADD(DAY, 1 - TheDayOfWeek, TheDate)),
    TheWeekOfMonth      = CONVERT(tinyint, DENSE_RANK() OVER 
                            (PARTITION BY TheYear, TheMonth ORDER BY TheWeek)),
    TheMonth,
    TheMonthName,
	TheMonthAbbreviation = Format(TheDate, 'MMM'),
    TheFirstOfMonth,
    TheLastOfMonth      = MAX(TheDate) OVER (PARTITION BY TheYear, TheMonth),
    TheFirstOfNextMonth = DATEADD(MONTH, 1, TheFirstOfMonth),
    TheLastOfNextMonth  = DATEADD(DAY, -1, DATEADD(MONTH, 2, TheFirstOfMonth)),
    TheQuarter,
    TheFirstOfQuarter   = MIN(TheDate) OVER (PARTITION BY TheYear, TheQuarter),
    TheLastOfQuarter    = MAX(TheDate) OVER (PARTITION BY TheYear, TheQuarter),
    TheYear,
    TheISOYear          = TheYear - CASE WHEN TheMonth = 1  AND TheISOWeek > 51 THEN 1 
										 WHEN TheMonth = 12 AND TheISOWeek = 1  THEN -1 
										 ELSE 0 END,      
    TheFirstOfYear      = DATEFROMPARTS(TheYear, 1,  1),
    TheLastOfYear,
    IsLeapYear          = CONVERT(bit, CASE WHEN (TheYear % 400 = 0) OR (TheYear % 4 = 0 AND TheYear % 100 <> 0) 
										    THEN 1 
											ELSE 0 END),
    --Has53Weeks          = CASE WHEN DATEPART(WEEK,     TheLastOfYear) = 53 THEN 1 ELSE 0 END,
    --Has53ISOWeeks       = CASE WHEN DATEPART(ISO_WEEK, TheLastOfYear) = 53 THEN 1 ELSE 0 END,
	LastWeekOfYear		= DATEPART(WEEK,     TheLastOfYear),
	LastISOWeekOfYear	= DATEPART(ISO_WEEK, TheLastOfYear),
    MMYYYY              = CONVERT(char(2), CONVERT(char(8), TheDate, 101)) + CONVERT(char(4), TheYear),
    Style101            = CONVERT(char(10), TheDate, 101), /* mm/dd/yyyy */
    Style103            = CONVERT(char(10), TheDate, 103), /* dd/mm/yyyy */
    Style112            = CONVERT(char(8),  TheDate, 112), /* yyyymmdd */
    Style120            = CONVERT(char(10), TheDate, 120)  /* yyyy-mm-dd */
  FROM src
)	/*	anything else we want to know about this sucker? If so, add it in somewhere in this stack.  */
SELECT * INTO dbo.DateDimension 
  FROM dim
 ORDER BY TheDate
OPTION (MAXRECURSION 0);

CREATE UNIQUE CLUSTERED INDEX PK_DateDimension ON dbo.DateDimension(TheDate);

select top 50 *
  from dbo.DateDimension
  where TheDate >= getDate();

/*	===============================================================================================

	Next, we need to talk about holidays, 
	one of the primary reasons you need to use a calendar table instead of relying on built-in date/time functions. 
	This table allows you to have more than one holiday for any given date, 
	and in fact allows for multiple entire calendars each with their own set of holidays.
*/



create table dbo.CalendarDimension (
	id int not null identity primary key,
	CalendarName nvarchar(255) not null,
	isWorkHoliday bit not null default 0,
	CalendarDescription nvarchar(2000)
);

Insert into dbo.CalendarDimension (CalendarName, CalendarDescription) values ('US Holidays', 'Standard US Holidays');
Insert into dbo.CalendarDimension (CalendarName, CalendarDescription, isWorkHoliday) values ('Work Holidays', 'Work Holidays', 1);
 
CREATE TABLE dbo.HolidayDimension (
  TheDate date NOT NULL foreign key references dbo.DateDimension(TheDate),
  CalendarDimensionID int foreign key references dbo.CalendarDimension(ID),
  HolidayText nvarchar(255) NOT NULL
);

CREATE CLUSTERED INDEX CIX_HolidayDimension ON dbo.HolidayDimension(TheDate);
GO

/*	===============================================================================================
		This will populate the basic US holidays.
		Note that there are hundreds of other dates across the world that are worth tracking.
		But this shows how to set them up.
*/
;WITH x AS (	/*	get our dates to check for holidays	*/
	SELECT
			TheDate,
			TheFirstOfYear,
			TheDayOfWeekInMonth, 
			TheMonth, 
			TheDayName, 
			TheDay,
			TheLastDayOfWeekInMonth = ROW_NUMBER() OVER (
				PARTITION BY TheFirstOfMonth, TheDayOfWeek
			    ORDER BY TheDate DESC
			)
	   FROM dbo.DateDimension
), s AS (	/*	some holidays are specific day/month. Some are Nth X of a month.	*/
	SELECT 
			TheDate, 
			HolidayText = 
				CASE
					WHEN (TheDate = TheFirstOfYear)													THEN 'New Year''s Day'
					WHEN (TheDayOfWeekInMonth = 3 AND TheMonth = 1 AND TheDayName = 'Monday')		THEN 'Martin Luther King Day'    -- (3rd Monday in January)
					WHEN (TheDayOfWeekInMonth = 3 AND TheMonth = 2 AND TheDayName = 'Monday')		THEN 'President''s Day'          -- (3rd Monday in February)
					WHEN (TheLastDayOfWeekInMonth = 1 AND TheMonth = 5 AND TheDayName = 'Monday')   THEN 'Memorial Day'              -- (last Monday in May)
					WHEN (theMonth = 6 and TheDay = 20 and year(theDate) > 2019)					THEN 'Juneteenth National Independence Day'	--Jun 20 2020 and later
					WHEN (TheMonth = 7 AND TheDay = 4)											    THEN 'Independence Day'          -- (July 4th)
					WHEN (TheDayOfWeekInMonth = 1 AND TheMonth = 9 AND TheDayName = 'Monday')	    THEN 'Labor Day'                 -- (first Monday in September)
					WHEN (TheDayOfWeekInMonth = 2 AND TheMonth = 10 AND TheDayName = 'Monday')      THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
					WHEN (TheMonth = 11 AND TheDay = 11)										    THEN 'Veterans'' Day'            -- (November 11th)
					WHEN (TheDayOfWeekInMonth = 4 AND TheMonth = 11 AND TheDayName = 'Thursday')    THEN 'Thanksgiving Day'          -- (Thanksgiving Day fourth Thursday in November)
					WHEN (TheMonth = 12 AND TheDay = 24)										    THEN 'Christmas Eve'
					WHEN (TheMonth = 12 AND TheDay = 25)										    THEN 'Christmas Day'
				END
	  FROM x
	 WHERE TheDate = TheFirstOfYear
		OR (TheDayOfWeekInMonth		= 3	 AND TheMonth = 1  AND TheDayName = 'Monday'  )
		OR (TheDayOfWeekInMonth		= 3  AND TheMonth = 2  AND TheDayName = 'Monday'  )
		OR (TheLastDayOfWeekInMonth = 1  AND TheMonth = 5  AND TheDayName = 'Monday'  )
		OR (theMonth				= 6	 AND TheDay	  = 20 AND Year(TheDate) > 2019   ) 
		OR (TheMonth				= 7	 AND TheDay   = 4                             )
		OR (TheDayOfWeekInMonth		= 1  AND TheMonth = 9  AND TheDayName = 'Monday'  )
		OR (TheDayOfWeekInMonth		= 2  AND TheMonth = 10 AND TheDayName = 'Monday'  )
		OR (TheMonth				= 11 AND TheDay   = 11                            )
		OR (TheDayOfWeekInMonth		= 4  AND TheMonth = 11 AND TheDayName = 'Thursday')
		OR (TheMonth				= 12 AND TheDay   = 24							  )
		OR (TheMonth				= 12 AND TheDay   = 25							  )
)
INSERT dbo.HolidayDimension(TheDate, CalendarDimensionID, HolidayText)
SELECT TheDate, 1, HolidayText 
  FROM s 
 UNION ALL 
SELECT DATEADD(DAY, 1, TheDate), 1, 'Black Friday'
  FROM s 
 WHERE HolidayText = 'Thanksgiving Day'
 ORDER BY TheDate;
go



CREATE or ALTER FUNCTION dbo.GetEasterHolidays(@TheYear INT) 
	RETURNS TABLE WITH SCHEMABINDING
AS
	/*	-- ===============================================================================================
		--	AND THEN THERE IS EASTER
		--  Easter Sunday is the Sunday following the paschal full moon date. 
		--	https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/ 
		-- ===============================================================================================
	*/
	/*  --  from the above mssqltips.com link:
	RETURN (
		WITH x AS (
			SELECT TheDate = DATEFROMPARTS(@TheYear, [Month], [Day])
			  FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))
					  FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
							  FROM (SELECT DaysToSunday = paschal - ((@TheYear + (@TheYear / 4) + paschal - 13) % 7)
									  FROM (SELECT paschal = epact - (epact / 28)
											  FROM (SELECT epact = (24 + 19 * (@TheYear % 19)) % 30) AS epact
											) AS paschal
									) AS dts
							) AS m
					) AS d
				)
		SELECT TheDate, HolidayText = 'Easter Sunday'	  FROM x	UNION ALL 
		SELECT DATEADD(DAY, -2, TheDate), 'Good Friday'   FROM x	UNION ALL 
		SELECT DATEADD(DAY,  1, TheDate), 'Easter Monday' FROM x
	);
	*/
	/*	-- ===============================================================================================
		-- This longer version more closely aligns with the wikipedia article's formula. 
			Not sure if the above is a reduced form of this same set, but a few sample years further out from now
			didn't return the same values, so I believe this may be more accurate.
		-- ===============================================================================================
		-- */
	return (
		with ab     AS ( Select @theYear % 19 AS A, @theYear % 4 AS B ),
		     ck     AS ( Select A, B, @theYear % 7 AS C, FLOOR(@theYear / 100) AS K                                          from ab ),
		     pq     AS ( select A, B, C, K, FLOOR((13 + 8 * K) / 25) AS P, FLOOR(K / 4) AS Q                                 from ck ),
			 mn     AS ( Select A, B, C, K, P, Q,  (15 - P + K - Q) % 30 AS M,  (4 + K - Q) % 7 AS N                         from pq ),
			 d      AS ( Select A, B, C, K, P, Q, M, N, (19 * A + M) % 30 AS D                                               from mn ),
			 e      AS ( Select A, B, C, K, P, Q, M, N, D, (2 * B + 4 * C + 6 * D + N) % 7 AS E, (11 * M + 11) % 30 AS X     from d  ),
			 flg    AS ( select A, B, C, K, P, Q, M, N, D, E, Case When D = 28 and E = 6 and X < 19 then 1 
			                                                       when D = 29 and E = 6 then 2 else 0 end AS Z              from e  ),
		     dy     AS ( select A, B, C, K, P, Q, M, N, D, E, Z, Case when Z > 0 then 99 else 22 + D + E end AS Mar, 
													             case when Z = 1 then 18 
														              when Z = 2 then 19 else D + E - 9 End AS Apr           from flg),
			 mnth   AS ( select A, B, C, K, P, Q, M, N, D, E, Z, Mar, Apr, case when Mar > 31 then 4 else 3 end AS [Month], 
			                                                               case when Mar > 31 then Apr else Mar end AS [Day] from dy )
		select /* A     AS [A-19Year_LunarCycle], 
		       B , 
			   C , 
		       K        AS [K-100YrLeapOffset], 
			   Q        AS [Q-400YrLeapOffset],
			   P        AS [P-LunarRoundingCorrection],
		       M        AS [M-CenturyStartPt], 
			   N        AS [N-01Jan_WeekdayOffset], 
			   D        AS [D-22Mar_Offset], 
			   E        AS [E-Offset_D_to_Sunday], 
			   Z        AS [z-HistoricalOFfsetFlag], 
			   Mar      AS [m-MarchOffset], 
			   Apr      AS [a-AprilOffset],  -- */
			   @theYear AS [Easter Year],   
			   [Month]  AS [Easter Month],   
			   [Day]    AS [Easter Day],  
			   DATEADD(Day, -7, DATEFROMPARTS(@theYear, [Month], [Day])) AS [Palm Sunday],		/* Sixth day of Lent. 1st day of Holy Week */
			   DATEADD(Day, -3, DATEFROMPARTS(@theYear, [Month], [Day])) AS [Maundy Thursday],  /* Last supper. Maundy" comes from the Latin word mandatum, or commandment, reflecting Jesus' words "I give you a new commandment. */
			   DATEADD(Day, -2, DATEFROMPARTS(@theYear, [Month], [Day])) AS [Good Friday],		/* Commemorates the crucifixion. Buried on Sat, the Sabbath. */
			   DATEFROMPARTS(@theYear, [Month], [Day])                   AS [Easter Sunday],	/* celebrates the resurrection */
			   DATEADD(Day, 1,  DATEFROMPARTS(@theYear, [Month], [Day])) AS [Easter Monday]
		  from mnth 
		)
/*	-- ===============================================================================================
	--	https://en.wikipedia.org/wiki/Date_of_Easter
		From the above wikipedia article:
			subtraction in modulo math is done via addition.

		The paschal full moon date is the ecclesiastical full moon date on or after 21 March. 
		The Gregorian method derives paschal full moon dates by determining the epact for each year.

		The epact of 1 represents the theoretical 1st visibility of the 1st crescent of the moon.
			Day 14, then, is the the day of the full moon. New moon is day 29 of a hollow (29-day) month or 30 of a full(30-day) month.
		The paschal full moon date for a year is found from it's sequence # in the Metonic cycle. Called the golden number.
			This repeats the lunar phase on Jan 1 every 19 years. The Gregorian reform messes this up somewhat.
			As of this writing, the current Metonic cycle began in 2014 and goes through 2032.
		On this cycle, the Pascal full moon is either 11 days earlier than the previous year or 19 days later, 
			except that in year 1 the date is 18 days later (Apr 14, not 15).

		First Part:
		D represents the # of days, counting from 22 March, to the day after the full moon.
		A is the year's position in the 19-year lunar phase cycle. It's not exactly the Metonic cycle (6939.6813 days vs 6939.6075 days).
			(19a + M) mod 30 repeats every 19 years within each century as M is determined per century. 
			The 19-yr cycle has nothing to do with the 19 in 19a. This is correcting a mismatch betweeen calendar yr and integer num of lunar months.
			A calendar year (non-leap year) has 365 days and the closest one can come with an integer number of lunar months is 12 × 29.5 = 354 days. 
			The difference is 11 days, which must be corrected for by moving the following year's occurrence of a full moon 11 days back. 
			But in modulo 30 arithmetic, subtracting 11 is the same as adding 19, hence the addition of 19 for each year added, i.e. 19a
		M serves to have a correct starting point at the start of each century. It takes the num of leap years up until that century.
		K inhibits a leap day every 100 years.
		Q reinstalls it every 400 years.
			yielding (k − q) as the total number of inhibitions to the pattern of a leap day every four years. 
			Thus we add (k − q) to correct for leap days that never occurred. 
		P corrects for the lunar orbit not being fully describable in integer terms.

		The range of days considered for the full moon to determine Easter are 21 March (the day of the ecclesiastical equinox of spring) to 18 April -- a 29-day range. 
			However, in the mod 30 arithmetic of variable d and constant M, both of which can have integer values in the range 0 to 29, the range is 30. 
			Therefore, adjustments are made in critical cases. Once d is determined, this is the number of days to add to 22 March 
			(the day after the earliest possible full moon allowed, which is coincident with the ecclesiastical equinox of spring) to obtain the date of the day after the full moon.
		So the first allowable date of Easter is March 22 + d + 0, as Easter is to celebrate the Sunday after the ecclesiastical full moon, that is if the full moon falls on Sunday 21 March Easter is to be celebrated 7 days after, while if the full moon falls on Saturday 21 March Easter is the following 22 March.

		Second Part:
		E, the additional offset days that must be added to D to arrive at a Sunday; 0 to 6 determined via modulo 7 arithmetic:
			E = 2b + 4c + 6d + N mod 7.
			2b + 4c fixes for weekdays slide each year. year = 365, but 52*7 = 364, so we lose one weekday each year.
			6d fixes for the corresponding slide of the lunar year.
			Therefore E ends up holding the step from day after the day of the full moon to the nearest following Sunday, between 0 and 6 days.
		N provides the starting point for the calculation for each century and depends on what weekday 1 Jan falls on.
		D + E hields a range of offsets 0 - 35, or 22 March to 26 April. 
			For historical compatibility, all offsets of 35 and some of 34 are subtracted by 7, jumping back 1 week.
			Thus, 26 Apr is never Easter and 19 Apr is overrepresented. This is a historical correction and has nothing to do with the mathematical algorithm.
			The offset of 34 is adjusted if D=28 and D=29.

		This algorithm is not valid for years < 1583, as that was the 1st year Gregorian calendars were used for Easter.
		This algorithm may not be valid for far-future dates, since churches can set Easter to whatever they decide.


		A-19Year_LunarCycle	B	C	K-100YrLeapOffset	Q-400YrLeapOffset	P-LunarRoundingCorrection	
		10					1	6	17						4				5	
		3					1	3	18						4				6	
		4					1	1	19						4				6	
		17					2	0	19						4				6	
		8					2	6	20						5				6	
		9					3	0	20						5				6	
		10					0	1	20						5				6	
		11					1	2	20						5				6	
		18					2	3	22						5				7		

		M-CenturyStartPt	N-01Jan_WeekdayOffset	D-22Mar_Offset	E-Offset_D_to_Sunday	z-HistoricalOFfsetFlag	m-MarchOffset	a-AprilOffset	
		23					3						3				5						0						30				-1	
		23					4						20				5						0						47				16	
		24					5						10				1						0						33				2	
		24					5						17				6						0						45				14	
		24					5						26				0						0						48				17	
		24					5						15				3						0						40				9	
		24					5						4				5						0						31				0	
		24					5						23				6						0						51				20	
		25					0						7				2						0						31				0	

		Easter Year	Easter Month	Easter Day	Palm Sunday	Maundy Thursday	Good Friday	Easter Sunday	Easter Monday
		1777		3				30			1777-03-23	1777-03-27		1777-03-28	1777-03-30		1777-03-31
		1865		4				16			1865-04-09	1865-04-13		1865-04-14	1865-04-16		1865-04-17
		1961		4				2			1961-03-26	1961-03-30		1961-03-31	1961-04-02		1961-04-03
		1974		4				14			1974-04-07	1974-04-11		1974-04-12	1974-04-14		1974-04-15
		2022		4				17			2022-04-10	2022-04-14		2022-04-15	2022-04-17		2022-04-18
		2023		4				9			2023-04-02	2023-04-06		2023-04-07	2023-04-09		2023-04-10
		2024		3				31			2024-03-24	2024-03-28		2024-03-29	2024-03-31		2024-04-01
		2025		4				20			2025-04-13	2025-04-17		2025-04-18	2025-04-20		2025-04-21
		2222		3				31			2222-03-24	2222-03-28		2222-03-29	2222-03-31		2222-04-01

	*/
go





/* get our Easter holidays */

INSERT dbo.HolidayDimension(TheDate, CalendarDimensionID, HolidayText)
SELECT d.TheDate, 1, 'Easter'
  FROM dbo.DateDimension AS d
 CROSS APPLY dbo.GetEasterHolidays(d.TheYear) AS h
 WHERE d.TheDate = h.[Easter Sunday];
go

/*	===============================================================================================
	which holidays does my employer observe?

	Pull the holidays from US Holidays to build Work Holidays calendar.
	Exclude any holiday on the weekends (we'll get to those next).
	Only pull the holidays that my employer considers work holidays. I don't get President's Day off...
*/
insert into dbo.HolidayDimension (theDate, CalendarDimensionID, HolidayText)
  select TheDate, 2, HolidayText 
  from HolidayDimension
 where CalendarDimensionID = 1
   and HolidayText not in ('Columbus Day', 'President''s Day', 'Easter Monday', 'Veterans'' Day') 
   and DATEPART(WEEKDAY, theDate) not in (1, 7)
go


with weekendHolidaysNewDate as (
	/*	Get the Fri before Sat or the Mon after Sun holidays 
		Warning, this CTE allows overlap w/ existing holidays
			For US holidays, this means Christmas Eve/Christmas. 
			Years ..., 2000, 2004, 2006, 2010, 2017, 2021, 2023, 2027, ...
	*/
	Select	TheDate,
			DATEPART(WEEKDAY, theDate) wd,
			DATENAME(WEEKDAY, theDate) theDay,
			Case When DATEPART(WEEKDAY, theDate) = 7 then DATEADD(day, -1,  theDate)
		         When DATEPART(WEEKDAY, theDate) = 1 then DATEADD(day,  1,  theDate)
			end newDate,
			HolidayText + ' (Observed)' obsHolidayText
	   from HolidayDimension hd
	  where HolidayText not in ('Columbus Day', 'President''s Day', 'Easter Sunday', 'Easter Monday', 'Veterans'' Day') 
	    and CalendarDimensionID = 1
	    and DATEPART(WEEKDAY, theDate) in (1, 7)
)
insert into HolidayDimension (TheDate, CalendarDimensionID, HolidayText) 
select newDate, 2, obsHolidayText
  from weekendHolidaysNewDate
 where NewDate in (select theDate from DateDimension)
 

 /*
	Now go back, find the days where we have two observed work holidays on the same date in the same calendar.
	Again, this is only impacting Christmas Eve / Christmas...
	But find the overlaps, then move the holidays out so there's no longer an overlap...

*/
 ;with Duplicates as (
	select theDate, count(*) Cnt
	  from HolidayDimension 
	 where CalendarDimensionID = 2
	 group by theDate
	having count(*) > 1
), ToFix as (
	Select TheDate OldDate,
		   DATENAME(WEEKDAY, theDate) theDay,
		   HolidayText oldText
	  from HolidayDimension
	 where TheDate in (select TheDate from Duplicates)
	   and HolidayText not like '%Observed%'
	   and CalendarDimensionID = 2
)
Update hd 
   set hd.TheDate = DATEADD(day, 1, hd.theDate), 
	   hd.HolidayText = oldText + ' (Observed)'
  from HolidayDimension hd
 inner join ToFix tf on tf.OldDate = hd.TheDate and tf.oldText = hd.HolidayText
 where hd.CalendarDimensionID = 2



/*  Merge the two tables into 1 view */
IF OBJECT_ID('dbo.TheCalendar', 'V') IS NOT NULL
    DROP VIEW dbo.TheCalendar
GO
CREATE VIEW dbo.TheCalendar
AS 
/*  based on https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/  
	if you have more than 2 holiday calendars, you'll need to expand the columns at bottom and add the join statements.
*/
SELECT
       d.TheDate,
       d.TheDay,
       d.TheDaySuffix,
       d.TheDayName,
       d.TheDayOfWeek,
       d.TheDayOfWeekInMonth,
       d.TheDayOfYear,
       d.IsWeekend,
       d.TheWeek,
       d.TheISOweek,
       d.TheFirstOfWeek,
       d.TheLastOfWeek,
       d.TheWeekOfMonth,
       d.TheMonth,
       d.TheMonthName,
       d.TheFirstOfMonth,
       d.TheLastOfMonth,
       d.TheFirstOfNextMonth,
       d.TheLastOfNextMonth,
       d.TheQuarter,
       d.TheFirstOfQuarter,
       d.TheLastOfQuarter,
       d.TheYear,
       d.TheISOYear,
       d.TheFirstOfYear,
       d.TheLastOfYear,
       d.IsLeapYear,
       --d.Has53Weeks,
       --d.Has53ISOWeeks,
	   d.LastWeekOfYear,
	   d.LastISOWeekOfYear,
       d.MMYYYY,
       d.Style101 [MMDDYYYY],
       d.Style103 [DDMMYYYY],
       d.Style112 [YYYYMMDD],
       d.Style120 [YYYY-MM-DD],
	   hUS.HolidayText [US Holiday],
	   cUS.isWorkHoliday [US isWorkHoliday],
	   hWk.HolidayText [Work Holiday],
	   cWk.isWorkHoliday [Work isWorkHoliday]
  from dbo.DateDimension d
  left join dbo.HolidayDimension  hUS on hUS.TheDate = d.TheDate and hUS.CalendarDimensionID = 1
  left join dbo.CalendarDimension cUS on cUS.id = hUS.CalendarDimensionID
  left join dbo.HolidayDimension  hWk on hWk.TheDate = d.TheDate and hWk.CalendarDimensionID = 2
  left join dbo.CalendarDimension cWk on cWk.id = hWk.CalendarDimensionID
  ;
  go


  Select top 50 *
    from dbo.TheCalendar
   where TheDate >= getDate();
