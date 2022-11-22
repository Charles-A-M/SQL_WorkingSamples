/*
	There are a number of factors tables and such "Astronomical Algorithms Second Edition" by Jean Meeus, 1998.
	These values are recreated here for functions to use as needed.

*/

drop table if exists dbo.MeeusLookupTableValues;
drop table if exists dbo.MeeusLookupTables;
go

Create Table dbo.MeeusLookupTables (
	ID int not null identity primary key, 
	Chapter nvarchar(15),
	TableNumber nvarchar(15),
	PageNumber smallint,
	TableName nvarchar(250),
	Header_Factor1 nvarchar(200),
	Header_Factor2 nvarchar(200),
	Header_Factor3 nvarchar(200),
	Header_Factor4 nvarchar(200),
	Header_Factor5 nvarchar(200),
	Header_Factor6 nvarchar(200),
	Header_Factor7 nvarchar(200),
	Header_Factor8 nvarchar(200),
	Header_Factor9 nvarchar(200)
);
Insert Into dbo.MeeusLookupTables (chapter, tableNumber, pagenumber, tablename, Header_Factor1, Header_Factor2) values (N'10', N'10.A', 79, N'ΔT for given years', N'Year', N'ΔT in Seconds');
Insert Into dbo.MeeusLookupTables (chapter, tableNumber, pagenumber, tablename, Header_Factor1, Header_Factor2, Header_Factor3, Header_Factor4, Header_Factor5, Header_Factor6) values (N'47', N'47.A', 339, N'Periodic terms for longitude (Σl) and distance (Σr) of the Moon.', 		'Mulitple of D', 'Multiple of M', 'Multiple of M''', 'Multiple of F', 'Σl coefficient of the sin of argument', 'Σr coefficient of the cos of argument')
Insert Into dbo.MeeusLookupTables (chapter, tableNumber, pagenumber, tablename, Header_Factor1, Header_Factor2, Header_Factor3, Header_Factor4, Header_Factor5) values (N'47', N'47.B', 341, N'Periodic terms for latitude (Σb) of the Moon.', 'Mulitple of D', 'Multiple of M', 'Multiple of M''', 'Multiple of F', 'Σb coefficient of the cos of argument')
Insert Into dbo.MeeusLookupTables (chapter, tableNumber, pagenumber, tablename, Header_Factor1, Header_Factor2, Header_Factor3, Header_Factor4, Header_Factor5, Header_Factor6, Header_Factor7, Header_Factor8, Header_Factor9) values (N'22', N'22.A', 145, N'Nutation: y = D+M+M''+F+Ω'', Δψ = a+b sin(y),  Δε = c+d cos(y)',    N'Multiple of D', N'Multiple of M', N'Multiple of M''', N'Multiple of F', N'Multiple of Ω', N'a', N'b * T', N'c', N'd*T');
go

Create Table dbo.MeeusLookupTableValues (
	ID int not null identity primary key,
	TableID int not null foreign key references dbo.MeeusLookupTables(ID),
	Factor1 float,
	Factor2 float,
	Factor3 float,
	Factor4 float,
	Factor5 float,
	Factor6 float,
	Factor7 float,
	Factor8 float,
	Factor9 float
);
go

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1620, 121 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1622, 112 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1624, 103 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1626, 95 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1628, 88 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1630, 82 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1632, 77 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1634, 72 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1636, 68 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1638, 63 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1640, 60 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1642, 56 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1644, 53 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1646, 51 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1648, 48 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1650, 46 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1652, 44 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1654, 42 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1656, 40 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1658, 38 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1660, 35 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1662, 33 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1664, 31 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1666, 29 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1668, 26 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1670, 24 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1672, 22 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1674, 20 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1676, 18 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1678, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1680, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1682, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1684, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1686, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1688, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1690, 8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1692, 7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1694, 7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1696, 7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1698, 7 ); 

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1700, 7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1702, 7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1704, 8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1706, 8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1708, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1710, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1712, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1714, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1716, 9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1718, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1720, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1722, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1724, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1726, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1728, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1730, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1732, 10 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1734, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1736, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1738, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1740, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1742, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1744, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1746, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1748, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1750, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1752, 13 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1754, 13 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1756, 13 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1758, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1760, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1762, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1764, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1766, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1768, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1770, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1772, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1774, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1776, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1778, 16 ); 

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1780, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1782, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1784, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1786, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1788, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1790, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1792, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1794, 15 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1796, 14 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1798, 13 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1800, 13.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1802, 12.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1804, 12.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1806, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1808, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1810, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1812, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1814, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1816, 12 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1818, 11.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1820, 11.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1822, 11 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1824, 10.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1826, 9.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1828, 8.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1830, 7.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1832, 6.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1834, 5.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1836, 5.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1838, 5.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1840, 5.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1842, 5.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1844, 5.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1846, 6.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1848, 6.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1850, 6.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1852, 7.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1854, 7.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1856, 7.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1858, 7.6 ); 

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1860, 7.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1862, 7.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1864, 6.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1866, 5.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1868, 2.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1870, 1.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1872, -1.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1874, -2.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1876, -3.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1878, -4.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1880, -5.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1882, -5.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1884, -5.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1886, -5.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1888, -5.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1890, -6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1892, -6.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1894, -6.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1896, -6.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1898, -4.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1900, -2.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1902, -0.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1904, 2.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1906, 5.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1908, 7.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1910, 10.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1912, 13.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1914, 16 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1916, 18.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1918, 20.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1920, 21.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1922, 22.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1924, 23.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1926, 23.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1928, 24.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1930, 24 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1932, 23.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1934, 23.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1936, 23.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1938, 24 ); 

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1940, 24.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1942, 25.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1944, 26.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1946, 27.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1948, 28.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1950, 29.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1952, 30 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1954, 30.7 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1956, 31.4 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1958, 32.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1960, 33.1 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1962, 34 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1964, 35 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1966, 36.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1968, 38.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1970, 40.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1972, 42.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1974, 44.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1976, 46.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1978, 48.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1980, 50.5 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1982, 52.2 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1984, 53.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1986, 54.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1988, 55.8 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1990, 56.9 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1992, 58.3 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1994, 60 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1996, 61.6 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1998, 63 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2) Values (1, 1977, 48 ); 
go



Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 1, 0, 6288774, -20905355 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, -1, 0, 1274027, -3699111 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 0, 0, 658314, -2955968 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 2, 0, 213618, -569925 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 1, 0, 0, -185116, 48888 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 0, 2, -114332, -3149 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, -2, 0, 58793, 246158 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, -1, 0, 57066, -152138 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 1, 0, 53322, -170733 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, 0, 0, 45758, -204586 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 1, -1, 0, -40923, -129620 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 0, 0, 0, -34720, 108743 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 1, 1, 0, -30383, 104755 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 0, -2, 15327, 10321 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 1, 2, -12528, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 1, -2, 10980, 79661 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, 0, -1, 0, 10675, -34782 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 3, 0, 10034, -23210 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, 0, -2, 0, 8548, -21636 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 1, -1, 0, -7888, 24208 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 1, 0, 0, -6766, 30824 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 0, -1, 0, -5163, -8379 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 1, 0, 0, 4987, -16675 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, 1, 0, 4036, -12831 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 2, 0, 3994, -10445 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, 0, 0, 0, 3861, -11650 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, -3, 0, 3665, 14403 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 1, -2, 0, -2689, -7003 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, -1, 2, -2602, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, -2, 0, 2390, 10056 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 0, 1, 0, -2348, 6322 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -2, 0, 0, 2236, -9884 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 1, 2, 0, -2120, 5751 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 2, 0, 0, -2069, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -2, -1, 0, 2048, -4950 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 1, -2, -1773, 4130 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 0, 2, -1595, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, -1, -1, 0, 1215, -3958 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 2, 2, -1110, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 3, 0, -1, 0, -892, 3258 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 1, 1, 0, -810, 2616 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, -1, -2, 0, 759, -1897 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 2, -1, 0, -713, -2117 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 2, -1, 0, -700, 2354 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 1, -2, 0, 691, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, 0, -2, 596, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, 0, 1, 0, 549, -1423 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 4, 0, 537, -1117 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, -1, 0, 0, 520, -1571 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 0, -2, 0, -487, -1739 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 1, 0, -2, -399, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 0, 2, -2, -381, -4421 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 1, 1, 0, 351, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 3, 0, -2, 0, -340, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 4, 0, -3, 0, 330, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, -1, 2, 0, 327, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 0, 2, 1, 0, -323, 1165 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 1, 1, -1, 0, 299, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, 3, 0, 294, 0 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6) Values (2, 2, 0, -1, -2, 0, 8752 ); 
go

Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 0, 1, 5128122 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 1, 1, 280602 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 1, -1, 277693 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 0, -1, 173237 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, -1, 1, 55413 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, -1, -1, 46271 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 0, 1, 32573 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 2, 1, 17198 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 1, -1, 9266 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 2, -1, 8822 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, 0, -1, 8216 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, -2, -1, 4324 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 1, 1, 4200 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 1, 0, -1, -3359 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, -1, 1, 2463 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, 0, 1, 2211 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, -1, -1, 2065 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, -1, -1, -1870 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, -1, -1, 1828 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, 0, 1, -1794 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 0, 3, -1749 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, -1, 1, -1565 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 0, 0, 1, -1491 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, 1, 1, -1475 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, 1, -1, -1410 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, 0, -1, -1344 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 0, 0, -1, -1335 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 3, 1, 1107 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, 0, -1, 1021 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, -1, 1, 883 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 1, -3, 777 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, -2, 1, 671 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 0, -3, 607 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 2, -1, 596 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, 1, -1, 491 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, -2, 1, -451 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 3, -1, 439 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, 2, 1, 422 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 0, -3, -1, 421 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 1, -1, 1, -366 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 1, 0, 1, -351 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, 0, 1, 331 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, 1, 1, 315 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -2, 0, -1, 302 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 0, 1, 3, -283 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 1, 1, -1, -229 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 1, 0, -1, 223 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 1, 0, 1, 223 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, -2, -1, -220 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, 1, -1, -1, -220 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 0, 1, 1, -185 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -1, -2, -1, 181 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 0, 1, 2, 1, -177 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, -2, -1, 176 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, -1, -1, -1, 166 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 0, 1, -1, -164 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, 0, 1, -1, 132 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 1, 0, -1, -1, -119 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 4, -1, 0, -1, 115 ); 
Insert Into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5) Values (3, 2, -2, 0, 1, 107 ); 

--22.A
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 0, 0, 1, -171996, -174.2, 92025, 8.9 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 0, 2, 2, -13187, -1.6, 5736, -3.1 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 0, 2, 2, -2274, -0.2, 977, -0.5 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 0, 0, 2, 2062, 0.2, -895, 0.5 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 1, 0, 0, 0, 1426, -3.4, 54, -0.1 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, 0, 0, 712, 0.1, -7, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 1, 0, 2, 2, -517, 1.2, 224, -0.6 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 0, 2, 1, -386, -0.4, 200, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, 2, 2, -301, 0, 129, -0.1 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, -1, 0, 2, 2, 217, -0.5, -95, 0.3 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 1, 0, 0, -158, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 0, 2, 1, 129, 0.1, -70, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, -1, 2, 2, 123, 0, -53, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 0, 0, 0, 63, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, 0, 1, 63, 0.1, -33, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, -1, 2, 2, -59, 0, 26, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, -1, 0, 1, -58, -0.1, 32, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, 2, 1, -51, 0, 27, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 2, 0, 0, 48, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, -2, 2, 1, 46, 0, -24, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 0, 2, 2, -38, 0, 16, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 2, 2, 2, -31, 0, 13, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 2, 0, 0, 29, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 1, 2, 2, 29, 0, -12, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 0, 2, 0, -22, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, -1, 2, 1, 21, 0, -10, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 2, 0, 0, 0, 17, -0.1, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, -1, 0, 1, 16, 0, -8, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 2, 0, 2, 2, -16, 0.1, 7, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 1, 0, 0, 1, -15, 0, 9, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 1, 0, 1, -13, 0, 7, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, -1, 0, 0, 1, -12, 0, 6, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 2, -2, 0, 11, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, -1, 2, 1, -10, 0, 5, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 1, 2, 2, -8, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 1, 0, 2, 2, 7, 0, -3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 1, 1, 0, 0, -7, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, -1, 0, 2, 2, -7, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 0, 2, 1, -7, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 1, 0, 0, 6, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 2, 2, 2, 6, 0, -3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 1, 2, 1, 6, 0, -3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, -2, 0, 1, -6, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, 0, 0, 0, 1, -6, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, -1, 1, 0, 0, 5, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, -1, 0, 2, 1, -5, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 0, 0, 1, -5, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 2, 2, 1, -5, 0, 3, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 0, 2, 0, 1, 4, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -2, 1, 0, 2, 1, 4, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, -2, 0, 4, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 1, 2, 0, 3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, -2, 2, 2, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, -1, -1, 1, 0, 0, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 1, 1, 0, 0, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, -1, 1, 2, 2, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, -1, -1, 2, 2, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 0, 0, 3, 2, 2, -3, 0, 0, 0 ); 
insert into dbo.MeeusLookupTableValues (TableID, Factor1, Factor2, Factor3, Factor4, Factor5, Factor6, Factor7, Factor8, Factor9) values (4, 2, -1, 0, 2, 2, -3, 0, 0, 0 ); 


