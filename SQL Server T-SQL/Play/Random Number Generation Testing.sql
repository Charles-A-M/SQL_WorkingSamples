-- ways to generate random numbers:
/*
select rand() [RND 0 to 1]							  -- 0 to 1
	, FLOOR(RAND() * 10) + 1 [RND 1 to 10]			  -- rand between 1 and 10.
	, ABS(CHECKSUM(NEWID()) % 10) +1 [NEWID 0 to 10]  -- rand between 1 and 10.
	, FLOOR(RAND() * 100) + 1 [RND 1 to 100]
	, ABS(CHECKSUM(NEWID()) % 100) [NEWID 0 to 100]
*/
/*
drop table randvals;

create table randVals (
	id int not null primary key,
	RandCount bigint not null default 0,
	NewIDCount bigint not null default 0)

declare @i int = 0;
while @i <= 100
begin
	insert into randVals (id) values (@i);
	set @i = @i + 1;
end;
go

select * from randvals;
update randvals set randcount = 0, newidcount = 0;

set nocount on;
declare @x bigint = 0;
while @x < 90000000
begin
	set @x = @x + 1;
	declare @RndVal int = FLOOR(RAND() * 100) + 1;
	update randvals set randcount = randcount + 1 where id = @RndVal;
	set @RndVal = ABS(CHECKSUM(NEWID()) % 100) + 1;
	update randvals set NewIDCount = NewIDCount + 1 where id = @RndVal;
	if @x % 5000.0 = 0 
		print 'Run ' + format(@x, '#,###');
end;



after 1.2 million runs, it appears that they are both highly random, then:
rndMin	rndMax	RndAvg	RndStd		RndSum	
119288	120911	120150	352.8620	12015004	
NewMin	NewMax	NewAvg	newStd		NewSum
119358	120906	120150	315.2253	12015004


over 2 million rows, there's a difference between RAND and NewID, but good enough for government work:
Function	Runs	Min		Max	R	ange	Avg		StdDev
RAND()	20,000,001	198,747	201,310	2,563	200,000	490.4088
NEWID()	20,000,001	198,855	200,928	2,073	200,000	406.3913

rand is slightly less random than newid, as there's less spread between min and max here.


But at 10m runs, this reverses:
Function	Runs	Min	Max	Range	Avg	StdDev
RAND()	10,000,000	99,305	100,623	1,318	100,000	288.1714
NEWID()	10,000,000	99,216	100,909	1,693	100,000	323.3713

at 50m, the avgs are closer.
Function	Runs	Min	Max	Range	Avg	StdDev
RAND()	50,000,000	498,253	501,715	3,462	500,000	724.8073
NEWID()	49,999,999	498,392	502,160	3,768	499,999	747.8574
*/


set nocount on;
declare @x bigint = 0;
while @x < 1741073  --10,000,000
begin
	set @x = @x + 1;
	declare @RndVal int = FLOOR(RAND() * 100) + 1;
	update randvals set randcount = randcount + 1 where id = @RndVal;
	set @RndVal = ABS(CHECKSUM(NEWID()) % 100) + 1;
	update randvals set NewIDCount = NewIDCount + 1 where id = @RndVal;
	if @x % 5000.0 = 0 
		print 'Run ' + format(@x, '#,###');
end;

select 'RAND()' [Function], 
	format(sum(RandCount), '#,###') [Runs],
	format(Min(randcount), '#,###') [Min], 
	format(max(randcount), '#,###') [Max], 
	format(Max(randcount) -  Min(randcount), '#,###') [Range],
	format(avg(randcount), '#,###') [Avg], 
	format(STDEV(randcount), '#,###.####') [StdDev]
from randvals
where id > 0
union all
select 'NEWID()' [Function], 
	format(sum(NewIDCount), '#,###') [Runs],
	format(Min(NewIDCount), '#,###') [Min], 
	format(max(NewIDCount), '#,###') [Max], 
	format(Max(NewIDCount) -  Min(NewIDCount), '#,###') [Range],
	format(avg(NewIDCount), '#,###') [Avg], 
	format(STDEV(NewIDCount), '#,###.####') [StdDev]
from randvals
where id > 0
;