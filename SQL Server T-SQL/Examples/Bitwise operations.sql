 THROW 51000, 'Why are you here?', 1;  
 /*
	Bitwise operations.
	https://dietertack.medium.com/bitwise-operators-c-746a6cdf90e6
	
	Bitwise comparison:													C++*	VB		Excel	
	AND			returns a 1 for every bit where BOTH bits are 1			&		AND		BITAND
	OR			returns a 1 for every bit where EITHER bits is 1		|		OR		BITOR
	XOR			returns a 1 for every bit where ONLY ONE bit is 1		^		XOR		BITXOR
	NOT			inverts bits so 0 becomes 1, 1 becomes 0.				~		NOT		BITXOR({cell},HEX2DEC("FF"))
	* (C++, Jscript, and T-SQL are the same)
	Bitwise operations
	x << n		moves all bits in x left by n spaces, padding with 0	<<		<<		BITLSHIFT
	x >> n		moves all bits in x right by n spaces, padding with 0	>>		>>		BITRSHIFT
				(LEFT_SHIFT and RIGHT_SHIFT or << and >> appear in SQL 2022)

				As of SQL 2022:
	GET_BIT(x, n)		-- get the nth bit (from right, start at 0) of x, return as bit.
	SET_BIT(x, n, z)	-- set the nth bit (from right, start at 0) of x to z. Z is optional, must be null, 0, or 1.
	BIT_COUNT(x)		-- returns the # of bits of number/binary value x. 
						--	Note that SELECT BIT_COUNT(CAST (-1 as smallint)) and SELECT BIT_COUNT(CAST (-1 as int)) will return 16 and 32 respectively
						--	since the left-most bit is 1 for negative values.

-------------------------------+------------------------+------------------------+------------------------+---
Value 1 :    1  :  0000 0001   |    148  :  1001 0100   |    157  :  1001 1101   |     99  :  0110 0011   |   
Value 2 :  255  :  1111 1111   |     45  :  0010 1101   |    150  :  1001 0110   |     77  :  0100 1101   |   
          ----  :  ---------   |   ----  :  ---------   |   ----  :  ---------   |   ----  :  ---------   |   
    AND :    1  :  0000 0001   |      4  :  0000 0100   |    148  :  1001 0100   |     65  :  0100 0001   |   
     OR :  255  :  1111 1111   |    189  :  1011 1101   |    159  :  1001 1111   |    111  :  0110 1111   |   
    XOR :  254  :  1111 1110   |    185  :  1011 1001   |     11  :  0000 1011   |     46  :  0010 1110   |   
NOT val1:   -2  :  1111 1110   |   -149  :  0110 1011   |   -158  :  0110 0010   |   -100  :  1001 1100   |   
NOT val2: -256  :  0000 0000   |    -46  :  1101 0010   |   -151  :  0110 1001   |    -78  :  1011 0010   |   
-------------------------------+------------------------+------------------------+------------------------+---
id	value1	value2	v_and	v_or	v_xor	v_not1	v_not2	v1_bits	v2_bits	and_bits	or_bits	xor_bits	not1_bits	not2_bits
1	1	255	1	255	254	-2	-256	0000 0001	1111 1111	0000 0001	1111 1111	1111 1110	1111 1110	0000 0000
2	148	45	4	189	185	-149	-46	1001 0100	0010 1101	0000 0100	1011 1101	1011 1001	0110 1011	1101 0010
3	157	150	148	159	11	-158	-151	1001 1101	1001 0110	1001 0100	1001 1111	0000 1011	0110 0010	0110 1001
4	99	77	65	111	46	-100	-78	0110 0011	0100 1101	0100 0001	0110 1111	0010 1110	1001 1100	1011 0010


*/
Drop Table if Exists #BitValues;

create table #BitValues ( 
	id int identity primary key not null, 
	value1 int not null, 
	value2 int not null,
	v_and as value1 & value2,
	v_or  as value1 | value2,
	v_xor as value1 ^ value2,
	v_not1 as ~ value1,
	v_not2 as ~ value2,
	v1_bits as 
		 cast(cast(value1 & 128 as bit) as CHAR(1)) 
		+cast(cast(value1 &  64 as bit) as CHAR(1)) 
		+cast(cast(value1 &  32 as bit) as CHAR(1))
		+cast(cast(value1 &  16 as bit) as CHAR(1))+ ' '
		+cast(cast(value1 &   8 as bit) as CHAR(1))
		+cast(cast(value1 &   4 as bit) as CHAR(1))
		+cast(cast(value1 &   2 as bit) as CHAR(1))
		+cast(cast(value1 &   1 as bit) as CHAR(1)) ,
	v2_bits as 
		 cast(cast(value2 & 128 as bit) as CHAR(1)) 
		+cast(cast(value2 &  64 as bit) as CHAR(1)) 
		+cast(cast(value2 &  32 as bit) as CHAR(1))
		+cast(cast(value2 &  16 as bit) as CHAR(1)) + ' '
		+cast(cast(value2 &   8 as bit) as CHAR(1))
		+cast(cast(value2 &   4 as bit) as CHAR(1))
		+cast(cast(value2 &   2 as bit) as CHAR(1))
		+cast(cast(value2 &   1 as bit) as CHAR(1)) ,
	and_bits as 
		 cast(cast((value1 & value2) & 128 as bit) as CHAR(1))
		+cast(cast((value1 & value2) &  64 as bit) as CHAR(1))  
		+cast(cast((value1 & value2) &  32 as bit) as CHAR(1))
		+cast(cast((value1 & value2) &  16 as bit) as CHAR(1)) + ' '
		+cast(cast((value1 & value2) &   8 as bit) as CHAR(1))
		+cast(cast((value1 & value2) &   4 as bit) as CHAR(1))
		+cast(cast((value1 & value2) &   2 as bit) as CHAR(1))
		+cast(cast((value1 & value2) &   1 as bit) as CHAR(1)) ,
	or_bits as 
		 cast(cast((value1 | value2) & 128 as bit) as CHAR(1)) 
		+cast(cast((value1 | value2) &  64 as bit) as CHAR(1)) 
		+cast(cast((value1 | value2) &  32 as bit) as CHAR(1))
		+cast(cast((value1 | value2) &  16 as bit) as CHAR(1)) + ' '
		+cast(cast((value1 | value2) &   8 as bit) as CHAR(1))
		+cast(cast((value1 | value2) &   4 as bit) as CHAR(1))
		+cast(cast((value1 | value2) &   2 as bit) as CHAR(1))
		+cast(cast((value1 | value2) &   1 as bit) as CHAR(1)) ,
	xor_bits as 
		 cast(cast((value1 ^ value2) & 128 as bit) as CHAR(1)) 
		+cast(cast((value1 ^ value2) &  64 as bit) as CHAR(1))
		+cast(cast((value1 ^ value2) &  32 as bit) as CHAR(1))
		+cast(cast((value1 ^ value2) &  16 as bit) as CHAR(1)) + ' '
		+cast(cast((value1 ^ value2) &   8 as bit) as CHAR(1))
		+cast(cast((value1 ^ value2) &   4 as bit) as CHAR(1))
		+cast(cast((value1 ^ value2) &   2 as bit) as CHAR(1))
		+cast(cast((value1 ^ value2) &   1 as bit) as CHAR(1)) ,
	not1_bits as 
		 cast(cast((~ value1) & 128 as bit) as CHAR(1)) 
		+cast(cast((~ value1) &  64 as bit) as CHAR(1))
		+cast(cast((~ value1) &  32 as bit) as CHAR(1))
		+cast(cast((~ value1) &  16 as bit) as CHAR(1)) + ' '
		+cast(cast((~ value1) &   8 as bit) as CHAR(1))
		+cast(cast((~ value1) &   4 as bit) as CHAR(1))
		+cast(cast((~ value1) &   2 as bit) as CHAR(1))
		+cast(cast((~ value1) &   1 as bit) as CHAR(1)) ,
	not2_bits as 
		 cast(cast((~ value2) & 128 as bit) as CHAR(1)) 
		+cast(cast((~ value2) &  64 as bit) as CHAR(1))
		+cast(cast((~ value2) &  32 as bit) as CHAR(1))
		+cast(cast((~ value2) &  16 as bit) as CHAR(1)) + ' '
		+cast(cast((~ value2) &   8 as bit) as CHAR(1))
		+cast(cast((~ value2) &   4 as bit) as CHAR(1))
		+cast(cast((~ value2) &   2 as bit) as CHAR(1))
		+cast(cast((~ value2) &   1 as bit) as CHAR(1)) 
);

insert into #BitValues (value1, value2) values (1, 255);
insert into #BitValues (value1, value2) values (148, 45);
insert into #BitValues (value1, value2) values (157, 150);
insert into #BitValues (value1, value2) values (99, 77);

Select * from #BitValues;


Declare c1 Cursor For
	Select Value1, value2, v_and, v_or, v_xor, v_not1, v_not2, v1_bits, v2_bits, and_bits, or_bits, xor_bits, not1_bits, not2_bits
	  from #BitValues;
declare @val1 int;
declare @val2 int;
declare @vAnd int;
declare @v_Or int;
declare @vXor int;
declare @vNo1 int;
declare @vNo2 int;
declare @bV1  varchar(32);
declare @bV2  varchar(32);
declare @bAnd varchar(32);
declare @b_or varchar(32);
declare @bXor varchar(32);
declare @bNo1 varchar(32);
declare @bNo2 varchar(32);

declare @line0 varchar(2000) = '----------';
declare @line1 varchar(2000) = 'Value 1 : ';
declare @line2 varchar(2000) = 'Value 2 : ';
declare @line3 varchar(2000) = '          ';
declare @line4 varchar(2000) = '    AND : ';
declare @line5 varchar(2000) = '     OR : ';
declare @line6 varchar(2000) = '    XOR : ';
declare @line7 varchar(2000) = 'NOT val1: ';
declare @line8 varchar(2000) = 'NOT val2: ';

open c1;
Fetch Next From c1 into @val1, @val2, @vAnd, @v_Or, @vXor,
						@vNo1, @vNo2, @bV1 , @bV2 , @bAnd,
						@b_or, @bXor, @bNo1, @bNo2;
While @@FETCH_STATUS = 0
begin
	set @line0 += '---------------------+---';
	set @line1 += right('                ' + cast(@val1 as varchar), 4) + '  :  ' + @bV1 + '   |   ';
	set @line2 += right('                ' + cast(@val2 as varchar), 4) + '  :  ' + @bV2 + '   |   ';
	set @line3 += '----  :  ---------   |   ';
	set @line4 += right('                ' + cast(@vAnd as varchar), 4) + '  :  ' + @bAnd + '   |   ';
	set @line5 += right('                ' + cast(@v_Or as varchar), 4) + '  :  ' + @b_or + '   |   ';
	set @line6 += right('                ' + cast(@vXor as varchar), 4) + '  :  ' + @bXor + '   |   ';
	set @line7 += right('                ' + cast(@vNo1 as varchar), 4) + '  :  ' + @bNo1 + '   |   ';
	set @line8 += right('                ' + cast(@vNo2 as varchar), 4) + '  :  ' + @bNo2 + '   |   ';
	Fetch Next From c1 into @val1, @val2, @vAnd, @v_Or, @vXor,
						@vNo1, @vNo2, @bV1 , @bV2 , @bAnd,
						@b_or, @bXor, @bNo1, @bNo2;
end;
close c1;
deallocate c1;

print ' /* ';
print @line0;
print @line1;
print @line2;
print @line3;
print @line4;
print @line5;
print @line6;
print @line7;
print @line8;
print @line0;
print ' */ ';