/*
 *		Sql Crossword Builder
 *
 *		(C) Charles Moore, 2022
 *
 *		This code will attempt to generate a random crossword puzzle (solved and unsolved)
 *		for a given set of words and clues.
 *
 *		To customize, change the list of words below to your own list of words with their clues.
 *		If you change the number of words or word complexity, you may need to adjust the maximum number of 
 *		rows/columns to make everything fit well. This is the  @PuzzleSize value below.
 *
 *		=======================================================================================================
 *		License: 
 *		Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
 *		More info: https://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 *		You are free to:
 *		Share - copy and redistribute the material in any medium or format
 *		Adapt - remix, transform, and build upon the material for any non-commercial purpose
 *
 *		Under the following terms:
 *		Attribution					— You must give appropriate credit, provide a link to the license,
 *										and indicate if changes were made. You may do so in any reasonable 
 *										manner, but not in any way that suggests the licensor endorses you or your use.
 *
 *		NonCommercial				— You may not use the material for commercial purposes.
 *		ShareAlike					— If you remix, transform, or build upon the material, you must distribute your 
 *										contributions under the same license as the original.
 *		No additional restrictions	— You may not apply legal terms or technological measures that 
 *										legally restrict others from doing anything the license permits.
 *		No warranties are given. 
 * ==================================================================================================================
 *		Help with the algorithms from	https://www.codeproject.com/Articles/1271730/Mr-Crossworder-Create-Crosswords-in-Seconds
 *		Help with random numbers from	https://stackoverflow.com/questions/1045138/how-do-i-generate-a-random-number-for-each-row-in-a-t-sql-select
										https://web.archive.org/web/20110829015850/http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/sql-server-set-based-random-numbers
 * ==================================================================================================================

 Problems
	after the 1st word, we should try to cross the previous word if possible. or another word if not.
	
	the words are too scattered. Grid too large? May be fixed by above issue.
	
	it doesn't know that words can cross; right now, it requires all words to be isolated like battleship.
		TODO: Write a battleship SQL game?
	
	numbers on the table, not just the clue list.
		(how to show that?)

	cleaner output.
		generate an html table
		generate SVG and display as spatial results (this will be the one that looks the best, if I can do it right.)

 */

/*		=======================================================================================================
 *		You should not need to modify anything below this line to get your own crossword puzzles
 *		=======================================================================================================
 */

declare @CrLf			nvarchar(2)		= CHAR(13) + CHAR(10);	/*	for string output, make a line break	*/
declare @r				int				= -1;	/*	row number tracking */
declare @c				int				= -1;	/*	col number tracking	*/
declare @startR			int;					/*  where the 1st character of the word is placed	*/
declare @startC			int;					
declare @i				int;					/*	loop control	*/
declare @isAcross		bit				= 1;	/*	holds flag for word is to be horizontal or vertical	*/
Declare @Across			nvarchar(2000);			/*	holds an across clue from cursor */
Declare @Down			nvarchar(2000);			/*	holds down clue from cursor */
declare @orderNum		int;					/*	holds the word/clue number from cursor */
declare @maxClue		int;					/*	holds the length of the longest clue + 5 for spacing. */
declare @puzzleSolved	nvarchar(max)	= '';	/*	holds the solved crossword puzzle goes here */
declare @puzzleUnsolved nvarchar(max)	= '';	/*	holds the unsolved crossword puzzle */
Declare @puzzleClues	nvarchar(max)	= '';	/*	holds the puzzle clues in columns for across and down */
Declare @maxTries		int;					/*	If the puzzle loops more than this count, we quit with an error. */
Declare @OneWord		nvarchar(30);			/*	holds the word we're currently processing	*/
declare @wordCount		int;					/*	holds the count of unplaced words	*/
declare @clueNum		int;					/*	This is the number for the clues, 1...N across and 1...N down	*/
declare @placeTries		int;					/*	Try this times to find a place for this word then break out and start at the top w/ word selection	*/
declare @blocked		bit;					/*	flags whether a given word is blocked from placement at a given r, c location.	*/
declare @oneChar		nchar(1)				/*	a character from one grid cell	*/
declare cClue cursor for
 select distinct num.OrderNum, isnull(acc.Clue, N'') Across, isnull(dwn.Clue, N'') Down
   from #WordClues num
  left join #WordClues acc on acc.OrderNum = num.OrderNum and acc.isAcross = 1
  left join #WordClues dwn on dwn.OrderNum = num.OrderNum and dwn.isAcross = 0
 where num.isAcross is not null;
 ;
/*	the crossword puzzle occupies a grid of @PuzzleSize count of rows and columns.  
 *	Each cell of the grid can hold nothing or 1 character from word(s). 
 *	This table stores that grid.
 */





While @r < @PuzzleSize
begin
	set @c = 0;
	while @c < @PuzzleSize
	begin
		insert into #CrossWord (RowNum, ColNum) values (@r, @c);
		set @c += 1;
	end;
	set @r += 1;
end;


select @maxTries = count(*) * 50
  from #WordClues;

/*		=======================================================================================================
 *			Begin the master placement loop. 
 *			This loop goes through all of the words and attempts to drop each onto the grid.
 *		======================================================================================================= */
While @maxTries > 0
begin		/*	begin the placement loop.	*/
	select @wordCount = count(*) 
	  from #WordClues
	 where isAcross is null;
	
	if @wordCount < 1
		Break;		/*	We've placed all the words!	exit the placement loop.*/
		
	
	
	select @clueNum = isnull(MAX(orderNum), 0) + 1 
	  from #WordClues 
	 where isAcross = @isAcross;

	select top 1 @OneWord = Word 
	  from #WordClues
	 where isAcross is null
	 order by WordLength desc, NEWID();
	
	if @debug = 1
		print 'Placement loop. Tries remaining: ' + cast(@maxTries as nvarchar) + '. Word is "' + @oneWord + '".';
	/*		=======================================================================================================
	 *		now that we have a word, begin the inner trial loop
	 *		this gives us 30 tries to find a random location suitable for this word.
	 *		=======================================================================================================	*/
	set @placeTries = 0;
	while @placeTries < 30
	begin
		/*	IF this is going horizontal, then our start spot has to be < the word length.
		 *	Otherwise it's vertical and the start ROW has to be less than the length.

		if @isAcross = 1
		begin
			set @c = ABS(CHECKSUM(NewID())) % (@PuzzleSize - len(@oneWord));
			set @r = ABS(CHECKSUM(NewID())) % @PuzzleSize;
		end
		else
		begin
			set @r = ABS(CHECKSUM(NewID())) % (@PuzzleSize - len(@oneWord));
			set @c = ABS(CHECKSUM(NewID())) % @PuzzleSize;
		end
				 */
		if @r < 0 or @c < 0
		begin
			/*	first pass, center the word */
			set @r = @PuzzleSize / 2;
			set @c = (@PuzzleSize / 2) - (len(@oneWord) / 2);
			set @startR = @r;
			set @startC = @c;
		end
		else
		begin
			
		end
		 

		if @debug = 1
			print '... inner trial loop. Try # ' + cast(@placeTries as nvarchar) + '. R= ' + cast(@r as nvarchar) + '. C= ' + cast(@c as nvarchar) + '.';

		set @blocked = 0;
		set @i = 0;

				/*	If going across, check the cell		to the left on first letter			*/
				/*	If going across, check the cell		to the right of the last letter		*/
				/*	if going down, check the cell		above this cell on first letter		*/
				/*	if going down, check the cell		below this cell on last letter			*/

		while @i < len(@oneWord) and @blocked = 0
		begin
			set @i += 1;
			if @isAcross = 1
			begin
				/* check the cell we're trying to occupy	*/
				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r 
				   and ColNum = @c + @i;
				if @oneChar is not null
					if @oneChar <> SUBSTRING(@oneWord, @i, 1)
					begin
						set @blocked = 1;
						if @debug = 1
							print '... ...Blocked! Across, this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
						Break;
					end;
				/*	If going across, check the cell... above this cell						
					TODO: handle other words nearby						*/
 				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r - 1 
				   and ColNum = @c + @i;
				if @oneChar is not null
				begin
					set @blocked = 1;
					if @debug = 1
							print '... ...Blocked! Across, above this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
					Break;
				end;
				/*	If going across, check the cell... below this cell	
					TODO: handle other words nearby						*/
 				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r + 1 
				   and ColNum = @c + @i;
				if @oneChar is not null
				begin
					set @blocked = 1;
					if @debug = 1
							print '... ...Blocked! Across, below this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
					Break;
				end;
			end
			else	/* is vertical	*/
			begin
				/* check the cell we're trying to occupy	*/
				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r + @i
				   and ColNum = @c;
				if @oneChar is not null
					if @oneChar <> SUBSTRING(@oneWord, @i, 1)
					begin
						set @blocked = 1;
						if @debug = 1
							print '... ...Blocked! Down, this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
						Break;
					end;
				/*	if going down, check the cell... left of this cell
					TODO:	 nearby words?									*/
				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r + @i
				   and ColNum = @c - 1;
				if @oneChar is not null
				begin
					set @blocked = 1;
					if @debug = 1
						print '... ...Blocked! Down, left of this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
					Break;
				end;
				/*	if going down, check the cell... right of this cell	
					TODO:	 nearby words?									*/
				select @oneChar = CellValue
				  from #CrossWord
				 where RowNum = @r + @i
				   and ColNum = @c + 1;
				if @oneChar is not null
				begin
					set @blocked = 1;
					if @debug = 1
						print '... ...Blocked! Down, right of this cell r,c = (' + cast(@r as nvarchar) + ', ' + cast(@c as nvarchar) + ').';
					Break;
				end;
			end
		end	/*	/ word length	*/
		if @blocked = 1
			set @placeTries += 1;
		else
			break;

	end		/*	/ placeTries */
	if @blocked = 0
	begin
		if @debug = 1
			print '...Word successfully placed!';

		update #WordClues set isAcross = @isAcross, OrderNum = @clueNum,
								startRow = @startR, startCol = @startC
		 where Word = @OneWord;

		set @i = 0;
		while @i < LEN(@OneWord)
		begin
			set @i += 1;
			Update #CrossWord set CellValue = SUBSTRING(@OneWord, @i, 1)
			 Where RowNum = @r and ColNum = @c;
			if @isAcross = 1
				set @c += 1;
			else
				set @r += 1;
		end;
		set @isAcross = ~@isAcross;	/*	alternate across and down only on successful placement */
	end
	set  @maxTries -= 1;	/*	we can only try this so many times to place these words!	*/
end			/*	/ placement loop	*/

/*		=======================================================================================================
 *		done with placement.
 *		on to output!
 *		======================================================================================================= */

if @debug = 1
begin
	select * from #CrossWord;
	select * from #WordClues;
	select distinct num.OrderNum, acc.Clue Across, dwn.Clue Down
	  from #WordClues num
      left join #WordClues acc on acc.OrderNum = num.OrderNum and acc.isAcross = 1
      left join #WordClues dwn on dwn.OrderNum = num.OrderNum and dwn.isAcross = 0
     where num.isAcross is not null;
end;

select @maxClue = max(clueLength) + 5 from #WordClues;

set @puzzleClues = left(N'     Across' + Replicate(N' ', @maxClue), @maxClue) +
				   left(N'     Down' + Replicate(N' ', @maxClue), @maxClue) + @CrLf +
				   REPLICATE(N'-', @maxClue * 2) + @CrLf;


 open cClue;
 fetch next from cClue into @orderNum, @Across, @Down;
 While @@FETCH_STATUS = 0 
 begin
	set @puzzleClues += right( N'   ' + cast(@orderNum as nvarchar), 3) + ': ' + 
						left(@across + Replicate(N' ', @maxClue), @maxClue) +
						left(@down + Replicate(N' ', @maxClue), @maxClue) + @CrLf;

	fetch next from cClue into @orderNum, @Across, @Down;
 end;
 close cClue;
 deallocate cClue;

set @r = 0;
while @r <= @PuzzleSize
Begin
	set @c = 0;
	while @c <= @PuzzleSize
	begin
	--   ₀	₁	₂	₃	₄	₅	₆	₇	₈	₉	
	--  ∎ ⊠ ֈ ౷ ఼ ౝ ೝ ፠ ೱ ⁜ ※ ▢ ⏹	 ⏻	⏼	⏽	⏾	⏿ ⍞ ⎕ █ 	▅ 	▯ ▣ ▢ ☐ ☒ 🀜
		Select @puzzleSolved += cast(isnull(CellValue, N'-') as nvarchar)
		  from #CrossWord 
		 where RowNum = @r 
		   and ColNum = @c;

		Select @puzzleUnsolved += case when CellValue is null then N'☒' else N'☐' end
		  from #CrossWord
		 where RowNum = @r
		   and ColNum = @c;
		set @c += 1;
	end;
	Set @puzzleSolved += @CrLf;
	Set @puzzleUnsolved += @CrLf;
	Set @r += 1;
end;

 print replicate(N'=', @maxClue * 2);
 print N'     Sql Crossword Puzzle ';
 print replicate(N'-', @maxClue * 2);
 Print @puzzleUnsolved 
 print replicate(N'=', @maxClue * 2);
 print N'     Clues:';
 print replicate(N'-', @maxClue * 2);
 print @puzzleClues;
 print replicate(N'-', @maxClue * 2);
 Print N'     Solution:';
 print replicate(N'-', @maxClue * 2);
 Print  @puzzleSolved; 
 print replicate(N'=', @maxClue * 2);
 print N'     Sql Crossword Puzzle (C) 2022 by Charles Moore';
 print replicate(N'=', @maxClue * 2);




 
/*
	Place 1st word at random location.
	For each remaining word...
		Get starting x, y. Alternate between across and down.
			For each letter
				look for matches already placed on the board
				If a match is found, adjust r, c to fit word there and test
				else check next letter
			if no letter matches are found or no valid placement for those letters is found, 
				assign random r, c

		If isAcross
			see if no mismatching overlapping cells
			Sandwhich test
				see if cell to left is free
				see if cell to right is free
			Overlap test
				Are cells above this word free?
				Are cells below this word free?
			see if cells above word are free
				If cell isn't free, legit crossing?
			see if cells below word are free
				if cell isn't free, legit crossing?
			If these pass, place the word and go to next.
		if not isAross
			see if no mismatching overlapping cells
			see if top cell is free
			see if bottom cell is free
			see if cells along left are free or legit
			see if cells along right are free or legit
			if these pass, place word

		Can't place hat, cat, cart in these places:
			HAT
			CAT 
		HAT
		C
		A
		T
			CART
			 H
			 A
			 T
		TRAIN_
		 C
		 A
		 R
		 T
		MONKEY

		Can place hat, cat, cart in these places:
		 H
		CART
		 T
			A
			CART
			T  R
			O  I
			R  M
*/


set NoCount On;
set RowCount 0;
drop table if exists #wordsCrossWord;
Drop Table if exists #WordClues;

Declare @debug bit = 1;			/*	set this to 0 to not provide text output to the Messages via print statements. */
Declare @PuzzleSize int = 60;	/*	this controls how many rows and columns the puzzle will have. May need to adjust for your needs. */

/*	This table holds our words and clues. */
Create Table #WordClues (
	ID int identity not null primary key,
	Word nvarchar(100) not null unique,
	Clue nvarchar(2000) not null,
	WordLength as len(Word),
	ClueLength as len(Clue),
	isAcross bit,
	OrderNum int not null default 0			/*	match the number here for the output cells	*/
);


/*	Add, remove, or change the words and clues below to customize this puzzle
	TODO: add a dictionary and allow random words list	*/
insert into #WordClues (Word, Clue) values 
	(N'bus', N'Transport some people'),
	(N'cart', N'Before the horse'),
	(N'scatter', N'Spread the things'),
	(N'Hat', N'On top'),
	(N'STEAM', N'Water+Heat'),
	(N'ACTOR', N'On screen'),
	(N'TRIM', N'Just a little off the top'),
	(N'Along', N'Not ashort'),
	(N'Mart', N'Shop Smart. Shop S___.'),
	(N'Train', N'Teach them and they can ride'),
	(N'Monkey', N'Likes bananas'),
	(N'Crossword', N'This thing'),
	(N'Invention', N'Edison and Tesla loved these'),
	(N'Overmorrow', N'Yesterday, today, tomorrow, ?'),
	(N'Independence', N'not so dependent'),
	(N'abbreviation', N'Shorten it'),
	(N'cabinetmaker', N'Makes things in the kitchen'),
	(N'Help', N'Sometimes you need ___'),
	(N'Plank', N'Walk the ___'),
	(N'Kraken', N'Release the ____'),
	(N'namelessness', N'The state of lacking a monicker'),
	(N'racketeering', N'Extortion, smuggling');



Drop Table If Exists #CrossWord;
Create Table #CrossWord (
	ID int not null identity Primary Key,
	RowNum int not null,
	ColNum int not null,
	CellValue nchar(1),
);

create Table #WordsCrossWord (
	ID int identity not null primary key,
	WordID int not null foreign key references #WordClues(ID),
	RowNum	int not null,
	ColNum int not null,
	isAcross bit not null
);



Declare @WordToPlace	nvarchar(100);							/*	the word we're currently processing	*/
Declare @WordToPlaceID	int;									/*	the id of the word we're processing	*/
declare @isAcross		bit				= 1;					/*	the flag for whether word is to be horizontal or vertical	*/
declare @CrLf			nvarchar(2)		= CHAR(13) + CHAR(10);	/*	for string output, make a line break	*/
declare @r				int				= -1;					/*	row number tracking */
declare @c				int				= -1;					/*	col number tracking	*/
declare @startR			int;									/*  where the 1st character of the word is placed	*/
declare @startC			int;					
declare @WordsPlaced	int				= 0;					/*	how many words have been assigned a place on the puzzle?	*/
declare @i				int;
declare @isBlocked		bit;									/*	flags when a word is blocked from placement; find a new spot. */
declare @maxTries		int				= 1000;					/*	how many attempts do we make at placing this word? */
declare @thisTry		int;									/*	where are we in the placement attempt loop?	*/
declare @i_PlacedWord int;
declare @i_CheckWord int;
declare @checkWordID int;
declare @CheckRowNum int;
declare @CheckColNum int;
declare @CheckWord nvarchar(100);

declare cUnassignedWords cursor for
	Select id, Word
	  from #WordClues
	 where isAcross is null
	 order by WordLength desc, NEWID();




Update #WordClues set Word = UPPER(Word);							/*	Clues are mixed case, but the puzzle words are always all uppercase	*/


 open cUnassignedWords;
 fetch next from cUnassignedWords into @WordToPlaceID, @WordToPlace;
 While @@FETCH_STATUS = 0 
 begin
	if @WordsPlaced < 1
 	begin
		if @debug = 1 
			print 'Placing word 1, Across: ' + @wordToPlace;

		set @r = @PuzzleSize / 2;
		set @c = (@PuzzleSize / 2) - (len(@WordToPlace) / 2);
		update #WordClues set isAcross = @isAcross, OrderNum = 1 where id = @WordToPlaceID;
		set @i = 0;
		while @i < LEN(@WordToPlace)
		begin
			set @i += 1;
			Update #CrossWord set CellValue = SUBSTRING(@WordToPlace, @i, 1)
			 Where RowNum = @r and ColNum = @c;
			
			insert into #WordsCrossWord (WordID, RowNum, ColNum, isAcross) values (@WordToPlaceID, @r, @c, @isAcross);

			set @c += 1;
		end;
		set @isAcross = ~@isAcross;
		set @WordsPlaced += 1;
		fetch next from cUnassignedWords into @WordToPlaceID, @WordToPlace;
		continue; /*	no need to do any of the complex check code for the 1st word, as there's no contention for space	*/
	end
	if @debug = 1 
		if @isAcross = 1
			print 'Placing word ' + cast(@wordsplaced + 1 as nvarchar) + ', Across: ' + @wordToPlace;
		else
			print 'Placing word ' + cast(@wordsplaced + 1 as nvarchar) + ', Down  : ' + @wordToPlace;
	


	declare cPlacedWords cursor for
		select WordID, RowNum, ColNum, Word
		  from #WordsCrossWord wcw
		 inner join #WordClues wc  on wc.id = wcw.WordID
		 where wcw.isAcross = ~@isAcross
		 order by newid();

	open cPlacedWords;
	fetch next from cPlacedWords into @CheckWordID, @CheckRowNum, @CheckColNum, @CheckWord;
	While @@FETCH_STATUS = 0 
	begin
		set @isBlocked = 0;
		set @i_PlacedWord = 1;
		set @i_CheckWord = 1;
		--for each letter in @WordToPlace
			--for each letter in @CheckWord
				--if letter matches,
					--test adjacent letters
						--if blocked, 
							--mark blocked 
					--if not blocked
						--place word
						--exit for loops
	
		fetch next from cPlacedWords into @CheckWordID, @CheckRowNum, @CheckColNum, @CheckWord;
	end;
	--if not placed, try up to maxTries to find a random location that works
	set @thisTry = 0;
	-- inside the place block
		set @isAcross = ~@isAcross;
		set @WordsPlaced += 1;
	-- /place block
	fetch next from cUnassignedWords into @WordToPlaceID, @WordToPlace;
 end;
 close cUnassignedWords;
 deallocate cUnassignedWords;