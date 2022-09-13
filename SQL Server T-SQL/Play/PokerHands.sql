--http://bradsruminations.blogspot.com/2010/04/playing-for-high-stakes.html
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
,ShuffleAndDeal as
(
  select PlayerID=(row_number() over (order by newid())-1)/5+1
        ,CardName=SpotSymbol+SuitSymbol
        ,CardValue=SpotValue
        ,SuitSymbol
  from DeckOfCards
)  
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
,HandEvaluation7 as
(
  select PlayerID
        ,CardSeqName='Card'+str(CardSeq,1)
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
                        when HandPoints=1 then 'Two of a Kind'
                        else 'Nothing'
                      end
        ,PlayerRanking=dense_rank() over (order by HandPoints desc
                                                  ,CardValueInLargestGroup desc
                                                  ,CardValueIn2ndLargestGroup desc
                                                  ,LoneCardValString desc)
  from HandEvaluation6
)
select PlayerID
      ,Hand=Card1+' '+Card2+' '+Card3+' '+Card4+' '+Card5
      ,HandDescript
from HandEvaluation7
pivot (max(CardName) for CardSeqName in (Card1,Card2,Card3,Card4,Card5)) P
order by PlayerRanking



