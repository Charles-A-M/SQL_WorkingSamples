drop table if exists #tarotCards;
drop table if exists #tarotSuits;

create table #tarotSuits (
	ID int not null primary key identity,
	SuitName nvarchar(25),
	SuitUnicode nvarchar(2),
	SuitHtmlCode nvarchar(10)
);

Insert into #tarotSuits (SuitName, SuitUnicode, SuitHtmlCode) values
     ('Wands', NCHAR(0x2663), '&#x2663;'), 
     ('Pentacles', NCHAR(0x2666), '&#x2666;'), 
     ('Cups', NCHAR(0x2665), '&#x2665;'), 
     ('Swords', NCHAR(0x2660), '&#x2660;'),
	 ('Trumps', null, null);
 ;

select * from #tarotSuits

create table #tarotCards (
	ID int not null primary key identity,
	tarotSuitID int foreign key references #TarotSuits(ID),
	CardName nvarchar(50),
	CardAbbreviation nvarchar(10),
	CardValue int,
	CardUnicode nvarchar(2),
	CardHtmlCode nvarchar(10)
);

Insert into #tarotCards (tarotSuitID, CardName, CardAbbreviation, CardValue, cardUnicode, cardHtmlCode) Values 
     (5, 'The Fool', '0', 0, NCHAR(0xD83C) + NCHAR(0xDCE0), '&#x1F0E0;'), 
     (5, 'The Magician', 'I', 1, NCHAR(0xD83C) + NCHAR(0xDCE1), '&#x1F0E1;'), 
     (5, 'The High Priestess', 'II', 2, NCHAR(0xD83C) + NCHAR(0xDCE2), '&#x1F0E2;'), 
     (5, 'The Empress', 'III', 3, NCHAR(0xD83C) + NCHAR(0xDCE3), '&#x1F0E3;'), 
     (5, 'The Emperor', 'IV', 4, NCHAR(0xD83C) + NCHAR(0xDCE4), '&#x1F0E4;'), 
     (5, 'TheHierophant', 'V', 5, NCHAR(0xD83C) + NCHAR(0xDCE5), '&#x1F0E5;'), 
     (5, 'The Lovers', 'VI', 6, NCHAR(0xD83C) + NCHAR(0xDCE6), '&#x1F0E6;'), 
     (5, 'The Chariot', 'VII', 7, NCHAR(0xD83C) + NCHAR(0xDCE7), '&#x1F0E7;'), 
     (5, 'Strength', 'VIII', 8, NCHAR(0xD83C) + NCHAR(0xDCE8), '&#x1F0E8;'), 
     (5, 'The Hermit', 'IX', 9, NCHAR(0xD83C) + NCHAR(0xDCE9), '&#x1F0E9;'), 
     (5, 'The Wheel of Fortune', 'X', 10, NCHAR(0xD83C) + NCHAR(0xDCEA), '&#x1F0EA;'), 
     (5, 'Justice', 'XI', 11, NCHAR(0xD83C) + NCHAR(0xDCEB), '&#x1F0EB;'), 
     (5, 'The Hanged Man', 'XII', 12, NCHAR(0xD83C) + NCHAR(0xDCEC), '&#x1F0EC;'), 
     (5, 'Death', 'XIII', 13, NCHAR(0xD83C) + NCHAR(0xDCED), '&#x1F0ED;'), 
     (5, 'Temperance', 'XIV', 14, NCHAR(0xD83C) + NCHAR(0xDCEE), '&#x1F0EE;'), 
     (5, 'The Devil', 'XV', 15, NCHAR(0xD83C) + NCHAR(0xDCEF), '&#x1F0EF;'), 
     (5, 'The Tower', 'XVI', 16, NCHAR(0xD83C) + NCHAR(0xDCF0), '&#x1F0F0;'), 
     (5, 'The Star', 'XVII', 17, NCHAR(0xD83C) + NCHAR(0xDCF1), '&#x1F0F1;'), 
     (5, 'The Moon', 'XVIII', 18, NCHAR(0xD83C) + NCHAR(0xDCF2), '&#x1F0F2;'), 
     (5, 'The Sun', 'XIX', 19, NCHAR(0xD83C) + NCHAR(0xDCF3), '&#x1F0F3;'), 
     (5, 'The Last Judgement', 'XX', 20, NCHAR(0xD83C) + NCHAR(0xDCF4), '&#x1F0F4;'), 
     (5, 'The World', 'XXI', 21, NCHAR(0xD83C) + NCHAR(0xDCF5), '&#x1F0F5;'), 
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
     (4, 'Knight', 'Kn', 12, NCHAR(0xD83C) + NCHAR(0xDCAC), '&#x1F0AC;'), 
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
     (3, 'Knight', 'Kn', 12, NCHAR(0xD83C) + NCHAR(0xDCBC), '&#x1F0BC;'), 
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
     (2, 'Knight', 'Kn', 12, NCHAR(0xD83C) + NCHAR(0xDCCC), '&#x1F0CC;'), 
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
     (1, 'Knight', 'Kn', 12, NCHAR(0xD83C) + NCHAR(0xDCDC), '&#x1F0DC;'), 
     (1, 'Queen', 'Q', 13, NCHAR(0xD83C) + NCHAR(0xDCDD), '&#x1F0DD;'), 
     (1, 'King', 'K', 14, NCHAR(0xD83C) + NCHAR(0xDCDE), '&#x1F0DE;'), 
     (null, 'Back of Card', null, null, NCHAR(0xD83C) + NCHAR(0xDCA0), '&#x1F0A0;'); 


select * from #tarotCards;