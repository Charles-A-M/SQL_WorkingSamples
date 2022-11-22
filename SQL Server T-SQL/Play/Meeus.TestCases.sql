drop table if exists #TestValues;
go
create table #TestValues (
	ID int not null identity primary key, 
	Chapter nvarchar(20), 
	inDate datetime2, 
	inYear int, inMonth int, inDay int, inHour int, inMinute int, inSecond int, inNano int, 
	JD Float, JDE Float,
	Sr Float, 
	Delta Float, 
	R Float, 
	lunarLatitude Float,  lunarLongitude Float, LunarDistance Float,
	lunarObliquity float, lunarIlluminationExact float, lunarIllumination float,
	LunarPhase nvarchar(50),
	solarDistance Float);

insert into #TestValues (chapter, indate) values ('7.a',		cast('1957-10-04 19:26:24' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.b',		cast('0333-01-27 12:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.1/8',	cast('2000-01-01 12:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.2',		cast('1999-01-01 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.3',		cast('1987-01-27 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.4',		cast('1987-06-19 12:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.5',		cast('1988-01-27 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.6',		cast('1988-06-19 12:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.7',		cast('1900-01-01 00:00:01' as datetime2) );  -- should be 2,415,020.5
insert into #TestValues (chapter, indate) values ('7.c.8',		cast('1600-01-01 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.9',		cast('1600-12-31 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('7.c.10',		cast('0837-04-10 07:12:00' as datetime2) );
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.11',  -0123, 12, 31, 0,0,0,0);
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.12', -0122, 01, 01, 0,0,0,0);
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.13', -1000, 07, 12, 12,0,0,0);	
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.14', -1000, 02, 29, 0,0,0,0);
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.15', -1001, 08, 17, 21, 36, 0,0	);
insert into #TestValues (chapter, inyear, inmonth, inday, inhour, inminute, insecond, innano) values ('7.c.16', -4712, 01, 01, 12, 0,	0,0);
insert into #TestValues (chapter, indate) values ('7.e/8',		cast('1954-06-30 00:00:00' as datetime2) );
insert into #TestValues (chapter, indate) values ('22.a',      cast('1987-04-10 00:00:00' as datetime2));
insert into #TestValues (chapter, indate) values ('47.a/48.a', cast('1992-04-12 00:00:00' as datetime2));
insert into #TestValues (chapter, indate) values ('49.a',      cast('1977-02-15 00:00:00' as datetime2));

/*
declare @testDate as datetime2 = cast('1957-10-04 19:26:23.999999' as datetime2);

select dbo.DateToJD(cast('0333-01-27 12:00:00' as datetime2), 0) , dbo.DateToJD(@testDate, 0) ,  dbo.DateToJD(cast('4712-01-01 12:00:00' as datetime2), 0)
	, dbo.DatePartsToJD(-4712, 1, 1, 0, 0, 0, 0), dbo.DatePartsToJD(-4712, 1, 1, 12, 0, 0, 0)
 */
 update #TestValues set JD =  dbo.fn_DateToJD(inDate, 0), 
					   JDE =  dbo.fn_DateToJD(inDate, 1) 
  where inDate is not null;
 update #TestValues set JD  = dbo.fn_DatePartsToJD(inYear, inMonth, inDay, inHour, inMinute, inSecond, inNano, 0), 
						JDE = dbo.fn_DatePartsToJD(inYear, inMonth, inDay, inHour, inMinute, inSecond, inNano, 1) 
  where inDate is null;


 update #TestValues set				R          = dbo.fn_SolarDistance(JD), 
								Delta          = dbo.fn_LunarDistance(JD),
						lunarLatitude          = dbo.fn_LunarLatitude(JD), 
						LunarDistance          = dbo.fn_LunarDistance(JD), 
						lunarLongitude         = dbo.fn_lunarLongitude(JD),
						lunarObliquity         = dbo.fn_Obliquity(JD),
						lunarIllumination      = dbo.fn_LunarIllumination(JD, 1),
						lunarIlluminationExact = dbo.fn_LunarIllumination(JD, 0),
						LunarPhase			   = dbo.fn_lunarPhase(jd, 4);

 select ID, Chapter, inDate, JD, JDE, R, lunarLatitude [Lunar Lat β], LunarLongitude [Lunar Long λ], 
		LunarDistance [Lunar Dist Δ], lunarObliquity [ε], lunarIllumination [k],  lunarIlluminationExact [ke],
		lunarPhase
   from #TestValues;

