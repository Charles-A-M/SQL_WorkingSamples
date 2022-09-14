/*
 -------------------- List All Unicode Code Points -------------------

Created By: Solomon Rutzky / Sql Quantum Leap ( https://SqlQuantumLeap.com/ )
Created On: 2019-03-25
Updated On: 2019-04-09
Updated On: 2020-01-13 ~ Add UTF-8 support for all SQL Server versions (does not require "_UTF8" collation!!)
                       ~ Clarify that HTML escape sequences are also used in XML
                       ~ Add more app languages: F#, JavaScript, and Julia
                       ~ Correct "\x" to be "\u" for C#, F#, Java, etc app languages
                       ~ Split "\u" and "\u\u" into 2 columns to be more accurate for app languages
                       ~ Add "\U" column to be more accurate for app languages
                       ~ Fix "Location" URL in header comment

Location:          https://pastebin.com/0JvkHu2D
Related blog post: https://sqlquantumleap.com/2019/03/25/ssms-tip-3-easily-access-research-all-unicode-characters-yes-including-emojis-%f0%9f%98%b8/

Escape Sequences:  For more details and/or additional languages, please see the following post:
                   https://sqlquantumleap.com/2019/06/26/unicode-escape-sequences-across-various-languages-and-platforms-including-supplementary-characters/
----------------------------------------------------------------------
*/


USE [tempdb];


IF (OBJECT_ID(N'dbo.ListAllUnicodeCodePoints') IS NULL)
BEGIN
	RAISERROR(N'Creating placeholder function...', 10, 1) WITH NOWAIT;
	EXEC(N'CREATE FUNCTION dbo.ListAllUnicodeCodePoints()
			RETURNS TABLE AS RETURN SELECT 1 AS [a];');
END;


-------------------------------------------------------------------------------
--===========================================================================--
-------------------------------------------------------------------------------
GO
ALTER FUNCTION dbo.ListAllUnicodeCodePoints(@EncodeSurrogateCodePointsInUTF8 BIT = 0)
RETURNS TABLE
AS RETURN
WITH nums AS
(
  SELECT TOP (1114111) (ROW_NUMBER() OVER (ORDER BY @@MICROSOFTVERSION) - 1) AS [num]
  FROM   [master].[sys].[all_columns] ac1
  CROSS JOIN [master].[sys].[all_columns] ac2
), chars AS
(
  SELECT CONVERT(INT, n.[num]) AS [num], -- pass-through
         RIGHT(CONVERT(CHAR(6), CONVERT(BINARY(3), n.[num]), 2),
               CASE WHEN n.[num] > 65535 THEN 5 ELSE 4 END) AS [CodePointHex],
         CONVERT(INT, CASE WHEN n.[num] > 65535 THEN 55232 + (n.[num] / 1024) END) AS [HighSurrogateINT],
         CONVERT(INT, CASE WHEN n.[num] > 65535 THEN 56320 + (n.[num] % 1024) END) AS [LowSurrogateINT]
  FROM   nums n
  WHERE  n.[num] BETWEEN 0x000000 AND 0x014700 -- filter out 925,455
  OR     n.[num] BETWEEN 0x016800 AND 0x030000 -- unmapped code
  OR     n.[num] BETWEEN 0x0E0001 AND 0x0E01EF -- points
)
SELECT
       'U+' + c.[CodePointHex] AS [CodePoint],
       c.[num] AS [CdPntINT],
       '0x' + c.[CodePointHex] AS [CdPntBIN],
       CASE
         WHEN c.[num] > 65535 THEN NCHAR(c.[HighSurrogateINT]) + NCHAR(c.[LowSurrogateINT])
         ELSE NCHAR(c.[num])
       END AS [Char],
       CASE
         WHEN c.[num] > 65535 THEN CONVERT(CHAR(10), CONVERT(BINARY(4),
                                           NCHAR(c.[HighSurrogateINT]) + NCHAR(c.[LowSurrogateINT])), 1)
         ELSE CONVERT(CHAR(6), CONVERT(BINARY(2), NCHAR(c.[num])), 1)
       END AS [UTF-16LE       ],
       '0x' + CASE -- https://rosettacode.org/wiki/UTF-8_encode_and_decode#VBA
                WHEN c.[num] < 128
                  THEN CONVERT(CHAR(4), CONVERT(BINARY(1), c.[num]), 2)
                WHEN c.[num] BETWEEN 128 AND 2047
                  THEN CONVERT(CHAR(2), CONVERT(BINARY(1), ((c.[num] / 64) + 192)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), ((c.[num] % 64) + 128)), 2)
                WHEN (@EncodeSurrogateCodePointsInUTF8 = 0) AND (c.[num] BETWEEN 55296 AND 57343)
                  THEN 'EFBFBD' -- Replacement (U+FFFD) Surrogate Code Points are invalid in UTF-8
                WHEN c.[num] BETWEEN 2048 AND 65535
                  THEN CONVERT(CHAR(2), CONVERT(BINARY(1), (((c.[num] / 64) / 64) + 224)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), (((c.[num] / 64) % 64) + 128)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), ((c.[num] % 64) + 128)), 2)
                WHEN c.[num] BETWEEN 65536 AND 1114111
                  THEN CONVERT(CHAR(2), CONVERT(BINARY(1), ((((c.[num] / 64) / 64) / 64) + 240)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), ((((c.[num] / 64) / 64) % 64) + 128)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), (((c.[num] / 64) % 64) + 128)), 2)
                  +    CONVERT(CHAR(2), CONVERT(BINARY(1), ((c.[num] % 64) + 128)), 2)
                ELSE CONVERT(VARCHAR(15), NULL)
              END AS [UTF-8          ],
       c.[HighSurrogateINT] AS [HighSrgtINT],
       c.[LowSurrogateINT] AS [LowSrgtINT],
       CONVERT(BINARY(2), c.[HighSurrogateINT]) AS [HighSrgtBIN],
       CONVERT(BINARY(2), c.[LowSurrogateINT]) AS [LowSrgtBIN],
       'NCHAR(' + CASE
                    WHEN c.[num] > 65535 THEN CONVERT(CHAR(6), CONVERT(BINARY(2), c.[HighSurrogateINT]), 1)
                      + ') + NCHAR(' + CONVERT(CHAR(6), CONVERT(BINARY(2), c.[LowSurrogateINT]), 1)
                    ELSE CONVERT(CHAR(6), CONVERT(BINARY(2), c.[num]), 1)
                  END + ')' AS [T-SQL                                                  ],
       '&#x' + c.[CodePointHex] + ';' AS [HTML/XML    ],
       CASE
         WHEN c.[num] < 65536 THEN '\u' + CONVERT(CHAR(4), CONVERT(BINARY(2), c.[num]), 2)
         ELSE CONVERT(VARCHAR(10), NULL)
       END AS [C#/F#/C++/Java[Script]]/Julia/?],
       CASE
         WHEN c.[num] > 65535 THEN '\u' + CONVERT(CHAR(4), CONVERT(BINARY(2), c.[HighSurrogateINT]), 2)
           + '\u' + CONVERT(CHAR(4), CONVERT(BINARY(2), c.[LowSurrogateINT]), 2)
         ELSE CONVERT(VARCHAR(15), NULL)
       END AS [C#/F#/Java[Script]]/?],
       '\U' + CONVERT(CHAR(8), CONVERT(BINARY(4), c.[num]), 2) AS [C#/F#/C/C++/Julia/?]
FROM   chars c;
GO
-------------------------------------------------------------------------------
--===========================================================================--
-------------------------------------------------------------------------------


-------- TEST ---------
/*

-- List all 188,657 code points:
SELECT cp.*
FROM   dbo.ListAllUnicodeCodePoints(DEFAULT) cp; -- DEFAULT is same as 0


-- List surrogate code points to show difference in UTF-8 encoding options:
-- (Surrogate code points are invalid in UTF-8 and ideally should not be encoded)
SELECT enc.[CodePoint], enc.[CdPntINT], enc.[CdPntBIN], enc.[Char],
       no_enc.[UTF-8          ] AS [UTF-8 conforming], enc.[UTF-8          ] AS [UTF-8 encoded]
FROM   dbo.ListAllUnicodeCodePoints(0) no_enc -- 0 is same as DEFAULT
INNER JOIN dbo.ListAllUnicodeCodePoints(1) enc
        ON enc.[CdPntINT] = no_enc.[CdPntINT]
WHERE  no_enc.[CdPntINT] BETWEEN 0xD800 AND 0xDFFF;


-- List some emoji:
SELECT cp.*
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F000 AND 0x1F9FF;


-- List the Tibetan characters, sorted naturally for that language:
SELECT cp.*
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x0F00 AND 0x0FFF -- Tibetan
ORDER BY  cp.[Char] COLLATE Nepali_100_CS_AS;


-- List characters that are considered the same as "E"
-- (when using Latin1_General_100_CI_AI):
SELECT cp.*
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[Char] = N'E' COLLATE Latin1_General_100_CI_AI
ORDER BY  cp.[CdPntINT];
-- 94 rows!!


-- List characters that have a numeric value between 0 and 10,000
-- (for pre-SQL Server 2017, use Latin1_General_100_CI_AI):
SELECT cp.*
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[Char] LIKE N'%[0-' + NCHAR(0x2182) + N']%' COLLATE Japanese_XJIS_140_CI_AI--Latin1_General_100_CI_AI
ORDER BY  cp.[Char] COLLATE Japanese_XJIS_140_CI_AI--Latin1_General_100_CI_AI
-- 752 rows!! (for Japanese_XJIS_140_CI_AI)
-- 550 rows!! (for Latin1_General_100_CI_AI)



-- Can be used in SSMS a as a keyboard Query Shortcut (only a single line is allowed):
SELECT cp.* FROM dbo.ListAllUnicodeCodePoints(0) cp; RETURN;
-- See blog post (linked in the header comment bloc) for details.



-- DROP FUNCTION dbo.ListAllUnicodeCodePoints;

*/


select * from dbo.ListAllUnicodeCodePoints(0) cp
 where  cp.[CdPntINT] in (0x1F0BF, 0x1F0CF)

 

--tarot trumps 
SELECT ROW_NUMBER() OVER(ORDER BY cp.[T-SQL]) -1 RowNum ,
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F0e0 AND 0x1F0f5;
 

 --Spades / Swords
SELECT ROW_NUMBER() OVER(ORDER BY cp.[T-SQL]) RowNum ,
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F0a1 AND 0x1f0ae;

 --hearts / cups
SELECT ROW_NUMBER() OVER(ORDER BY cp.[T-SQL]) RowNum ,
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F0b1 AND 0x1f0be;

 --diamonds / pentacles
SELECT ROW_NUMBER() OVER(ORDER BY cp.[T-SQL]) RowNum ,
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F0c1 AND 0x1f0ce;

 --clubs / wands
SELECT ROW_NUMBER() OVER(ORDER BY cp.[T-SQL]) RowNum ,
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] BETWEEN 0x1F0d1 AND 0x1f0de;


 --other
SELECT 'Back of Card' [Name],
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x1F0a0
union
SELECT 'Joker, Red' [Name],
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x1F0bf
union
SELECT 'Joker, Black' [Name],
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x1F0cf
union
SELECT 'Joker, White' [Name],
		cp.[Char], cp.[HTML/XML], cp.[T-SQL], cp.[CdPntINT]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x1F0df



Select
		cp.[Char],
		cp.[HTML/XML],
		cp.[T-SQL],
		cp.[CdPntINT],
		'Spade/sword Suit' [Name]
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x2660
union
Select
		cp.[Char],
		cp.[HTML/XML],
		cp.[T-SQL],
		cp.[CdPntINT],
		'Club/Wand Suit'
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x2663
union
Select
		cp.[Char],
		cp.[HTML/XML],
		cp.[T-SQL],
		cp.[CdPntINT], 
		'Heart Suit'
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x2665
union
Select
		cp.[Char],
		cp.[HTML/XML],
		cp.[T-SQL],
		cp.[CdPntINT], 
		'Diamond/Pentacle Suit'  
FROM   dbo.ListAllUnicodeCodePoints(0) cp
WHERE  cp.[CdPntINT] = 0x2666