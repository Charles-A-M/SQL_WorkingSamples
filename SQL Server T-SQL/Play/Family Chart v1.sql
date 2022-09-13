-- http://bradsruminations.blogspot.com/2009/10/viva-la-famiglia.html

if object_id('OurFamily') is not null 
drop table OurFamily;
go
  
create table OurFamily
(
   ID         int primary key
  ,FirstName  nvarchar(500)
  ,LastName   nvarchar(500)
  ,Gender     char(1)
  ,ParentID   int  --TODO: change to fatherID and motherID
  ,SpouseName varchar(20) --TODO: Change to spouseID or to a relationship table to allow divorces?
);
insert OurFamily
          select 101,'John'    ,'M',null,'Mary'
union all select 102,'Fred'    ,'M', 101,'Wilma'
union all select 103,'Linda'   ,'F', 101,'Mike'
union all select 104,'Charles' ,'M', 101,'Diana'
union all select 105,'Rebecca' ,'F', 102,'Marvin'
union all select 106,'Sam'     ,'M', 102,'Tammy'
union all select 107,'Ben'     ,'M', 102,'Abigail'
union all select 108,'Jack'    ,'M', 102,'Jill'
union all select 109,'George'  ,'M', 103,'Martha'
union all select 110,'Dorothy' ,'F', 104,'Paul'
union all select 111,'Tom'     ,'M', 104,'Judy'
union all select 112,'Susan'   ,'F', 104,'Andrew'
union all select 113,'Patrick' ,'M', 105,null
union all select 114,'Sharon'  ,'F', 105,'Mark'
union all select 115,'Brian'   ,'M', 106,null
union all select 116,'Jean'    ,'F', 107,'Bob'
union all select 117,'Calvin'  ,'M', 107,'Kate'
union all select 118,'Frank'   ,'M', 109,'Jennifer'
union all select 119,'Joan'    ,'F', 109,null
union all select 120,'Eric'    ,'M', 109,'Elaine'
union all select 121,'Lisa'    ,'F', 110,null
union all select 122,'James'   ,'M', 111,'Cynthia'
union all select 123,'Isabel'  ,'F', 111,'Greg'
union all select 124,'David'   ,'M', 112,null
union all select 125,'Cindy'   ,'F', 114,'Nigel'
union all select 126,'Alvin'   ,'M', 114,'Lucy'
union all select 127,'Julie'   ,'F', 116,null
union all select 128,'Tim'     ,'M', 118,null
union all select 129,'Michelle','F', 120,'Ryan'
union all select 130,'Peter'   ,'M', 120,null
union all select 131,'Ken'     ,'M', 123,null
union all select 132,'Harry'   ,'M', 125,null
union all select 133,'Nancy'   ,'F', 129,null


create table Relations (generation int not null, Distance int not null, Masculine nvarchar(500), Feminine nvarchar(500), Neutral nvarchar(500)
);



if object_id('udf_GetRelation') is not null
drop procedure usp_GetListOfRelatives;
go

create function udf_GetRelation( @RelGender char(1), @N int, @N2 int )
 returns nvarchar(500)
 as
 /* based on the messy, long, series of case/when statements from:
 	-- http://bradsruminations.blogspot.com/2009/10/viva-la-famiglia.html

*/
 Begin
	declare @Generation int = @N2 - @N;
	declare @N3 int = @N2;
	declare @Relation nvarchar(500);

	if @Generation >= 0 
		set @N3 = @n;
	
	if @N3 > 2
		set @Relation = 'Cousin';


 end;
 go



if object_id('usp_GetListOfRelatives') is not null
drop procedure usp_GetListOfRelatives;
go 

create procedure usp_GetListOfRelatives(   @Who nvarchar(500) )
as
/*
	-- http://bradsruminations.blogspot.com/2009/10/viva-la-famiglia.html
	--TODO: Change WHO to ID or firstname and lastname

	insert OurFamily
          select 101,'John'    ,'M',null,'Mary'
union all select 102,'Fred'    ,'M', 101,'Wilma'
union all select 103,'Linda'   ,'F', 101,'Mike'
union all select 104,'Charles' ,'M', 101,'Diana'
union all select 105,'Rebecca' ,'F', 102,'Marvin'
union all select 106,'Sam'     ,'M', 102,'Tammy'
union all select 107,'Ben'     ,'M', 102,'Abigail'
union all select 108,'Jack'    ,'M', 102,'Jill'
union all select 109,'George'  ,'M', 103,'Martha'
union all select 110,'Dorothy' ,'F', 104,'Paul'
union all select 111,'Tom'     ,'M', 104,'Judy'
union all select 112,'Susan'   ,'F', 104,'Andrew'
union all select 113,'Patrick' ,'M', 105,null
union all select 114,'Sharon'  ,'F', 105,'Mark'
union all select 115,'Brian'   ,'M', 106,null
union all select 116,'Jean'    ,'F', 107,'Bob'
union all select 117,'Calvin'  ,'M', 107,'Kate'
union all select 118,'Frank'   ,'M', 109,'Jennifer'
union all select 119,'Joan'    ,'F', 109,null
union all select 120,'Eric'    ,'M', 109,'Elaine'
union all select 121,'Lisa'    ,'F', 110,null
union all select 122,'James'   ,'M', 111,'Cynthia'
union all select 123,'Isabel'  ,'F', 111,'Greg'
union all select 124,'David'   ,'M', 112,null
union all select 125,'Cindy'   ,'F', 114,'Nigel'
union all select 126,'Alvin'   ,'M', 114,'Lucy'
union all select 127,'Julie'   ,'F', 116,null
union all select 128,'Tim'     ,'M', 118,null
union all select 129,'Michelle','F', 120,'Ryan'
union all select 130,'Peter'   ,'M', 120,null
union all select 131,'Ken'     ,'M', 123,null
union all select 132,'Harry'   ,'M', 125,null
union all select 133,'Nancy'   ,'F', 129,null
;
 
John+Mary
|--Fred+Wilma
|  |--Rebecca+Marvin
|  |  |--Patrick
|  |  |--Sharon+Mark
|  |     |--Cindy+Nigel
|  |        |--Harry
|  |     |--Alvin+Lucy
|  |--Sam+Tammy
|  |  |--Brian
|  |--Ben+Abigail
|  |  |--Jean+Bob
|  |  |  |--Julie
|  |  |--Calvin+Kate
|  |--Jack+Jill
|--Linda+Mike
|  |--George+Martha
|     |--Frank+Jennifer
|     |  |--Tim
|     |--Joan
|     |--Eric+Elaine
|        |--Michelle+Ryan
|           |--Nancy
|        |--Peter
|--Charles+Diana
   |--Dorothy+Paul
   |  |--Lisa
   |--Tom+Judy
   |  |--James+Cynthia
   |  |--Isabel+Greg
   |     |--Ken
   |--Susan+Andrew
      |--David

	 (1) Build a FamTree recursive CTE to include an Ancestry path, 
	 (2) For each person in the FamTree, go through his Ancestry path, ancestor-by-ancestor (via the JOIN to a Numbers table), 
	 (3) For each of those ancestors, link them to everyone else in FamTree with common ancestors (via the JOIN again to FamTree), and 
	 (4) Calculate relative positioning values (N and N2) between each person and those relatives.

	The difference between N and N2 determines how a person is related, and corresponds to the relationship chart at the beginning of this article. 
	For example, if N-N2 is zero, where someone and a relative share a common parent or grandparent or great grandparent, etc, 
	then that has to do with the line going across the middle part of the chart (Myself, Brother/Sister, First Cousin, Second Cousin, etc). 
	Part of what makes the query lengthy is using the Gender column to determine gender-specific relations, like Mother/Father, Brother/Sister, Uncle/Aunt, Nephew/Niece, etc.

	All of this data (for the person in question) is put into the #FamilyRelations temp table.

	Finally, the second query brings spouses into the mix, which is another can of worms, with In-Laws, etc.

*/
begin
	declare @IsBloodRelative bit;
	set @IsBloodRelative = case when exists (select * from OurFamily where FirstName = @Who)
                     then 1 else 0 end;
  
	if object_id('tempdb..#FamilyRelations') is not null 
		drop table #FamilyRelations;
  
	with FamTree(ID, FirstName, Gender, SpouseName, Ancestry) as (
		select ID
			,FirstName
			,Gender
			,SpouseName
			,cast(str(ID,5) as varchar(max))
		from OurFamily
		where ParentID is null
		union all
		select t.ID
			,t.FirstName
			,t.Gender
			,t.SpouseName
			,cast(str(t.ID,5)+f.Ancestry as varchar(max))
		from FamTree f
		join OurFamily t on f.ID=t.ParentID
	) -- /famTree
	, Relationships as(
		select F1.FirstName
			,F1.Gender
			,F1.SpouseName
			,N,N2
			,RelFirstName=F2.FirstName
			,RelGender=F2.Gender
			,RelSpouseName=F2.SpouseName
		from FamTree F1
		join (select N = Number from master..spt_values where Type = 'P') Numbers on N between 1 and len(F1.Ancestry) / 5
		cross apply (select AncestryList=substring(Ancestry,N*5-4,9999)
                     ,PrevList=case when N=1   then '*' 
                               else substring(Ancestry,N*5-9,9999)
                               end) X1
			join FamTree F2 on charindex(AncestryList,F2.Ancestry)>0
                     and charindex(PrevList, F2.Ancestry ) = 0
		cross apply (select N2 = charindex(AncestryList, F2.Ancestry) / 5 + 1) X2
	) --/relationships
	select FirstName
		,Gender
		,SpouseName
		,RelFirstName
		,RelGender
		,RelSpouseName
		,FamilyRelationName=RelFirstName
		,FamilyRelation='my '+
		case when N2 - N < -3 then 
			case N2
			when 1 then replicate('Great ', N - N2 -2) + 'Grand'
                    + case when RelGender = 'M'
                     then 'father' else 'mother' end
			when 2 then replicate('Great ', N - N2 - 1)
                    + case when RelGender = 'M'
                     then 'Uncle' else 'Aunt' end
			when 3 then '1st Cousin '+ convert(varchar, N - N2)+'x Removed'
			when 4 then '2nd Cousin '+ convert(varchar, N - N2)+'x Removed'
			when 5 then '3rd Cousin '+ convert(varchar, N - N2)+'x Removed'
			else convert(varchar, N2 - 2) + 'th Cousin '
				 + convert(varchar, N - N2) + 'x Removed'
			end
		when N2 - N = -3 then 
			case N2
			when 1 then 'Great Grand'
                    + case when RelGender = 'M' 
                     then 'father' else 'mother' end
			when 2 then 'Great Great '
                    + case when RelGender = 'M' 
                     then 'Uncle' else 'Aunt' end
			when 3 then '1st Cousin 3x Removed'
			when 4 then '2nd Cousin 3x Removed'
			when 5 then '3rd Cousin 3x Removed'
			when 6 then convert(varchar, N2 - 2) + 'th Cousin 3x Removed'
			end
		when N2 - N = -2 then 
			case N2
			when 1 then 'Grand'
                    +case when RelGender = 'M' 
                     then 'father' else 'mother' end
			when 2 then 'Great '
                    +case when RelGender = 'M' 
                     then 'Uncle' else 'Aunt' end
			when 3 then '1st Cousin Twice Removed'
			when 4 then '2nd Cousin Twice Removed'
			when 5 then '3rd Cousin Twice Removed'
			when 6 then convert(varchar, N2 - 2) + 'th Cousin Twice Removed'
			end
		when N2 - N = -1 then 
			case N2
			when 1 then case when RelGender='M' 
                     then 'Father' else 'Mother' end
			when 2 then case when RelGender='M' 
                     then 'Uncle' else 'Aunt' end
			when 3 then '1st Cousin Once Removed'
			when 4 then '2nd Cousin Once Removed'
			when 5 then '3rd Cousin Once Removed'
			when 6 then convert(varchar,N2-2)+'th Cousin Once Removed'
			end
		when N2 - N = 0 then 
			case N
			when 1 then 'Myself'
			when 2 then case when RelGender = 'M' 
                     then 'Brother' else 'Sister' end
			when 3 then '1st Cousin'
			when 4 then '2nd Cousin'
			when 5 then '3rd Cousin'
			else convert(varchar, N - 2) + 'th Cousin'
			end
		when N2 - N = 1 then 
			case N
			when 1 then case when RelGender='M' 
                     then 'Son' else 'Daughter' end
			when 2 then case when RelGender='M' 
                     then 'Nephew' else 'Niece' end
			when 3 then '1st Cousin Once Removed'
			when 4 then '2nd Cousin Once Removed'
			when 5 then '3rd Cousin Once Removed'
			else convert(varchar,N-2)+'th Cousin Once Removed'
			end
		when N2 - N = 2 then 
			case N
			when 1 then 'Grand'
                    +case when RelGender='M' 
                     then 'son' else 'daughter' end
			when 2 then 'Great '
                    +case when RelGender='M' 
                     then 'Nephew' else 'Niece' end
			when 3 then '1st Cousin Twice Removed'
			when 4 then '2nd Cousin Twice Removed'
			when 5 then '3rd Cousin Twice Removed'
			else convert(varchar,N-2)+'th Cousin Twice Removed'
			end
		when N2-N=3 then 
			case N
			when 1 then 'Great Grand'
                    +case when RelGender='M' 
                     then 'son' else 'daughter' end
			when 2 then 'Great Great '
                    +case when RelGender='M' 
                     then 'Nephew' else 'Niece' end
			when 3 then '1st Cousin 3x Removed'
			when 4 then '2nd Cousin 3x Removed'
			when 5 then '3rd Cousin 3x Removed'
			else convert(varchar,N-2)+'th Cousin 3x Removed'
			end
		when N2-N>3 then 
			case N
			when 1 then replicate('Great ',N2-N-2)+'Grand'
                    +case when RelGender='M' 
                     then 'son' else 'daughter' end
			when 2 then replicate('Great ',N2-N-1)
                    +case when RelGender='M' 
                     then 'Nephew' else 'Niece' end
			when 3 then '1st Cousin '+convert(varchar,N2-N)+'x Removed'
			when 4 then '2nd Cousin '+convert(varchar,N2-N)+'x Removed'
			when 5 then '3rd Cousin '+convert(varchar,N2-N)+'x Removed'
			else convert(varchar,N-2)+'th Cousin '
				 +convert(varchar,N2-N)+'x Removed'
			end
		end
	into #FamilyRelations
	from Relationships
	where (FirstName = @Who or SpouseName = @Who) ;
  
	with SpouseRelations as(
	select
		FirstName
		,Gender
		,SpouseName
		,RelFirstName
		,RelGender
		,RelSpouseName
		,FamilyRelationName
		,FamilyRelation=
			case when FamilyRelation='my Myself'
			 then 'Myself' else FamilyRelation end
		,SpouseRelationName=RelSpouseName
		,SpouseRelation=
			case when FamilyRelation='my Myself' then 
				case when RelGender='M' then 'my Wife' 
				else 'my Husband' end
			when charindex('Grandfather', FamilyRelation) > 0 then replace(FamilyRelation,'father','mother')
			when charindex('Grandmother',FamilyRelation) > 0 then replace(FamilyRelation,'mother','father')
			when FamilyRelation = 'my Father' then 'my Mother'
			when FamilyRelation = 'my Mother' then 'my Father'
			when charindex('Uncle',FamilyRelation)>0 then replace(FamilyRelation,'Uncle','Aunt')
			when charindex('Aunt',FamilyRelation)>0 then replace(FamilyRelation,'Aunt','Uncle')
			when FamilyRelation='my Son' then 'my Daughter-In-Law, married to '+RelFirstName
			when FamilyRelation='my Daughter' then 'my Son-In-Law, married to '+RelFirstName
			else 
				case when RelGender='M'  then 'Wife' 
				else 'Husband' 
				end
				+ ' of '+FamilyRelation+', '+RelFirstName
			end
	from #FamilyRelations
	) --/spouseRelations
	, SpouseMultiple as( select Seq = 1 union all select 2 )
	,AllRelations as(
		select FirstName
			,Gender
			,SpouseName
			,RelationName = case when Seq=1 then FamilyRelationName
                           else SpouseRelationName end
			,TempRelation=case when Seq=1 then FamilyRelation
                           else SpouseRelation end
		from SpouseRelations,SpouseMultiple
		) --/allRelations
	,RelationPerspective as(
		select RelationName
		,Relation= 
		case 
		when @IsBloodRelative=1 then 
			case 
			when TempRelation like 'Husband of my Sister%'		then replace(TempRelation,'Husband of ','my Brother-In-Law, married to ')
			when TempRelation like 'Wife of my Brother%'		then replace(TempRelation,'Wife of ','my Sister-In-Law, married to ')
			when TempRelation like 'Husband of my Daughter%'	then replace(TempRelation,'Husband of ','my Son-In-Law, married to ')
			when TempRelation like 'Wife of my Son%'	        then replace(TempRelation,'Wife of ','my Daughter-In-Law, married to ')
			else TempRelation
			end
		else 
			case
			when TempRelation='Myself'							  then 'my '+SpouseType
			when TempRelation in ('my Husband','my Wife')         then 'Myself'
			when TempRelation in ('my Father','my Mother')        then TempRelation+'-In-Law'
			when TempRelation like 'my Son%' or TempRelation like 'my Daughter%'        then TempRelation
			when charindex('Grandson',TempRelation)>0         then TempRelation
			when charindex('Granddaughter',TempRelation)>0         then TempRelation
			else 
				case 
				when charindex(' of my ',TempRelation)>0 then replace(TempRelation,' of my ',' of my '+SpouseType+'''s ')
				else 'my '+SpouseType+'''s '+replace(TempRelation,'my ','')
				end
			end
		end
	from AllRelations
	cross apply (select SpouseType=case when Gender='M' then 'Husband' else 'Wife' end) X
		where RelationName is not null
	) 
	select RelationName, Relation
	from RelationPerspective
	order by RelationName;
  
	drop table #FamilyRelations;
end
go