/*
	These functions perform various selected calculations found in 
	"Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	
	Several of these rely on tables of factors, found in Meeus.LookupTables.sql.

	Functions found here:

	dbo.fn_DatePartsToJD(													Converts a set of date parts into either a JD or JDE (JD - delta T) value.
		@inYear as smallint,  @inMonth as tinyint,  @inDay as tinyint,		Used by several other functions here.
		@inHour as tinyint,   @inMinute as tinyint, @inSecond as tinyint,	UT requires Lookups for Table 10.A.
		@inNanosecond as int, @inReturnUT as bit = 0)
	Returns Float

	dbo.fn_DateToJD(@inDate as datetime2, @inReturnJDE as bit = 0)			Converts a dateTime2 value into either a JD or UT value. Requires dbo.DatePartsToJD.
	Returns Float

	dbo.fn_getMod(dividend, divisor)										SQL's % operator does not compute negative values correctly, so we have to do it manually.
																			returns dividend - (floor(dividend / divisor) * divisor) 



*/

/* For any given date parts (year, month, day, hour, minute, second, nanosecond) calculate a JD with or without ΔT. */
Create or Alter Function dbo.fn_DatePartsToJD(
	@inYear as int,  @inMonth as int,  @inDay as int, 
	@inHour as int,   @inMinute as int, @inSecond as int,
	@inNanosecond as int, @inUseDeltaT as bit = 0)
	Returns  numeric(38,20)
as 
Begin
	/*
	This converts a standard date from Datetime2 format to 
		JD:  Julian Days (@inReturnsJDE = 0)	-- Days (and fractions of a day) since 01 Jan -4712 12:00:00 noon. 
		JDE: Julian Days Ephemeris				-- JD adjusted to Universal Time (corrections for differences between Dynamical and observed time)
	
	Assumes input is UTC / is not time-zone-aware.
	Assumes date is Gregorian unless it's before 01 Oct 1582, the generally agreed-upon date 0 in Gregorian counting.
	Requires Meeus Lookup tables to exist for JD to JDE calculations.

	By using date parts instead of an actual date, this function can handle any date value; 
	therefore it is not limited by DateTime2's range of 0001-01-01 to 9999-12-31.

	Based on the algorithm presented in Ch. 7, p. 59 of "Astronomical Algorithms Second Edition" by Jean Meeus, 1998.
	Several check values from Ch. 7 to validate output:

	inDate						inYear	inMonth	inDay	inHour	Min		Sec		Nano	JD
	1957-10-04 19:26:24.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2436116.31
	0333-01-27 12:00:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	1842713
	2000-01-01 12:00:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2451545
	1999-01-01 00:00:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2451179.5
	1900-01-01 00:00:01.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2415020.50001157
	1600-01-01 00:00:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2305447.5
	1600-12-31 00:00:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2305812.5
	0837-04-10 07:12:00.0000000	NULL	NULL	NULL	NULL	NULL	NULL	NULL	2026871.8
	NULL						-123	12		31		0		0		0		0		1676496.5
	NULL						-122	1		1		0		0		0		0		1676497.5
	NULL						-1000	7		12		12		0		0		0		1356001
	NULL						-1000	2		29		0		0		0		0		1355866.5
	NULL						-1001	8		17		21		36		0		0		1355671.4
	NULL						-4712	1		1		12		0		0		0		0

	--------------------------------------------------------------------------------------------------
	2022-11-11	Charles M.		First Draft
	*/
	Declare @Fraction numeric(38,20) = @inDay + ((((((@inNanosecond / 1000000000.0) + @inSecond) / 60.0) + @inMinute) / 60.0) + @inHour) / 24.0;
	if @inMonth < 3
	begin
		set @inYear-= 1.0;
		set @inMonth+=12.0;
	end;

	declare @A int = floor(@inYear / 100.0);	
	declare @B int = 2.0 - @A + FLOOR(@A / 4.0);
	--19 , -13
	if @inYear < 1582 or ( @inYear = 1582 and @inMonth < 10)
		set @B = 0.0;

	declare @JD numeric(38, 20) = FLOOR(365.25 * (@inYear + 4716.0)) + FLOOR(30.6001 * (@inMonth + 1)) + @Fraction + @B - 1524.5;

	if @inUseDeltaT = 0
	   	 return @JD;
	
	/*	Correct for universal vs observed time.
		Ch. 10: JDE = JD - ΔT.	*/
	declare @t numeric(38,20) = (@inYear - 2000.0) / 100.0;
	declare @deltaT numeric(38,20) = 0.0;
	declare @dt1 numeric(38,20) ;
	declare @dt2 numeric(38,20) ;
	
	select top 1 @dt1 = Factor2 
	  from dbo.MeeusLookupTableValues 
	 Where TableID = (select ID from dbo.MeeusLookupTables where TableNumber = N'10.A') 
	   And Factor1 <= @inYear
	 Order by Factor1 Desc;
	
	select top 1 @dt2 = Factor2 
	  from dbo.MeeusLookupTableValues 
	 Where TableID = (select ID from dbo.MeeusLookupTables where TableNumber = N'10.A')
	   And Factor1 >= @inYear
	 Order by Factor1 Asc;
	 
	if @dt1 is null or @dt2 is null 
	begin
		if @inYear < 948
			set @deltaT = 2177.0 + 497 * @t + 44.1 * (@t * @t);
			/* 10.1, p. 78 */
		else if @inYear < 1601 or @inYear > 1999
			set @deltaT = 102.0 + 102 * @t + 25.3 * (@t * @t * @t); 
			/* 10.2, p. 78 */
		if @inYear > 1999 and @inYear < 2101
			set @deltaT = @deltaT + 0.37 * (@inYear - 2100)
	end
	else
	begin
		if @dt1 is null and @dt2 is not null
			set @dt1 = @dt2;
		else if @dt2 is null and @dt1 is not null
			set @dt2 = @dt1;
		if @dt1 > @dt2
			set @deltaT = @dt1;
		else
			set @deltaT = @dt2;
	end

	return @JD - (@deltaT / 24.0 / 60.0 / 60.0);
end;
go

/* for a given date, calculate the JD with or without  ΔT. */
Create or Alter Function dbo.fn_DateToJD(@inDate as datetime2, @inUseDeltaT as bit = 0) 
	Returns numeric(38,20) 
as
Begin
	/*
	This converts a standard date from Datetime2 format to 
		JD:  Julian Days (@inReturnsJDE = 0)	-- Days (and fractions of a day) since 01 Jan -4712 12:00:00 noon. 
		JDE: Julian Days Ephemeris				-- JD adjusted to Universal Time (corrections for differences between Dynamical and observed time)
	
	Requires Function DatePartsToJD to do the actual math.

	Assumes input is UTC / is not time-zone-aware.
	Assumes date is Gregorian unless it's before 01 Oct 1582, the generally agreed-upon date 0 in Gregorian counting.
	
	Limited by DATETIME2 range: 0001-01-01 00:00:00.000 to 9999-12-31 23:59:59.999999999
		To get negative values, will have to break this down into two functions; one for DateTime2 and one with inputs for date parts.

	Based on the algorithm presented in Ch 7, p. 59 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	--------------------------------------------------------------------------------------------------
	2022-11-11	Charles M.		First Draft
	*/
	Declare @year int  = DATEPART(year, @inDate);
	Declare @month int = DATEPART(month, @inDate);
	Declare @day int = DATEPART(day, @inDate);
	Declare @Hour int = DATEPART(hour, @inDate);
	Declare @Minute int = DATEPART(minute, @inDate);
	Declare @Second int = DATEPART(second, @inDate);
	Declare @Nano int  = DATEPART(nanosecond, @inDate);

	return dbo.fn_DatePartsToJD(@year, @month, @day, @hour, @minute, @second, @nano, @inUseDeltaT);	
end
go

/* The built in % operator doesn't handle negative values the way we need. return the remainder for dividend/divisor */
create or alter function dbo.fn_getMod( @inDividend numeric(38,19), @inDivisor numeric(38, 19) )
	returns float
as
	/*
		The built in Modulo function n % r returns incorrect values for negative dividends.
			-34086.1576962834 % 360 returns -246.157696283364
			but it should return 113.8423040
		Note that the Oracle mod(x,y) does the same thing, as does Python's math.fmod(x,y) function.
		But since Meeus' equations expect the operation to work as follows, we need a custom function to do this for us.
		---------------------------------------------------------------
		2022-11-18	CM		First Draft
	*/
begin
	--set @inDivisor += 0.0000000000000000006
	declare @Quotient float = FLOOR(@inDividend / @inDivisor);
	return @inDividend - (@Quotient * @inDivisor);
end
go

/* convert degrees, minutes, seconds to degrees */
Create or Alter Function dbo.fn_DMStoDegrees(@inDegrees as integer, @inMinutes as integer, @inSeconds as float)
	returns float
as
begin
/*
	Degrees = deg + Min/60 + sec/3600
*/
	declare @res float;
	if (@inDegrees < 0 or @inMinutes < 0 or @inSeconds < 0)
		set @res = (abs(@inDegrees) + abs(@inMinutes) / 60.0 + abs(@inSeconds) / 3600.0) * -1;
	else
		set @res = @inDegrees + @inMinutes / 60.0 + @inSeconds / 3600.0;
	return @res;
end;
go	

/* true Obliquity of the ecliptic. ε */
Create or Alter Function dbo.fn_Obliquity(@inJD as float)
	returns float 
as
/*	given a date, compute the true obliquity of the ecliptic.
	from Ch 22, p. 143-147 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	Obliquity is the angle between rotational axis and orbital axis.
	Ecliptic is the plane of the Earth's rotation around the sun. This and the equator's plane cross at vernal and and autumnal equinoxes.

	Requires table 22.a   

	22.1	p 143	T = (JDE - J2000) / 36525  --need 9+ decimals

					Mean elongation of the Moon from Sun
			p 144	D = 297.85036 + 445267.111480 * T    - 0.0019142 * T^2 + T^3 / 189474
			 		Mean anomaly of sun (earth)
			p 144	M = 357.52772 + 35999.050340 * T - 0.0001603 * T^2 - T^3 / 300000
				 	Mean anomaly of the moon
			p 144	M' = 134.96298 + 477198.867398 * T + 0.0086972 * T^2 + T^3 / 56250
				 	Moon's argument of latitude
			p 144	F = 93.27191 + 483202.017538 * T - 0.0036825 * T^2 + T^3 / 327270
				 	Longitude of ascending node of Moon's mean orbit
			p 144	Ω = 125.04452 - 1934.136261 * T + 0.0020708 * T^2 + T^3 / 450000

			unit is .0001"
	22.2	p 147	Δε =  Σ [ c+d*T cos( D+M+M'+F+Ω ) ]
	
			mean obliquity of the ecliptic
	22.2	p 147	ε0 = 23°26'21.448" - 46.815" T - 0.00059" T^2 + 0.001813" T^3
	
	However, JPL updated this to a different set of ephemerides, from the 2010 Astronomical Almanac:
	ε = 23°26′21.406″ − 46.836769″ T − 0.0001831″ T2 + 0.00200340″ T3 − 0.576×10−6″ T4 − 4.34×10−8″ T5
	Astronomical Almanac 2010, p. B52
	https://en.wikipedia.org/wiki/Ecliptic#:~:text=Obliquity%20of%20the%20ecliptic%20is,years%20because%20of%20planetary%20perturbations.

			true obliquity of ecplitic
			p 147	ε = ε0 + Δε
*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180.0;
	Declare @T  float = (@inJD - 2451545) / 36525;
	Declare @D  float = 297.85036 + 445267.111480 * @T - 0.0019142 * (@T * @T) + (@T * @T * @T) / 189474.0;
	Declare @M  float = 357.52772 + 35999.050340 * @T - 0.0001603 * (@T * @T) + (@T * @T * @T) / 300000.0;
	Declare @Mp float = 134.96298 + 477198.867398 * @T + 0.0086972 * (@T * @T) + (@T * @T * @T) / 56250.0;
	Declare @F  float = 93.27191 + 483202.017538 * @T - 0.0036825 * (@T * @T) + (@T * @T * @T) / 327270.0;
	Declare @Om float = 125.04452 - 1934.136261 * @T + 0.0020708 * (@T * @T) + (@T * @T * @T) / 450000.0;	
	Declare @de float;

	select @de = sum( (Factor8 + Factor9 * @T) * COS((Factor1 * @D + Factor2 * @M + Factor3 * @Mp + Factor4 * @F + Factor5 * @Om) * @Deg2Rad) )
	  from dbo.MeeusLookupTableValues
     where TableID = (Select ID from dbo.MeeusLookupTables where TableNumber = N'22.A'); 

	--declare @e0 float = dbo.fn_DMStoDegrees(23, 26, 21.448) - dbo.fn_DMStoDegrees(0, 0, 46.815) * @T
	--					- dbo.fn_DMStoDegrees(0, 0, 0.00059) * (@T * @T) + dbo.fn_DMStoDegrees(0, 0, 0.001813) * (@T * @T * @T);
	-- 23°26′21.406″ − 46.836769″ T − 0.0001831″ T2 + 0.00200340″ T3 − 0.576×10−6″ T4 − 4.34×10−8″ T5
	declare @e0 float =   dbo.fn_DMStoDegrees(23, 26, 21.406) 
						- dbo.fn_DMStoDegrees(0, 0, 46.836769) * @T
						- dbo.fn_DMStoDegrees(0, 0, 0.0001831) * (@T * @T) 
						+ dbo.fn_DMStoDegrees(0, 0, 0.00200340) * (@T * @T * @T)
						- dbo.fn_DMStoDegrees(0, 0, 0.000000576) * (@T * @T * @T * @T)
						- dbo.fn_DMStoDegrees(0, 0, 0.00000000434) * (@T * @T * @T * @T * @T);

	return (@de  * 0.0001) / 3600.0 + @e0;
end;
go


/*

Create or Alter Function dbo.SolarDeclination(@inJD as Float)
returns Float
as


342	Δ = 385000.56 + Σr / 1000



	T = (JDE - J2000) / 36525 
	to 9 + Float places

	Longitude of ascending node of Moon's mean orbit
			p. 144,		Ω = 125.04452 - 1934.136261 * T + 0.0020708 * T^2 + T^3 / 450000



	mean obliquity of the ecliptic
	22.2	p. 147		ε0 = 23°26'21.448" - 46.815" T - 0.00059" T^2 + 0.001813" T^3
			p. 144		Δε = 9.20" cos Ω + 0.57" cos 2L + 0.10" cos 2L' - 0.09" cos 2Ω
	True obcliquity of ecliptic 
			p. 147		εt = ε0 + Δε

	Apparent ascension of Sun
	25.8	p. 165		ε = εt + 0.00256° cos Ω)

	declination sun δ0
						δa = asin( sin ε sin λ )


begin

	return 0
end;
go



*/