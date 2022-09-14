drop table if exists #PokerCards;
drop table if exists #pokerSuits;

create table #pokerSuits (
	ID int not null primary key identity,
	SuitName nvarchar(25),
	suitUnicode nvarchar(2),
	suitHtmlCode nvarchar(10)
)

Insert into #pokerSuits (SuitName, SuitUnicode, SuitHtmlCode) values
     ('Clubs', NCHAR(0x2663), '&#x2663;'), 
     ('Diamonds', NCHAR(0x2666), '&#x2666;'), 
     ('Hearts', NCHAR(0x2665), '&#x2665;'), 
     ('Spades', NCHAR(0x2660), '&#x2660;');

 select * from #pokerSuits;

create table #PokerCards (
	ID int not null primary key identity,
	pokerSuitID int foreign key references #pokerSuits(ID),
	CardName nvarchar(25),
	CardAbbreviation nvarchar(2),
	CardValue int,
	CardUnicode nvarchar(2),
	CardHtmlCode nvarchar(10)
);

Insert into #pokerCards (pokerSuitID, CardName, CardAbbreviation, CardValue, cardUnicode, cardHtmlCode) Values 
     (4, 'Ace', 'A', 1, NCHAR(0xD83C) + NCHAR(0xDCA1), '&#x1F0A1;'), 
     (4, 'Two', '2', 2, NCHAR(0xD83C) + NCHAR(0xDCA2), '&#x1F0A2;'), 
     (4, 'Three', '3', 3, NCHAR(0xD83C) + NCHAR(0xDCA3), '&#x1F0A3;'), 
     (4, 'Four', '4', 4, NCHAR(0xD83C) + NCHAR(0xDCA4), '&#x1F0A4;'), 
     (4, 'Five', '5', 5, NCHAR(0xD83C) + NCHAR(0xDCA5), '&#x1F0A5;'), 
     (4, 'Six', '6', 6, NCHAR(0xD83C) + NCHAR(0xDCA6), '&#x1F0A6;'), 
     (4, 'Seven', '7', 7, NCHAR(0xD83C) + NCHAR(0xDCA7), '&#x1F0A7;'), 
     (4, 'Eight', '8', 8, NCHAR(0xD83C) + NCHAR(0xDCA8), '&#x1F0A8;'), 
     (4, 'Nine', '9', 9, NCHAR(0xD83C) + NCHAR(0xDCA9), '&#x1F0A9;'), 
     (4, 'Ten', '10', 10, NCHAR(0xD83C) + NCHAR(0xDCAA), '&#x1F0AA;'), 
     (4, 'Jack', 'J', 11, NCHAR(0xD83C) + NCHAR(0xDCAB), '&#x1F0AB;'), 

     (4, 'Queen', 'Q', 13, NCHAR(0xD83C) + NCHAR(0xDCAD), '&#x1F0AD;'), 
     (4, 'King', 'K', 14, NCHAR(0xD83C) + NCHAR(0xDCAE), '&#x1F0AE;'), 
     (3, 'Ace', 'A', 1, NCHAR(0xD83C) + NCHAR(0xDCB1), '&#x1F0B1;'), 
     (3, 'Two', '2', 2, NCHAR(0xD83C) + NCHAR(0xDCB2), '&#x1F0B2;'), 
     (3, 'Three', '3', 3, NCHAR(0xD83C) + NCHAR(0xDCB3), '&#x1F0B3;'), 
     (3, 'Four', '4', 4, NCHAR(0xD83C) + NCHAR(0xDCB4), '&#x1F0B4;'), 
     (3, 'Five', '5', 5, NCHAR(0xD83C) + NCHAR(0xDCB5), '&#x1F0B5;'), 
     (3, 'Six', '6', 6, NCHAR(0xD83C) + NCHAR(0xDCB6), '&#x1F0B6;'), 
     (3, 'Seven', '7', 7, NCHAR(0xD83C) + NCHAR(0xDCB7), '&#x1F0B7;'), 
     (3, 'Eight', '8', 8, NCHAR(0xD83C) + NCHAR(0xDCB8), '&#x1F0B8;'), 
     (3, 'Nine', '9', 9, NCHAR(0xD83C) + NCHAR(0xDCB9), '&#x1F0B9;'), 
     (3, 'Ten', '10', 10, NCHAR(0xD83C) + NCHAR(0xDCBA), '&#x1F0BA;'), 
     (3, 'Jack', 'J', 11, NCHAR(0xD83C) + NCHAR(0xDCBB), '&#x1F0BB;'), 

     (3, 'Queen', 'Q', 13, NCHAR(0xD83C) + NCHAR(0xDCBD), '&#x1F0BD;'), 
     (3, 'King', 'K', 14, NCHAR(0xD83C) + NCHAR(0xDCBE), '&#x1F0BE;'), 
     (2, 'Ace', 'A', 1, NCHAR(0xD83C) + NCHAR(0xDCC1), '&#x1F0C1;'), 
     (2, 'Two', '2', 2, NCHAR(0xD83C) + NCHAR(0xDCC2), '&#x1F0C2;'), 
     (2, 'Three', '3', 3, NCHAR(0xD83C) + NCHAR(0xDCC3), '&#x1F0C3;'), 
     (2, 'Four', '4', 4, NCHAR(0xD83C) + NCHAR(0xDCC4), '&#x1F0C4;'), 
     (2, 'Five', '5', 5, NCHAR(0xD83C) + NCHAR(0xDCC5), '&#x1F0C5;'), 
     (2, 'Six', '6', 6, NCHAR(0xD83C) + NCHAR(0xDCC6), '&#x1F0C6;'), 
     (2, 'Seven', '7', 7, NCHAR(0xD83C) + NCHAR(0xDCC7), '&#x1F0C7;'), 
     (2, 'Eight', '8', 8, NCHAR(0xD83C) + NCHAR(0xDCC8), '&#x1F0C8;'), 
     (2, 'Nine', '9', 9, NCHAR(0xD83C) + NCHAR(0xDCC9), '&#x1F0C9;'), 
     (2, 'Ten', '10', 10, NCHAR(0xD83C) + NCHAR(0xDCCA), '&#x1F0CA;'), 
     (2, 'Jack', 'J', 11, NCHAR(0xD83C) + NCHAR(0xDCCB), '&#x1F0CB;'), 

     (2, 'Queen', 'Q', 13, NCHAR(0xD83C) + NCHAR(0xDCCD), '&#x1F0CD;'), 
     (2, 'King', 'K', 14, NCHAR(0xD83C) + NCHAR(0xDCCE), '&#x1F0CE;'), 
     (1, 'Ace', 'A', 1, NCHAR(0xD83C) + NCHAR(0xDCD1), '&#x1F0D1;'), 
     (1, 'Two', '2', 2, NCHAR(0xD83C) + NCHAR(0xDCD2), '&#x1F0D2;'), 
     (1, 'Three', '3', 3, NCHAR(0xD83C) + NCHAR(0xDCD3), '&#x1F0D3;'), 
     (1, 'Four', '4', 4, NCHAR(0xD83C) + NCHAR(0xDCD4), '&#x1F0D4;'), 
     (1, 'Five', '5', 5, NCHAR(0xD83C) + NCHAR(0xDCD5), '&#x1F0D5;'), 
     (1, 'Six', '6', 6, NCHAR(0xD83C) + NCHAR(0xDCD6), '&#x1F0D6;'), 
     (1, 'Seven', '7', 7, NCHAR(0xD83C) + NCHAR(0xDCD7), '&#x1F0D7;'), 
     (1, 'Eight', '8', 8, NCHAR(0xD83C) + NCHAR(0xDCD8), '&#x1F0D8;'), 
     (1, 'Nine', '9', 9, NCHAR(0xD83C) + NCHAR(0xDCD9), '&#x1F0D9;'), 
     (1, 'Ten', '10', 10, NCHAR(0xD83C) + NCHAR(0xDCDA), '&#x1F0DA;'), 
     (1, 'Jack', 'J', 11, NCHAR(0xD83C) + NCHAR(0xDCDB), '&#x1F0DB;'), 

     (1, 'Queen', 'Q', 13, NCHAR(0xD83C) + NCHAR(0xDCDD), '&#x1F0DD;'), 
     (1, 'King', 'K', 14, NCHAR(0xD83C) + NCHAR(0xDCDE), '&#x1F0DE;'), 

     (null, 'Back of Card', '', null, NCHAR(0xD83C) + NCHAR(0xDCA0), '&#x1F0A0;'), 
     (null, 'Joker, Black', 'Jb', null, NCHAR(0xD83C) + NCHAR(0xDCCF), '&#x1F0CF;'), 
     (null, 'Joker, White', 'Jw', null, NCHAR(0xD83C) + NCHAR(0xDCDF), '&#x1F0DF;'), 
     (null, 'Joker, Red', 'Jr', null, NCHAR(0xD83C) + NCHAR(0xDCBF), '&#x1F0BF;'); 






select * from #PokerCards;