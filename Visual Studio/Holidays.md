# Holiday calculations in various languages


## US Federal Holidays


 - 01 Jan          : New Year's Day
 - 3rd Mon in Jan  : Martin Luther King Jr. Day
 - 3rd Mon in Feb  : President's Day
 - Last Mon in May : Memorial Day
 - 19 Jun          : Juneteenth
 - 04 Jul          : Independence Day
 - 1st Mon in Sep  : Labor Day
 - 2nd Mon in Oct  : Columbus Day
 - 11 Nov          : Veterans Day
 - 4th Thu in Nov  : Thanksgiving Day
 - 25 Dec          : Christmas Day
 
## Other significant US Holidays

 - 2nd Mon in May  : Mother's Day
 - See Below       : Easter
 - 31 Oct          : Halloween
 - 3rd Sun in Jun  : Father's Day
 - 14 Feb          : Valentine's Day
 - 17 Mar          : Saint Patrick's Day
 - 31 Dec          : New Year's Eve
 

https://en.wikipedia.org/wiki/Date_of_Easter

Easter falls on the first Sunday after the ecclesiastical full moon that occurs on or soonest after 21 March.
... see the T-SQL calendar file for a longer description of all this mess, but there are three algorithms to calculate Easter.

Gauss	
     a		=	Year mod 19													1777	1865	1961	1974	2014	2022	2023	2024	2025	2222	
     b		=	Year mod 4													10		3		4		17		0		8		9		10		11		18	
     c		=	Year mod 7													1		1		1		2		2		2		3		0		1		2		
     k		=	FLOOR( Year / 100 )											6		3		1		0		5		6		0		1		2		3		
     p		=	FLOOR( (13 + 8k) / 25 )										17		18		19		19		20		20		20		20		20		22	
     q		=	FLOOR( k / 4 )												5		6		6		6		6		6		6		6		6		7	
     M		=	(15 − p + k − q) mod 30										4		4		4		4		5		5		5		5		5		5	
     N		=	(4 + k − q) mod 7											23		23		24		24		24		24		24		24		24		25		
     d		=	(19a + M) mod 30											3		4		5		5		5		5		5		5		5		0 				
     e		=	(2b + 4c + 6d + N) mod 7									3		20		10		17		24		26		15		4		23		7 				
     Em		=	22 + d + e													5		5		1		6		5		0		3		5		6		2 				
     Ea		=	d + e - 9													30		47		33		45		51		48		40		31		51		31					
     m		=	(11M + 11) mod 30											-1		16		2		14		20		17		9		0		20		0 											
     Af1		=	if d=28 & e=6 & m < 19 Then Apr 18						24		24		5		5		5		5		5		5		5		16					
     Af2		=	if d=29 & e=6 Then Apr 19								0		0		0		0		0		0		0		0		0		0 								
     Af3		=	if Em < 32 Then Em Else Ea								0		0		0		0		0		0		0		0		0		0 											
     Day		=	if Af1>0 then Af1. if Af2>0 then Af2. Else Af3			30		16		2		14		20		17		9		31		20		31		
     Month	=	if Af1>0 or Af2>0 then 4. If Em < 32 then 3. Else 4			30		16		2		14		20		17		9		31		20		31	
                                                                            3		4		4		4		4		4		4		3		4		3
     																	3/30/'77 4/16/'65	4/2/61	4/14/74	4/20/14	4/17/22	4/9/23	3/31/24	4/20/25	3/31/22

Meeus/Jones/Butcher  (original format)			
     Dividend		Divisor	Quotient	Remain
     year			19			--			a
     year			100			b			c
     b				4			d			e
     b+8			25			f			--
     b-f+1			3			g			--
     19a+b-d-g+15	30			--			h
     c				4			i			k
     32+2e+2i-h-k	7			--			l
     a+11h+22 l		451			m			--
     h+l-7m+114		31			n			o

Meeus/Jones/Butcher
     		Y	=	Year													1777	1865	1961	1974	2014	2022	2023	2024	2025	2222
     		a	=	Y mod 19												10		3		4		17		0		8		9		10		11		18
     		b	=	FLOOR( Y / 100 )										17		18		19		19		20		20		20		20		20		22
     		c	=	Y mod 100												77		65		61		74		14		22		23		24		25		22
     		d	=	FLOOR( b / 4 )											4		4		4		4		5		5		5		5		5		5
     		e	=	b mod 4													1		2		3		3		0		0		0		0		0		2
     		f	=	FLOOR( (b + 8) / 25 )									1		1		1		1		1		1		1		1		1		1
     		g	=	FLOOR( (b − f + 1)/3 )									5		6		6		6		6		6		6		6		6		7
     		h	=	(19a + b − d − g + 15) mod 30							3		20		10		17		24		26		15		4		23		7
     		i	=	FLOOR( c / 4 )											19		16		15		18		3		5		5		6		6		5
     		k	=	c mod 4													1		1		1		2		2		2		3		0		1		2
     		l	=	(32 + 2e + 2i − h − k) mod 7							5		5		1		6		5		0		3		5		6		2
     		m	=	FLOOR( (a + 11h + 22 l) / 451 ) 						0		0		0		0		0		0		0		0		0		0
     Month =	n	=	FLOOR( (h + l − 7m + 114) / 31 )					3		4		4		4		4		4		4		3		4		3
     		o	=	(h + l − 7m + 114) mod 31								29		15		1		13		19		16		8		30		19		30
     Day		Dy	=	o + 1												30		16		2		14		20		17		9		31		20		31
     																		3/30/77	4/16/65	4/2/61	4/14/74	4/20/14	4/17/22	4/9/23	3/31/24	4/20/25	3/31/22

New Scientist												
     		Y	=	Year													1777	1865	1961	1974	2014	2022	2023	2024	2025	2222
     		a	=	Y mod 19												10		3		4		17		0		8		9		10		11		18
     		b	=	FLOOR( Y / 100 )										17		18		19		19		20		20		20		20		20		22
     		c	=	Y mod 100												77		65		61		74		14		22		23		24		25		22
     		d	=	FLOOR( b / 4 )											4		4		4		4		5		5		5		5		5		5
     		e	=	b mod 4													1		2		3		3		0		0		0		0		0		2
     		g	=	FLOOR( (8b + 13) / 25 )									5		6		6		6		6		6		6		6		6		7
     		h	=	(19a + b − d − g + 15) mod 30							3		20		10		17		24		26		15		4		23		7
     		i	=	FLOOR( c / 4 )											19		16		15		18		3		5		5		6		6		5
     		k	=	c mod 4													1		1		1		2		2		2		3		0		1		2
     		l	=	(32 + 2e + 2i − h − k) mod 7							5		5		1		6		5		0		3		5		6		2
     		m	=	FLOOR( (a + 11h + 19 l) / 433 ) 						0		0		0		0		0		0		0		0		0		0
     Month	n	=	FLOOR( (h + l − 7m + 90) / 25 )							3		4		4		4		4		4		4		3		4		3
     Day	p	=	(h+l-7m+33n+19) mod 32									30		16		2		14		20		17		9		31		20		31
     	New Scientist Date													3/30/77	4/16/65	4/2/61	4/14/74	4/20/14	4/17/22	4/9/23	3/31/24	4/20/25	3/31/22


Javascript:

		var a = 
	 
	 
	 
	 
	 
	 
	 
	 
	 