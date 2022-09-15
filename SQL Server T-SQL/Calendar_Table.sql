
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

	/*	===============================================================================================
			AND THEN THERE IS EASTER
			Which is based on lunar cycles and such, so the formula is a bit complex.
			https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/ 
	*/
	RETURN (
		WITH x AS (
    SELECT TheDate = DATEFROMPARTS(@TheYear, [Month], [Day])
      FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))
			  FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
					  FROM (SELECT DaysToSunday = paschal - ((@TheYear + (@TheYear / 4) + paschal - 13) % 7)
							  FROM (SELECT paschal = epact - (epact / 28)
									  FROM (SELECT epact = (24 + 19 * (@TheYear % 19)) % 30) 
													AS epact
									) AS paschal
							) AS dts
					) AS m
			) AS d
		)
	SELECT TheDate, HolidayText = 'Easter Sunday'	  FROM x
    UNION ALL 
	SELECT DATEADD(DAY, -2, TheDate), 'Good Friday'   FROM x
    UNION ALL 
	SELECT DATEADD(DAY,  1, TheDate), 'Easter Monday' FROM x
);


GO



/* get our Easter holidays */

INSERT dbo.HolidayDimension(TheDate, CalendarDimensionID, HolidayText)
SELECT d.TheDate, 1, h.HolidayText
  FROM dbo.DateDimension AS d
 CROSS APPLY dbo.GetEasterHolidays(d.TheYear) AS h
 WHERE d.TheDate = h.TheDate;
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
