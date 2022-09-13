--http://bradsruminations.blogspot.com/2010/04/playing-for-high-stakes.html
SET ANSI_WARNINGS OFF;
/*                                                Qnty     Qnty     Diff In
                          Num      Num             In     In 2nd  Value Btwn
    Hand         Hand  Distinct Distinct   Num  Largest  Largest  LowCard And 
Description    Points   Values    Suits  Groups  Group    Group     HighCard  Comments
----------------------------------------------------------------------------------------
Royal Flush        9       5        1       0     N/A      N/A         4      HiCard=Ace
Straight Flush     8       5        1       0     N/A      N/A         4
Four Of A Kind     7       2       N/A      1      4       N/A        N/A
Full House         6       2       N/A      2      3        2         N/A
Flush              5      N/A       1       0     N/A      N/A        N/A
Straight           4       5       N/A      0     N/A      N/A         4
Three Of A Kind    3       3       N/A      1      3       N/A        N/A
Two Pair           2       3       N/A      2      2        2         N/A
Two Of A Kind      1       4       N/A      1      2       N/A        N/A
*/
 
declare @CountNothing float(53) = 0;
declare @CountOnePair  float(53) = 0;          
declare @CountTwoPair  float(53) = 0;
declare @CountThreeOfKind  float(53) = 0;
declare @CountStraight  float(53) =0;     
declare @CountFlush  float(53) = 0;             
declare @CountFullHouse  float(53) = 0;                
declare @countFourOfKind  float(53) = 0;             
declare @countStraightFlush  float(53) = 0;        
declare @countRoyalFlush  float(53) = 0;         
 
DECLARE @cnt bigint = 0;

WHILE @cnt < 5000000
BEGIN
	
   declare PokerRun cursor for
-- Step 1, build a deck of cards
with DeckOfCards as
(
  select SpotValue
        ,SpotSymbol
        ,SuitSymbol
  from (values ('2',2),('3',3),('4',4),('5',5),('6',6)
              ,('7',7),('8',8),('9',9),('10',10)
              ,('J',11),('Q',12),('K',13),('A',14)) Spots(SpotSymbol,SpotValue)
  cross join (values (N'♠'),(N'♦'),(N'♣'),(N'♥')) Suits(SuitSymbol)
)
--select * from DeckOfCards
-- step 2, shuffle and deal the cards.
,ShuffleAndDeal as
(
  select PlayerID=(row_number() over (order by newid())-1) / 5 + 1
        ,CardName = SpotSymbol + SuitSymbol
        ,CardValue = SpotValue
        ,SuitSymbol
  from DeckOfCards
)  
--select * from ShuffleAndDeal

-- step 3, we will throw out the extra 2 cards of PlayerID 11 (WHERE PlayerID<=10). 
--Next, we will calculate the DENSE_RANK() of both the Card Values and the Suits. 
--We will also introduce a Card Sequence Number in order to sort the individual hands 
--(PARTITION BY PlayerID) by the Card Value (ORDER BY CardValue). 
--Finally, we are also going to introduce a Group Sequence Number, 
--which is similar to the Card Sequence Number, except it will be 
--PARTITIONed by both PlayerID and CardValue. This will become clearer when you look at some actual sample data below:v
,HandEvaluation1 as
(
  select PlayerID
        ,CardSeq=row_number() over (partition by PlayerID 
                                    order by CardValue)
        ,CardName
        ,CardValue
        ,SuitSymbol
        ,ValDenseRank=dense_rank() over (partition by PlayerID 
                                         order by CardValue)
        ,SuitDenseRank=dense_rank() over (partition by PlayerID 
                                          order by SuitSymbol)
        ,GroupSeq=row_number() over (partition by PlayerID,CardValue
                                     order by CardValue)
  from ShuffleAndDeal
  where PlayerID<=10
)
--select * from HandEvaluation1
-- calculate the MAX(ValDenseRank) and MAX(SuitDenseRank) values, 
--which, as I explained earlier, will give us the COUNT(DISTINCT) 
--of CardValues and Suits respectively. We will calculate the 
--MAX(GroupSeq) to figure out the quantity of cards in our largest group. 
--And we will calculate the MAX() and MIN() of the CardValue column to
--figure out the high and low card in the hand. This will be important in 
--figuring out whether a person has a Straight or not, because a Straight 
--will have a difference of 4 between the HighCardValue and LowCardValue.
,HandEvaluation2 as
(
  select PlayerID
        ,CardSeq
        ,CardName
        ,CardValue
        ,GroupSeq
        ,NumDistinctVals=max(ValDenseRank) over (partition by PlayerID)
        ,NumDistinctSuits=max(SuitDenseRank) over (partition by PlayerID)
        ,QtyInLargestGroup=max(GroupSeq) over (partition by PlayerID)
        ,HighCardValue=max(CardValue) over (partition by PlayerID)
        ,LowCardValue=min(CardValue) over (partition by PlayerID)
  from HandEvaluation1 
)
/*
select PlayerID
      ,CardName
      ,NumDistinctVals 
      ,NumDistinctSuits 
      ,QtyInLargestGroup 
from HandEvaluation2
*/
--figure out the CardValue of the largest group. 
--It does this by looking for a card that has a GroupSeq>1 
--(indicating that it is part of a group) and it has a GroupSeq 
--equal to the QtyInLargestGroup column, which we calculated in HandEvaluation2. 
--Note that we apply a MAX() aggregate. This is because a person may have 
--Two Pair… there are two groups, each with 2 cards. 
--The QtyInLargestGroup is 2, but in reality, it’s the quantity in both groups, 
--so by using the MAX() aggregate we get the CardValue of the highest pair.
,HandEvaluation3 as
(
  select PlayerID
        ,CardSeq
        ,CardName
        ,CardValue
        ,GroupSeq
        ,NumDistinctVals
        ,NumDistinctSuits
        ,QtyInLargestGroup
        ,HighCardValue
        ,LowCardValue
        ,CardValueInLargestGroup=max(case 
                                       when GroupSeq>1 
                                            and GroupSeq=QtyInLargestGroup
                                       then CardValue 
                                       else 0 
                                     end) 
                                 over (partition by PlayerID)
  from HandEvaluation2
)
-- figure out the CardValue of the second largest group. 
--It does this in a similar way to HandEvaluation3, 
--except it just makes sure that the CardValue is NOT the CardValue of the first largest group.
,HandEvaluation4 as
(
  select PlayerID
        ,CardSeq
        ,CardName
        ,CardValue
        ,GroupSeq
        ,NumDistinctVals
        ,NumDistinctSuits
        ,QtyInLargestGroup
        ,HighCardValue
        ,LowCardValue
        ,CardValueInLargestGroup
        ,CardValueIn2ndLargestGroup=max(case 
                                          when GroupSeq>1 
                                               and CardValue<>CardValueInLargestGroup
                                          then CardValue 
                                          else 0
                                        end)
                                    over (partition by PlayerID)
  from HandEvaluation3
)
/*
select PlayerID
      ,CardName
      ,QtyInLargestGroup
      ,CardValueInLargestGroup 
      ,CardValueIn2ndLargestGroup 
from HandEvaluation4
*/
--Now comes the part of evaluating the individual non-group loner cards. 
--Instead of trying to evaluate them individually, 
--I decided to put together a string containing all their values. 
--This way, in order to evaluate whether one Player’s hand outranks another, 
--I could just compare strings instead of trying to compare a bunch of individual cards. 
--So the CTE HandEvaluation5 will concatenate together those lone cards into a column called LoneCardValString.
,HandEvaluation5 as
(
  select PlayerID
        ,CardSeq
        ,CardName
        ,CardValue
        ,GroupSeq
        ,NumDistinctVals
        ,NumDistinctSuits
        ,QtyInLargestGroup
        ,HighCardValue
        ,LowCardValue
        ,CardValueInLargestGroup
        ,CardValueIn2ndLargestGroup
        ,LoneCardValString=coalesce(
                             str(
                               max(case
                                     when CardSeq=5
                                          and CardValue<>CardValueInLargestGroup 
                                          and CardValue<>CardValueIn2ndLargestGroup 
                                     then CardValue
                                   end) over (partition by PlayerID)
                               ,2)
                             ,'')
                          +coalesce(
                             str(
                               max(case
                                     when CardSeq=4
                                          and CardValue<>CardValueInLargestGroup 
                                          and CardValue<>CardValueIn2ndLargestGroup 
                                     then CardValue
                                   end) over (partition by PlayerID)
                               ,2)
                             ,'')
                          +coalesce(
                             str(
                               max(case
                                     when CardSeq=3
                                          and CardValue<>CardValueInLargestGroup 
                                          and CardValue<>CardValueIn2ndLargestGroup 
                                     then CardValue
                                   end) over (partition by PlayerID)
                               ,2)
                             ,'')
                          +coalesce(
                             str(
                               max(case
                                     when CardSeq=2
                                          and CardValue<>CardValueInLargestGroup 
                                          and CardValue<>CardValueIn2ndLargestGroup 
                                     then CardValue
                                   end) over (partition by PlayerID)
                               ,2)
                             ,'')
                          +coalesce(
                             str(
                               max(case
                                     when CardSeq=1
                                          and CardValue<>CardValueInLargestGroup 
                                          and CardValue<>CardValueIn2ndLargestGroup 
                                     then CardValue
                                   end) over (partition by PlayerID)
                               ,2)
                             ,'')
  from HandEvaluation4
)
/*
select PlayerID
      ,CardName
      ,CardValueInLargestGroup
      ,CardValueIn2ndLargestGroup
      ,LoneCardValString 
from HandEvaluation5
*/
--Now comes the time to figure out what hand each player has. 
--The CTE HandEvaluation6 will assign a HandPoints column with a value of 0 through 9, 
--where 0 represents a “Nothing” hand and 1 represents Two of a Kind, up to 9, 
--which represents a Royal Flush. This is done based on the table of rules that 
--I had presented towards the beginning of this article.
,HandEvaluation6 as
(
  select PlayerID
        ,CardSeq
        ,CardName
        ,CardValueInLargestGroup
        ,CardValueIn2ndLargestGroup
        ,LoneCardValString
        ,HandPoints=case
                      /* Royal Flush: */
                      when NumDistinctSuits=1
                           and NumDistinctVals=5
                           and HighCardValue-LowCardValue=4
                           and HighCardValue=14
                      then 9
                      /* Straight Flush: */
                      when NumDistinctSuits=1
                           and NumDistinctVals=5
                           and HighCardValue-LowCardValue=4
                      then 8
                      /* Four of a Kind: */
                      when QtyInLargestGroup=4
                      then 7
                      /* Full House: */
                      when QtyInLargestGroup=3
                           and CardValueIn2ndLargestGroup<>0
                      then 6
                      /* Flush: */
                      when NumDistinctSuits=1
                      then 5
                      /* Straight: */   
                      when NumDistinctVals=5
                       and HighCardValue-LowCardValue=4
                      then 4
                      /* Three of a Kind: */
                      when QtyInLargestGroup=3
                      then 3
                      /* Two Pair: */
                      when QtyInLargestGroup=2
                           and NumDistinctVals=3
                      then 2
                      /* Two of a Kind: */
                      when QtyInLargestGroup=2
                      then 1
                      /* Nothing: */
                      else 0
                    end
  from HandEvaluation5 
)
--Then the CTE HandEvaluation7 will assign a HandDescript column with a string describing the type of hand. 
--It also calculates a PlayerRanking column, which will rank the players on the following combination: 
--HandPoints (based on the kind of poker hand the player has), CardValueInLargestGroup, 
--CardValueIn2ndLargestGroup, and finally, the LoneCardValString.
,HandEvaluation7 as
(
  select PlayerID
        ,CardSeqName = 'Card' + str(CardSeq,1)
        ,CardName
        ,HandDescript=case
                        when HandPoints=9 then 'Royal Flush'
                        when HandPoints=8 then 'Straight Flush'
                        when HandPoints=7 then 'Four of a Kind'
                        when HandPoints=6 then 'Full House'
                        when HandPoints=5 then 'Flush'
                        when HandPoints=4 then 'Straight'
                        when HandPoints=3 then 'Three of a Kind'
                        when HandPoints=2 then 'Two Pair'
                        when HandPoints=1 then 'One Pair'
                        else 'Nothing'
                      end
        ,PlayerRanking=dense_rank() over (order by HandPoints desc
                                                  ,CardValueInLargestGroup desc
                                                  ,CardValueIn2ndLargestGroup desc
                                                  ,LoneCardValString desc)
  from HandEvaluation6
)
/*
select PlayerID
      ,CardSeqName
      ,CardName
      ,HandDescript
      ,PlayerRanking
from HandEvaluation7
order by PlayerRanking
*/
-- the final piece of the puzzle is to PIVOT all those 50 rows into just 10. 
--Each row will show the PlayerID, his hand, and the description of that hand. 
--The 10 players will be output in descending order of rank, so that the player on top 
--is the winner of the round. Note that the CTE HandEvaluation7 above already 
--created a new column called CardSeqName with the values 'Card1' through 'Card5', 
--and we can use that column to PIVOT on in the final query.
/*
select PlayerID
      ,Hand=Card1+' '+Card2+' '+Card3+' '+Card4+' '+Card5
      ,HandDescript
from HandEvaluation7
pivot (max(CardName) for CardSeqName in (Card1,Card2,Card3,Card4,Card5)) P
order by PlayerRanking
*/
/*
TO DO:
write a loop to track the odds of getting a specific hand.
goal is something like :
 
HandDescript    Occurrences PercentOccurred		WikiPedia prob.	Odds against
-------------------------------------------
Nothing           1,303,701      50.162411%		50.1177%			  0.995	   : 1
Two of a Kind     1,098,481      42.266176%		42.2569%		      1.366    : 1
Two Pair            123,259       4.742628%		 4.7539%			     20    : 1
Three of a Kind      54,955       2.114500%		 2.1128%			     46.33 : 1
Straight              9,095       0.349948%		 0.3925%			    253.8  : 1
Flush                 5,007       0.192654%		 0.1965%			    508.8  : 1
Full House            3,777       0.145327%      0.1441%			    693.17 : 1	  
Four of a Kind          653       0.025125%		 0.0240%			  4,165	   : 1
Straight Flush           24       0.000923%		 0.00139			 72,192.33 : 1
Royal Flush               8       0.000308%		 0.000154%			649,739    : 1
-------------------------------------------
GRAND TOTAL       2,598,960     100.000000%

and the results should be similar to:
http://en.wikipedia.org/wiki/Poker_probability
*/
--Draw one hand of poker:
	select PlayerID
      ,Hand = Card1 + ' ' + Card2 + ' ' + Card3 + ' ' + Card4 + ' ' + Card5
      ,HandDescript
	from HandEvaluation7
	pivot (max(CardName) for CardSeqName in (Card1,Card2,Card3,Card4,Card5)) P
	order by PlayerRanking	;

	Declare @PlayerID int = 0;
	declare @PlayerHand nvarchar(50) = N'';
	declare @HandDescript nvarchar(50) = N'';
		 
	Open PokerRun;
	 
	FETCH NEXT FROM PokerRun   
	INTO @PlayerID, @PlayerHand, @HandDescript 
 
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		if @handDescript is null
			print N'NULL HAND!';
		else if @HandDescript = 'Nothing'
			set @CountNothing = @CountNothing + 1;
		else if @HandDescript = 'One Pair'
			set @CountOnePair = @CountOnePair + 1;
		else if @HandDescript = 'Two Pair'
			set @CountTwoPair = @CountTwoPair + 1;
		else if @HandDescript = 'Three of a Kind'
			set @CountThreeOfKind = @CountThreeOfKind + 1;
		else if @HandDescript = 'Straight'
			set @CountStraight = @CountStraight + 1;
		else if @HandDescript = 'Flush'
			set @CountFlush = @CountFlush + 1;
		else if @HandDescript = 'Full House'
			set @CountFullHouse = @CountFullHouse + 1;
		else if @HandDescript = 'Four of a Kind'
			set @countFourOfKind = @countFourOfKind + 1;
		else if @HandDescript = 'Straight Flush'
			set @countStraightFlush = @countStraightFlush + 1;
		else if @HandDescript = 'Royal Flush'
			set @countRoyalFlush = @countRoyalFlush + 1;
		else
			print N'Bad hand: ' + @handDescript;

		SET @cnt = @cnt + 1;

		FETCH NEXT FROM PokerRun   
		INTO @PlayerID, @PlayerHand , @HandDescript
	end; 

	CLOSE PokerRun;  
	DEALLOCATE PokerRun;  

	if @cnt % 25000 = 0
		print N'Loop is at ' + format(@cnt, '#,##0');
end

select 1 Ordr, 'Nothing: ' Hand, @CountNothing Cnt, ((@CountNothing / @cnt) * 100) Pct union
select 2, 'One Pair: ' Hand, @CountOnePair Cnt, ((@CountOnePair / @cnt) * 100) Pct union
select 3, 'Two Pair: ' Hand, @CountTwoPair Cnt, ((@CountTwoPair / @cnt)  * 100) Pct union 
select 4, 'Three of a Kind: ' Hand, @CountThreeOfKind Cnt, ((@CountThreeOfKind / @cnt)  * 100) Pct  union
select 5, 'Straight: ' Hand, @CountStraight Cnt, ((@CountStraight / @cnt)  * 100) Pct  union
select 6, 'Flush: ' Hand, @CountFlush Cnt, ((@CountFlush / @cnt)  * 100) Pct  union
select 7, 'Full House: ' Hand, @CountFullHouse Cnt, ((@CountFullHouse / @cnt)  * 100) Pct union 
select 8, 'Four of a Kind: ' Hand, @countFourOfKind Cnt, ((@countFourOfKind / @cnt)  * 100) Pct  union
select 9, 'Straight Flush: ' Hand, @countStraightFlush Cnt, ((@countStraightFlush / @cnt)  * 100) Pct  union
select 10, 'Royal Flush: ' Hand, @countRoyalFlush Cnt, ((@countRoyalFlush / @cnt)  * 100) Pct union
select 11, 'GRAND TOTAL: ' Hand, @Cnt, ((@cnt / @cnt)  * 100)  
order by 1;

/*
Ordr	Hand				Cnt	Pct
1		Nothing: 			2,508,172	 50.16344
2		One Pair: 			2,112,013	 42.24026
3		Two Pair: 			  238,091	  4.76182
4		Three of a Kind: 	  105,825	  2.1165
5		Straight: 			   17,724	  0.35448
6		Flush: 				    9,854	  0.19708
7		Full House: 		    7,052	  0.14104
8		Four of a Kind: 	    1,186	  0.02372
9		Straight Flush: 	       74	  0.00148
10		Royal Flush: 		        9	  0.00018
11		GRAND TOTAL: 		5,000,000	100
*/