/*
	These functions perform various selected calculations related to the Sun, as found in 
	"Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	
	Several of these rely on tables of factors, found in Meeus.LookupTables.sql.

	Functions found here:

	dbo.fn_SolarDistance(@inJD as Float)									Calculates the distance from Earth to Sun in AU for a given Julian Days value.
																			1 AU = 149597870.691 km
dbo.fn_SolarLongitude
dbo.fn_SolarDeclination
*/

/*	Returns distance from Earth to Sun in AU. R. */
Create or Alter Function dbo.fn_SolarDistance(@inJD as Float)
returns Float
as
	/* given a Julian Day, approximate the radius vector of (distance to) the sun, in AU.
		from Ch 25, p 164 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.

		p 218, τ = (JDE - 2451545.0) / 365250
		p 218, T = 10τ
		
		25.3, p	163		mean anomaly of the Sun
		M = 357.52911° + 35999.05029° * T - 0.0001537° * T^3

		p 164	Sun's equation of the center C
		C = (1.914602° - 0.004817° T - 0.000014° * T^2) sin M
			+ (0.019993° - 0.000101° *T) sin 2M
			+ 0.000289° sin 3M
				
		25.4, p 163		Eccentricity of Earth's orbit
		e = 0.016708634 - 0.000042037 T - 0.0000001267*T^2
		
		p 164			Sun's true anomaly 
		v = M + C

		25.5, p 164		Sun's radius vector in AU
		R = (1.000001018 (1-e^2) ) / (1 + e cos v)
	--------------------------------------------------------------------------------------------------
	2022-11-14	Charles M.		First Draft
	*/
begin
		declare @Deg2Rad Float = pi() / 180;
		declare @t1 Float = (@inJD - 2451545.0) / 365250.0;
		declare @T Float = 10 * @t1;
		declare @M Float = 357.52911 + 35999.05029 * @T - 0.0001537 * (@T * @T * @T);
		declare @C Float = (1.914602 - 0.004817 * @T - 0.000014 * (@T * @T)) * SIN(@M * @Deg2Rad)
				+ (0.019993 - 0.000101 * @T) * sin(2 * @M * @deg2rad)
				+ 0.000289 * sin(3 * @M * @Deg2Rad);
		declare @e Float = 0.016708634 - 0.000042037 * @T - 0.0000001267 * (@T * @T);
		declare @v Float = @M + @C

		return (1.000001018 * (1 - (@e * @e)) ) / (1 + @e * cos(@v * @deg2rad));

end;
go

/* return solar longitude Θ */
create or alter function dbo.fn_SolarLongitude(@inJD as float, @inIsApparent as bit)
	returns float
as
/*
	adapted from Ch 25 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	requires fn_getMod.

	Eq#		p
			218		τ = (JDE - 2451545.0) / 365250
			219		T = 10τ

	25.2	163	geometric mean longitude of the Sun
					L0 = 280.46646° + 36000.76983° T + 0.0003032° * T^2

	25.3	163	mean anomaly of the Sun
					M = 357.52911° + 35999.05029° * T - 0.0001537° * T^3

			164	Sun's equation of the center C
					C = (1.914602° - 0.004817° T - 0.000014° * T^2) sin M
						+ (0.019993° - 0.000101° *T) sin 2M
						+ 0.000289° sin 3M

				Sun's true geometric mean longitude
			164		Θ = L0 + C

			164	apparent longitude of the sun
				Ω = 125.04° - 1934.136° * T
				λ = Θ - 0.00569° - 0.00478° sin Ω

*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
	declare @T float = 10 * ((@inJD - 2451545.0) / 365250.0);
	declare @L float = 280.46646 + 36000.76983 * @T + 0.0003032 * (@T * @T);
	declare @M float = 357.52911 + 35999.05029 * @T - 0.0001537 * (@T * @T * @T);
	declare @C float  =  (1.914602 - 0.004817 * @T 
						- 0.000014 * (@T * @T)) * sin(@M * @deg2rad)
						+ (0.019993 - 0.000101 * @T) * sin(2 * @M * @deg2rad)
						+ 0.000289 * sin(3 * @M * @deg2rad);
	declare @lon float = @L + @C; /* Θ */
	if @inIsApparent = 1
	begin
		declare @Om float = 125.04 - 1934.136 * @T;
		set @lon = @lon - 0.00569 - 0.00478 * sin(@om * @deg2rad);
	end
	return dbo.fn_getMod(@lon, 360);
end;
go

/* Solar Declination  δ0 */
Create or Alter Function dbo.fn_SolarDeclination(@inJD as float, @inIsApparent as bit)
	returns float
as
/*
	adapted from Ch 25 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	Requires fn_Obliquity, fn_SolarLongitude, fn_getMod
	 ε0 = obliquity
	 Θ  = longitude
		Sun's declination
	25.7	p 165	sin δ = sin ε0 sin Θ
					δ = asin( sin ε0 sin Θ )

			Sun's apparent declination
			p 218	τ = (JDE - 2451545.0) / 365250
			p 219	T = 10τ
			p 164	Ω = 125.04° - 1934.136° * T
			p 165	ε = ε0 + 0.00256° cos Ω
			p 165	δa = asin( sin ε sin λ )
*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028 / 180.0;
	declare @Rad2Deg Float = 180.0 / 3.1415926535897932384626433832795028;
	declare @decl float;
	declare @e0 float = dbo.fn_Obliquity(@inJD);
	declare @lon float

	if @inIsApparent = 0
	begin		
		set @lon = dbo.fn_solarLongitude(@inJD, 0);
		set @decl = asin( sin(@e0 * @deg2rad) * sin(@lon * @deg2rad) );
	end
	else
	begin
		declare @T float = ( (@inJD - 2451545.0) / 365250.0) * 10;
		declare @om float = 125.04 - 1934.136 * @T;
		declare @e float = @e0 + 0.00256 * cos(@om * @deg2rad);
		set @lon = dbo.fn_solarLongitude(@inJD, 1);
		--sin om 8 sin lon
		set @decl = asin( sin(@e * @deg2rad) * sin(@lon * @deg2rad) );
	end
	return @decl * @rad2Deg;
end;
go

/* geocentric right ascension Sun  α0 */
Create or Alter Function dbo.fn_SolarAscension(@inJD as float, @inIsApparent as bit)
	returns float
as
/*
	adapted from Ch 25 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	Requires dbo.fn_Obliquity, dbo.fn_SolarLongitude

				ε0 obliquity of the ecliptic
				Θ  True geometric mean longitude
				λ  apparent longitude

				time in Julian millennia
				p 218	τ = (JDE - 2451545.0) / 365250
				p 219	T = 10τ

		Sun's right ascension
		25.6	p 165	tan α = (cos ε0 sin Θ) / cos Θ
						α = atan2 (cos Θ , (cos ε0 sin Θ) )

		apparent longitude of the sun
				p 164	Ω = 125.04° - 1934.136° * T
						λ = Θ - 0.00569° - 0.00478° sin Ω

		Apparent ascension of Sun
		25.8	p 165	ε = ε0 + 0.00256° cos Ω
						α = atan2 (cos λ , (cos ε sin λ) )
*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028 / 180;
	declare @Rad2Deg Float = 180 / 3.1415926535897932384626433832795028;
	declare @T float = 10 * ((@inJD - 2451545.0) / 365250.0);
	declare @e0 float = dbo.fn_Obliquity(@inJD);
	declare @lon float;
	declare @asc float;
	if @inIsApparent = 0
	begin
		set @lon = dbo.fn_SolarLongitude(@inJD, 0);		/*  Θ solar longitude */
	end
	else
	begin
		declare @om  float = 125.04 - 1934.136 * @T;	/* Ω  */
		set @e0 = @e0 + 0.00256 * cos(@om * @Deg2Rad);	
		set @lon = dbo.fn_SolarLongitude(@inJD, 1);		/*  λ solar longitude, apparent */
	end

	set @asc = atn2( (cos(@e0 * @deg2rad) * sin(@lon * @deg2rad)), cos(@lon * @deg2Rad) );
	return dbo.fn_getMod(@asc * @rad2deg, 360);
end;
go
