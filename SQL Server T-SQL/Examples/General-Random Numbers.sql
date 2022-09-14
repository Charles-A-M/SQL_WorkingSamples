 THROW 51000, 'Why are you here?', 1;  
 -- ==============================================================================================================================================================================================================================
 -- ==============================================================================================================================================================================================================================
 --	General Use code
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	Random numbers
			-- Taken from	https://web.archive.org/web/20110829015850/http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/sql-server-set-based-random-numbers
			-- See also 	https://stackoverflow.com/questions/1045138/how-do-i-generate-a-random-number-for-each-row-in-a-t-sql-select
	
			-- ABS(CHECKSUM(NewID())) % {range} + {Min}
			Select ABS(CHECKSUM(NewID())) % 20 + 1  -- this will give a range between 1 and 20
			
			
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- most basic: between 0 and < 1
Select RAND();
	-- 0.281876417574935

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- But now there's a problem...
SELECT RAND() AS RandomNumber
FROM   (SELECT 1 AS NUM UNION All
        SELECT 2 UNION All
        SELECT 3) AS ALIAS;
	-- 0.678894882899506
	-- 0.678894882899506
	-- 0.678894882899506
	
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- 	here we see that newID is immune to this problem...
SELECT RAND() AS RandomNumber, NewId() AS GUID
FROM   (SELECT 1 AS NUM UNION All
        SELECT 2 UNION All
        SELECT 3) AS ALIAS;
		
	-- RandomNumber			GUID
	-- 0.248103966248315	D493E192-40D8-4814-AE8F-6BF907AAA5BE
	-- 0.248103966248315	22B3C1FF-56D3-44ED-ABBB-6485E9EB72EE
	-- 0.248103966248315	7FA44DBC-7049-4F30-88A6-F96E21D0737D

 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- CHECKSUM function will return an integer hash value based on its argument. the values must fall between -2,147,483,648 and 2,147,483,647

SELECT RAND() AS RandomNumber,
       NewId() AS GUID,
       CHECKSUM(NewId()) AS RandomInteger
FROM   (SELECT 1 AS NUM UNION All
        SELECT 2 UNION All
        SELECT 3) AS ALIAS

	-- RandomNumber	GUID	RandomInteger
	-- 0.754200255100332	BE94FD60-45A5-49A9-98DD-15FE29B936A1	-953877562
	-- 0.754200255100332	D4E85EC8-014A-4CE4-A156-BB3BB473F2CA	-937054348
	-- 0.754200255100332	C609DDA7-7E8E-4F19-8F56-813A8B07C1F4	1448775030
	
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- convert the checksum value to a defined range, we divide the CHECKSUM value by the range and keep the remainder... ABS means we make negatives into positives.
 -- 	so this gives us integers between 0 and 9...
 
SELECT RAND() AS RandomNumber,
       NewId() AS GUID,
       ABS(CHECKSUM(NewId())) % 10 AS RandomInteger
FROM   (SELECT 1 AS NUM UNION All
        SELECT 2 UNION All
        SELECT 3) AS ALIAS;
		
	-- RandomNumber	GUID	RandomInteger
	-- 0.236193654511616	6170D7E7-5306-4310-A1FB-ECDD0930777D	0
	-- 0.236193654511616	2308ED3A-AEDB-42D8-A05D-7A28EAC6EEC4	9
	-- 0.236193654511616	283B7F33-B07A-4DBC-B22E-FC31A538C4A8	2
	
 -- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Assuming Numbers has 1 million rows...	
SELECT  RandomNumber, COUNT(*) AS NumberCount
FROM    (
        SELECT ABS(CHECKSUM(NewId())) % 11 - 5 AS RandomNumber
        FROM Numbers
        ) AS A
GROUP BY RandomNumber
ORDER BY RandomNumber;
/*
results should be something like

RandomNumber NumberCount
------------ -----------
-5           90889
-4           90794
-3           91365
-2           90476
-1           91104
0            90730
1            90895
2            90815
3            90762
4            91133
5            91037

*/

	