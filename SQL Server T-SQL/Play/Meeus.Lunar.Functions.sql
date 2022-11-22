/*
	These functions perform various selected calculations relating to the Moon, as found in 
	"Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	
	Several of these rely on tables of factors, found in Meeus.LookupTables.sql.

	Functions found here:

	dbo.fn_LunarDistance(@inJD as Float)										Calculates the distance from Earth to Moon in KM for a given Julian Days value.

	dbo.fn_LunarLatitude(@inJD)													Compute the Latitude of the Moon
	dbo.fn_LunarLongitude(@inJD)												Compute the Longitude of the Moon
		λ  = Longitude°
		β  = Latitude°


	dbo.fn_LunarAscension(@inLatitude, @inLongitude, @inObliquity)
dbo.fn_LunarDeclination
dbo.fn_LunarIllumination
	

		δ  = declination of the moon
		α  = geocentric right ascension of the moon

	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
	declare @Rad2Deg Float = 180 / 3.1415926535897932384626433832795028 ;
*/





/* Distance Moon to Earth (Δ) in km */
Create or Alter Function dbo.fn_LunarDistance(@inJD as Float)
returns Float
as
/*	given a date, Compute the distance from Earth to Moon in kilometers.
	from Ch 47, p. 338-392 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	
	Requires lookup values from table 47.A.

	T = (JDE - J2000) / 36525

	Mean elongation of moon
	47.2	p. 338		D = 297.8501921 + 445267.1114034 T
						- 0.0018819 T^2 + T^3 / 545868
						- T^4 / 113065000
	Sun's mean anomaly
	47.3	p. 338		M = 357.5291092 + 35999.0502909 T
						- 0.0001536 T^2 + T^3 / 24490000

	Moon's mean anomaly
	47.4	p. 338		M' = 134.9633964 + 477198.8675055 T
						+ 0.0087414 T^2 + T^3 / 69699
						- T^4 / 14712000
	
	47.6	p. 338		E = 1 - 0.002516 T - 0.0000074 T^2

	Moon's argument of latitude
	47.5	p. 338		F = 93.2720950 + 483202.0175233 T
						- 0.0036539 T^2 - T^3 / 3526000
						+ T^4 / 863310000
	
			p. 339		Σr = Σ [ x cos (D+M+M'+F) ]
						if E= 1, then M * E, if E=2, then M*E^2						
						or  cols F *  cos((A+B+C+D) * Deg2Rad)

	Distance Earth-Moon
			p. 342		Δ km = 385000.56 + Σr / 1000
	--------------------------------------------------------------------------------------------------
	2022-11-14	Charles M.		First Draft
	*/
Begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
declare @T  Float = (@inJD - 2451545.00) / 36525.00;
	declare @D  Float = 297.8501921 + 445267.1114034 * @T
						- 0.0018819 * (@T * @T) 
						+ (@T * @T * @T) / 545868
						- (@T * @T * @T * @T) / 113065000;
	declare @M  Float = 357.5291092 + 35999.0502909 * @T
						- 0.0001536 * (@t * @T) 
						+ (@T * @T * @T) / 24490000;
	declare @Mp Float = 134.9633964 + 477198.8675055 * @T
						+ 0.0087414 * (@t * @T) 
						+ (@T * @T * @T) / 69699
						- (@T * @T * @T * @T) / 14712000;
	declare @F  Float = 93.2720950 + 483202.0175233 * @T
						- 0.0036539 * (@T * @T) 
						- (@T * @T * @T) / 3526000
						+  (@T * @T * @T * @T) / 863310000;
	set @D = dbo.fn_getMod(@D, 360.0);
	set @M = dbo.fn_getMod(@M, 360.0);
	set @MP = dbo.fn_getMod(@Mp, 360.0);
	set @F = dbo.fn_getMod(@F, 360.0);
	declare @E Float = 1 - 0.002516 * @T - 0.0000074 * (@T * @T);

	declare @Sr Float;
	select @Sr = sum (Factor6 * (case when abs(Factor2) = 1.0 then @E when abs(Factor2) = 2.0 then @E * @E else 1 end) * COS((Factor1 * @D + Factor2 * @M + Factor3 * @Mp + Factor4 * @F) * @Deg2Rad) )
	  from dbo.MeeusLookupTableValues
     where TableID = (Select ID from dbo.MeeusLookupTables where TableNumber = N'47.A')

	return 385000.56 + @Sr / 1000.0;
end
go

/* latitude of the moon β°  */
Create or Alter Function dbo.fn_LunarLatitude(@inJD Float)
returns Float
as
/*	given a date, Compute the Latitude of the Moon
	from Ch 47, p. 338-392 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	Requires lookup values from Table 47.B.

	22.1	p. 143		T = (JDE - J2000) / 36525

	Mean elongation of moon
	47.2	p. 338		D = 297.8501921 + 445267.1114034 T
						- 0.0018819 T^2 + T^3 / 545868
						- T^4 / 113065000
	Sun's mean anomaly
	47.3	p. 338		M = 357.5291092 + 35999.0502909 T
						- 0.0001536 T^2 + T^3 / 24490000

	Moon's mean anomaly
	47.4	p. 338		M' = 134.9633964 + 477198.8675055 T
						+ 0.0087414 T^2 + T^3 / 69699
						- T^4 / 14712000
	
	47.6	p. 338		E = 1 - 0.002516 T - 0.0000074 T^2

	Moon's argument of latitude
	47.5	p. 338		F = 93.2720950 + 483202.0175233 T
						- 0.0036539 T^2 - T^3 / 3526000
						+ T^4 / 863310000

			p. 340		Σb = Σ [ x cos (D+M+M'+F) ]
						if E= 1, then M * E, if E=2, then M*E^2						
						or  cols F *  cos((A+B+C+D) * Deg2Rad)	
	
	Venus action additives
			p. 338		A1 = 119.75 + 131.849 * T
	
						A3 = 313.45 + 481266.484 * T

			p. 342		Additive to Σb -2235 sin L'
									  +  382 sin A3
									  +  175 sin (A1 - F)
									  +  175 sin (a1 + F)
									  +  127 sin (L' - M')
									  -  115 sin (L' + M')

	Moon's mean longitude:
	47.1	p. 338		L' = 218.3164477 + 481267.88123421 T
					    - 0.0015786 T^2 + T^3 / 538841
					    - T^4 / 65194000

	latitude
			P. 342		β = Σb /1000000

	--------------------------------------------------------------------------------------------------
	2022-11-14	Charles M.		First Draft
	
	*/
Begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
	declare @T  Float = (@inJD - 2451545.000) / 36525.000;
	declare @D  Float = 297.8501921 + 445267.1114034 * @T
						- 0.0018819 * (@T * @T) 
						+ (@T * @T * @T) / 545868
						- (@T * @T * @T * @T) / 113065000;
	declare @M  Float = 357.5291092 + 35999.0502909 * @T
						- 0.0001536 * (@t * @T) 
						+ (@T * @T * @T) / 24490000;
	declare @Mp Float = 134.9633964 + 477198.8675055 * @T
						+ 0.0087414 * (@t * @T) 
						+ (@T * @T * @T) / 69699
						- (@T * @T * @T * @T) / 14712000;
	declare @F  Float = 93.2720950 + 483202.0175233 * @T
						- 0.0036539 * (@T * @T) 
						- (@T * @T * @T) / 3526000
						+  (@T * @T * @T * @T) / 863310000;

	Declare @E float = 1.0 - 0.002516 * @T - 0.0000074 * @T * @T;

	DECLARE @Lp Float = 218.3164477 + 481267.88123421 * @T
						- 0.0015786 * (@T * @T) + (@T * @T * @T) / 538841
						- (@T * @T * @T * @T) / 65194000;

	set @D = dbo.fn_getMod(@D, 360.0);
	set @M = dbo.fn_getMod(@M, 360.0);
	set @MP = dbo.fn_getMod(@Mp, 360.0);
	set @F = dbo.fn_getMod(@F, 360.0);
	set @Lp = dbo.fn_getMod(@Lp, 360.0);

	Declare @A1 Float = dbo.fn_getMod(119.75 + 131.849 * @T, 360.0);
	Declare @A3 Float =  dbo.fn_getMod(313.45 + 481266.484 * @T, 360.0);

	declare @Sb Float;

	select @Sb = sum(Factor5 * (case when abs(Factor2) = 1.0 then @E when abs(Factor2) = 2.0 then @E * @E else 1 end) * SIN((Factor1 * @D + Factor2 * @M + Factor3 * @Mp + Factor4 * @F) *  @Deg2Rad))
	  from dbo.MeeusLookupTableValues
     where TableID = (Select ID from dbo.MeeusLookupTables where TableNumber = N'47.B');
 
	set @Sb = @Sb
				 - 2235 * SIN(@Lp * @Deg2rad)
				 +  382 * SIN(@A3 * @Deg2Rad)
				 +  175 * SIN((@A1 - @F) * @Deg2Rad)  
				 +  175 * SIN((@A1 + @F) * @Deg2Rad) 
				 +  127 * SIN((@Lp - @Mp) * @Deg2Rad) 
				 -  115 * SIN((@Lp + @Mp) * @Deg2Rad);

	return @Sb / 1000000.000 ;
end;
go

/* longitude of the moon λ° */
Create or Alter Function dbo.fn_LunarLongitude(@inJD Float)
returns Float
as
/*	given a date, Compute the Latitude of the Moon
	from Ch 47, p. 338-392 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	Requires lookup values from Table 47.A

	22.1	p. 143		T = (JDE - J2000) / 36525

	Mean elongation of moon
	47.2	p. 338		D = 297.8501921 + 445267.1114034 T
						- 0.0018819 T^2 + T^3 / 545868
						- T^4 / 113065000
	Sun's mean anomaly
	47.3	p. 338		M = 357.5291092 + 35999.0502909 T
						- 0.0001536 T^2 + T^3 / 24490000

	Moon's mean anomaly
	47.4	p. 338		M' = 134.9633964 + 477198.8675055 T
						+ 0.0087414 T^2 + T^3 / 69699
						- T^4 / 14712000
	
	47.6	p. 338		E = 1 - 0.002516 T - 0.0000074 T^2

	Moon's argument of latitude
	47.5	p. 338		F = 93.2720950 + 483202.0175233 T
						- 0.0036539 T^2 - T^3 / 3526000
						+ T^4 / 863310000

			p. 340		Σb = Σ [ x cos (D+M+M'+F) ]
						if E= 1, then M * E, if E=2, then M*E^2						
						or  cols F *  cos((A+B+C+D) * Deg2Rad)	
	
	Moon's mean longitude:
	47.1	p. 338		L' = 218.3164477 + 481267.88123421 T
					    - 0.0015786 T^2 + T^3 / 538841
					    - T^4 / 65194000


	--------------------------------------------------------------------------------------------------
	2022-11-14	Charles M.		First Draft
	
	*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
	declare @T  Float = (@inJD - 2451545.000) / 36525.000;
	declare @D  Float = 297.8501921 + 445267.1114034 * @T
						- 0.0018819 * (@T * @T) 
						+ (@T * @T * @T) / 545868
						- (@T * @T * @T * @T) / 113065000;
	declare @M  Float = 357.5291092 + 35999.0502909 * @T
						- 0.0001536 * (@t * @T) 
						+ (@T * @T * @T) / 24490000;
	declare @Mp Float = 134.9633964 + 477198.8675055 * @T
						+ 0.0087414 * (@t * @T) 
						+ (@T * @T * @T) / 69699
						- (@T * @T * @T * @T) / 14712000;
	declare @F  Float = 93.2720950 + 483202.0175233 * @T
						- 0.0036539 * (@T * @T) 
						- (@T * @T * @T) / 3526000
						+  (@T * @T * @T * @T) / 863310000;
	Declare @E float = 1.0 - 0.002516 * @T - 0.0000074 * @T * @T;
	DECLARE @Lp Float = 218.3164477 + 481267.88123421 * @T
						- 0.0015786 * (@T * @T) + (@T * @T * @T) / 538841
						- (@T * @T * @T * @T) / 65194000;
	set @D = dbo.fn_getMod(@D, 360.0);
	set @M = dbo.fn_getMod(@M, 360.0);
	set @MP = dbo.fn_getMod(@Mp, 360.0);
	set @F = dbo.fn_getMod(@F, 360.0);
	set @Lp = dbo.fn_getMod(@Lp, 360.0);

	Declare @Sl Float;

	select @Sl = sum(Factor5 * (case when abs(Factor2) = 1.0 then @E when abs(Factor2) = 2.0 then @E * @E else 1 end) * SIN((Factor1 * @D + Factor2 * @M + Factor3 * @Mp + Factor4 * @F) *  @Deg2Rad))
	  from dbo.MeeusLookupTableValues
     where TableID = (Select ID from dbo.MeeusLookupTables where TableNumber = N'47.A'); 

	return  @Lp + @Sl / 1000000.000 ;
end;
go

/* calculate moon's right ascension. α from lat β°, long λ°, obliquity ε */
Create or Alter Function dbo.fn_LunarAscension(@inJD Float)
returns Float
as
/*		given input, compute the moon's geocentric right ascension.
		from Ch 13 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
		Requires dbo.fn_LunarLatitude, dbo.fn_LunarLongitude, dbo.fn_Obliquity

		13.3	p. 93	tan α = (sin λ cos ε - tan β sin ε) / cos λ
						α = ATAN2( (sin λ cos ε - tan β sin ε) , cos λ)
		β = Latitude	
		λ = Longitude	
		ε = Obliquity of the ecliptic.		
*/
begin
	declare @Latitude float = dbo.fn_LunarLatitude(@inJD);
	declare @Longitude float =  dbo.fn_LunarLongitude(@inJD);
	declare @Obliquity float = dbo.fn_Obliquity(@inJD);
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
	declare @Rad2Deg Float = 180 / 3.1415926535897932384626433832795028 ;
	declare @e1 Float = (SIN(@Longitude * @deg2Rad) * COS(@Obliquity * @Deg2Rad) - TAN(@Latitude * @Deg2Rad) * SIN(@Obliquity * @Deg2Rad));
	declare @e2 Float = COS(@Longitude * @Deg2Rad);

	return ATN2(@e1, @e2) * @rad2Deg;
end;
go

/* Moon's apparent declination δ */
Create or Alter function dbo.fn_LunarDeclination(@inJD as float)
	returns float
as
/*	From Ch 47, p. 337-343 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.

					β°,				λ°,					ε
	Requires fn_LunarLatitude, fn_LunarLongitude, fn_Obliquity.
	13.4	343	Moon's apparent declination
				sin δ = sin β cos ε + cos β sin ε sin λ
				δ = ASIN( sin β cos ε + cos β sin ε sin λ ) * rad2deg
*/
begin
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028 / 180.0;
	declare @Rad2Deg float = 180.0 / 3.1415926535897932384626433832795028;

	declare @Lat float = dbo.fn_LunarLatitude(@inJD);
	declare @Lon float = dbo.fn_LunarLongitude(@inJD);
	declare @Obl float = dbo.fn_Obliquity(@inJD);

	Declare @f1 float = sin(@Lat * @deg2rad);
	declare @f2 float = cos(@Obl * @deg2rad);
	declare @f3 float = cos(@lat * @deg2rad);
	declare @f4 float = sin(@Obl * @deg2rad);
	declare @f5 float = sin(@lon * @deg2rad);

	return asin(@f1 * @f2 + @f3 * @f4 * @f5) * @rad2deg;
end;
go


/* Returns a percentage (1 = full) of the moon that is illuminated */
Create or Alter Function dbo.fn_LunarIllumination(@inJD as Float, @inApproximate as bit)
	returns Float									
as
	/* given a date, compute the percentage of face of the moon that's illuminated.

		requires fn_LunarDistance, fn_LunarDeclination, fn_LunarAscension
				 fn_SolarDistance, fn_SolarDeclination, fn_SolarAscension

		from Ch 48, p 345 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
		α	geocentric right ascension Moon	
		Δ	Distance Earth-moon (Km)	
		R	Distance Earth-Sun (AU)		
		ψ	geocentric elongation of the moon from sun
		δ	declination moon
		δ0	declination sun
		α0	geocentric right ascension Sun	

		1 AU = 149597870.691 km

		Sun's apparent declination
					ε0 = obliquity
					ε = ε0 + 0.00256° cos Ω
			p 165	δa = asin( sin ε sin λ )

	48.2	p 345	cos ψ = sin δ0 sin δ
						+ cos δ0 cos δ cos(α0 - α)
					ψ = acos(  sin δ0 sin δ
						+ cos δ0 cos δ cos(α0 - α)  ) *rad2deg

	48.4	p 346	approximate i
					i = 180 - D - 6.289 * sin( M' )
					    + 2.1 * sin( M )
					    - 1.274 * sin( 2*D - M' )
					    - 0.658 * sin( 2*D)
					    - 0.214 * sin( 2*M' )
					    - 0.110 * sin( D );

	48.3	p 346	tan i = (R sin ψ) / (Δ - R cos ψ)
					i = atan2( (Δ - R cos ψ),  (R sin ψ) )

	38.1	p 345	k = (1 + cos i) / 2		
	--------------------------------------------------------------------------------------------------
	2022-11-14	Charles M.		First Draft
	*/
begin	
	declare @Deg2Rad Float = 3.1415926535897932384626433832795028 / 180.0;
	declare @Rad2Deg Float = 180.0 / 3.1415926535897932384626433832795028;
	declare @Au2Km   float = 149597870.691;
	declare @i       float;
	declare @k		 float;
	if @inApproximate = 1
	begin
		/* Approximation method isn't as accurate: */
		declare @T  Float = (@inJD - 2451545.000) / 36525.000;
		declare @D  Float = 297.8501921 + 445267.1114034 * @T
							- 0.0018819 * (@T * @T) 
							+ (@T * @T * @T) / 545868
							- (@T * @T * @T * @T) / 113065000;
		declare @M  Float = 357.5291092 + 35999.0502909 * @T
							- 0.0001536 * (@t * @T) 
							+ (@T * @T * @T) / 24490000;
		declare @Mp Float = 134.9633964 + 477198.8675055 * @T
							+ 0.0087414 * (@t * @T) 
							+ (@T * @T * @T) / 69699
							- (@T * @T * @T * @T) / 14712000;
		set @D  = dbo.fn_getMod(@D, 360.0);
		set @M  = dbo.fn_getMod(@M, 360.0);
		set @Mp = dbo.fn_getMod(@Mp, 360.0);
		set @i  = 180 - @D - 6.289 * sin( @Mp * @deg2rad )
						    + 2.1 * sin( @M * @deg2rad )
						    - 1.274 * sin((2 * @D - @Mp) * @Deg2rad )
						    - 0.658 * sin((2 * @D) * @deg2rad)
						    - 0.214 * sin((2 * @Mp)  * @deg2rad)
						    - 0.110 * sin(@D * @deg2rad);
		set @k =  (1 + COS(@i * @deg2rad)) / 2;
	end
	else
	begin
		/* i = atan2( (Δ - R cos ψ),  (R sin ψ) )   */
		declare @lunDecl float = dbo.fn_lunarDeclination(@inJD);	/* δ  lunar declination            */
		declare @solDecl float = dbo.fn_solarDeclination(@inJD, 1);	/* δ0 solar apparent declination   */
		declare @lunAsc  float = dbo.fn_LunarAscension(@inJD);		/* α  lunar ascension              */
		declare @solAsc  float = dbo.fn_SolarAscension(@inJD, 1);	/* α0 solar apparent ascension     */
		declare @lunDist float = dbo.fn_LunarDistance(@inJD);		/* Δ  Distance Earth to moon in Km */
		declare @solDist float = dbo.fn_SolarDistance(@inJD);		/* R  distance earth to sun in AU  */
		set @solDist = @solDist * @Au2Km;
		/* ψ  elongation of the moon from sun */
		declare @f1 float = SIN(@solDecl * @Deg2Rad);
		declare @f2 float = SIN(@lunDecl * @Deg2Rad);
		declare @f3 float = COS(@solDecl * @Deg2Rad);
		declare @f4 float = COS(@lunDecl * @Deg2Rad);
		declare @f5 float = COS((@solAsc - @lunAsc) * @Deg2Rad);
		declare @elong float = ACOS(@F1 * @F2 + @f3 * @f4 *  @f5) * @rad2Deg;
 
		set @i = atn2( (@solDist * sin(@elong * @Deg2rad)) , (@lunDist - @solDist * cos(@elong * @deg2rad)) ) ;
		set @k = (1 + COS(@i )) / 2
	end;
	return @k
end
go

/* get % iluminated and position angle of illuminated limb χ to return text phase
	inMode 1 = text only, 2 = unicode symbol only, 3 = text+unicode, 4 = unicode+text */
Create or Alter Function dbo.fn_LunarPhase(@inJD as Float, @inMode tinyint)
	returns nvarchar(50)
as
/*	From Ch 48 of "Astronomical Algorithms Second Edition" by Jean Meeus, (c) 1998.
	requires dbo.fn_LunarIllumination, fn_LunarDeclination, fn_LunarAscension, fn_getMod
	

	 δ	Lunar Declination
	 α	Lunar ascension
	 δ0	Solar Declination
	 α0	Solar ascension

	k = lunar illumination as percentage
	48.5	p 346	position angle of the midpoint of illuminated limb
					f1 = sin δ0 cos δ - cos δ0 sin δ cos (α0 - α)
					f2 = cos δ0 sin(α0 - α) 
					χ = atan2 ( f1, f2)   * rad2deg

	The exact definition of what % = what phase is kind of subjective, or at least I'm not finding good notes on where
	the division between phases lies...
	🌑 new moon  🌒 waxing crescent. 🌓 1st qtr 🌔 Waxing gibbous
	🌕 full moon 🌖 waning gibbous. 🌗 last qtr 🌘 waning crescent
*/
begin
	declare @code nvarchar(1) = N'';
	declare @text nvarchar(45) = N'';
	declare @k float = dbo.fn_LunarIllumination(@inJD, 1);
	declare @outText nvarchar(50) = N'';
/*
	0.0000	0.0030	New
	0.0031	0.4525	Crescent
	0.4526	0.5425	Quarter
	0.5426	0.988	Gibbous
	0.9876	1.00	Full

*/
	if @k < 0.0030
	begin
		set @text = N'New';
		set @code = N'🌑';
	end
	if @k > 0.9876
	begin
		set @text = N'Full';
		set @code = N'🌕';
	end
	if @k > 0.0030 and @k < 0.9876
	begin
		declare @Deg2Rad Float = 3.1415926535897932384626433832795028  / 180;
		declare @Rad2Deg Float = 180 / 3.1415926535897932384626433832795028 ;
		--declare @LunarLat  float = dbo.fn_LunarLatitude(@inJD);		/* β */
		--declare @lunarLon  float = dbo.fn_LunarLongitude(@inJD);	/* λ */
		--declare @Obliquity float = dbo.fn_Obliquity(@inJD);			/* ε */
		declare @lunarDecl float = dbo.fn_LunarDeclination(@inJD);		/* δ  */
		declare @lunarAsc  float = dbo.fn_LunarAscension(@inJD);		/* α  */
		declare @solarDecl float = dbo.fn_SolarDeclination(@inJD, 1);	/* δ0 */
		declare @SolarAsc  float = dbo.fn_SolarAscension(@inJD, 1);		/* α0 */
		declare @f1 float = cos(@solarDecl * @Deg2Rad) * sin((@SolarAsc - @lunarAsc) * @Deg2Rad);
		declare @f2 float = sin(@solarDecl * @Deg2Rad)  * cos(@lunarDecl * @Deg2Rad) 
						  - cos(@solarDecl * @Deg2Rad)  * sin(@lunarDecl * @Deg2Rad) 
						  * cos((@SolarAsc - @lunarAsc) * @Deg2Rad);
		declare @x float = atn2(@f1, @f2) * @rad2deg;
		set @x = dbo.fn_getMod(@x, 360.0);
		declare @flag tinyint = 0;
		
		if @k > 0.003 and @k < 0.4526
			set @flag = 1;		--set @Text += N' Crescent';
		if @k > 0.4525 and @k < 0.5426
			set @flag = 2;		--set @text += N' Quarter';
		if @k > 0.5425 and @k < 0.989
			set @flag = 3;		--set @text += N' Gibbous';
		if @x > 200.0
			set @flag *= 10;	--	set @text = N'Waxing'
 
		if @flag = 1
		begin
			set @code = N'🌘';
			set @text = N'Waning Crescent';
		end
		else if @flag = 2
		begin
			set @code = N'🌗';
			set @text = N'Last Quarter';
		End
		else if @flag = 3
		begin
			set @code = N'🌖';
			set @text = N'Waning Gibbous';
		End
		else if @flag = 10
		begin
			set @code = N'🌒';
			set @text = N'Waxing Crescent';
		end
		else if @flag = 20
		begin
			set @code = N'🌓';
			set @text = N'First Quarter';
		End
		else if @flag = 30
		begin
			set @code = N'🌔';
			set @text = N'Waxing Gibbous';
		End
	end
	/* 	inMode 1 = text only, 2 = unicode symbol only, 3 = text+unicode, 4 = unicode+text */
	if @inMode = 1
		set @outText = @text;
	else if @inMode = 2
		set @outText = @code;
	else if @inMode = 3
		set @outText = @text + ' ' + @code;
	else if @inMode = 4
		set @outText =  @code + ' ' + @text;
	else
		set @outText = 'No valid inMode supplied.';

	return @outText;
end;




/*
==========================================================================================
latitude:	MoonPos:E66

		342	β = Σb /1000000
			Σb = 47a47b:i10

	342	Σb = Σb
		- 2235 sin L'
	    +  382 sin A3
	    +  175 sin (A1 - F)
	    +  175 sin (a1 + F)
	    +  127 sin (L' - M')
	    -  115 sin (L' + M')

longitude:	MoonPos:E74


	Moon's mean longitude:
	47.1	338	
				L' = 218.3164477 + 481267.88123421 T
				    - 0.0015786 T^2 + T^3 / 538841
				    - T^4 / 65194000
	Nutation in longitude	Δψ	nUTATION:E21
		 P 144	Δψ = -17.20" sin Ω - - 1.32" sin 2L - 0.23" sin 2L' + 0.21" sin 2Ω

	longitude
		342	λ = L' + Σl/1000000
	apparent longitude
			343	apparent λ = λ + Δψ

Obliquity:	Nutation:E43
*/



