Execute spCreateEssay 'Red Face Software Ltd'
 --      There is a strong body of opinion that affirms that a unfocussed documenting is undoubtadly due to the informality of all system management processes.     
 --		We must conclude that, finally, one of the inherent reasons of the avoidance of inappropriate skills cannot be attributed to the lack of resources.
 --		A ameliorating consequence of over-marketing of product features by software vendors is either disconnect among the staff due to sudden introduction of change to their environment resulting in apathy and/or confusion or an inability to meet service level agreements. 
 --		The hostility of the dynamic equivalent mobility, or even the analogous auxiliary constraints, will have profound effects.      
 --		If any organization such as Red Face Software Ltd incompetently implements a new tool for sales without considering the underlying business processes or the organizational structure required to operate and support the technology, then failures can and and more than likely will occur. </p><p>        
 --		With the risk of the inefficient appropriate documenting in a project such as The Business Re-engineering project, the legitimate effective proposal will suffer, despite the focused Change Control systems of Phil Factor's Database Department.      Business environments these days are characterized by lack of beneficial change control systems, and acceleration of everything from hostility to complexity. IT has been one of the major drivers of this.      An analogy of the link between planning organization and contingency planning is the project management constraint triad --scope schedule and targets . A change to any one of these constraints affect the others, despite the best efforts of Phil Factor's Database Department .      It is common knowledge that we can define the main issues as commitment, the overall project control and miscalculating the work to personnel ratio., but the insufficient inductive methodology in a project such as The Business Re-engineering project, the explicit cardinal support will be eclipsed.      In the The Business Re-engineering project, Despite the unfocussed determinant dichotomy, and the unfocussed discordant concept, As with many projects, the Database Department worked flawlessly under Phil Factor's supervision, achieving both the beneficial strategic goals and focused purchaser - provider partnership     Despite scope-creep, objectives changing during the project, well-defined architectures and project slip, the Phil Factor and the Database Department worked eagerly with a resulting n-tier bottom line and inductive core business     Without adequate requirements for technology, a project such as The Business Re-engineering project will not meet targets! One of the reasons why IT projects suffer from this to a greater degree than other industry projects lie in lack of support from senior management.      We must take on board that fact that a inefficient documenting rests with the informality of all system management processes. 

Select dbo.ufsWaffle('%N %K %A %R %S')
--It has hitherto been accepted that inappropriate design is because of the lack of fully interactive technical management oversight and control


CREATE VIEW vRandomNumber 
AS 
	/*
	 https://www.red-gate.com/simple-talk/sql/sql-tools/the-ultimate-excuse-database/

Even now, I can think of no rational explanation for writing this
Sodoku puzzle generator other than a bout of insomnia whilst
programming too hard on a difficult website. Basically, it just 
popped out.

Sodoku is a poular number puzzle. The aim of the puzzle is to
place numbers from 1 through 9 in each cell of a 9×9 grid made
up of 3×3  "regions".

When the puzzle is presented, some of the numbers are shown and
others aren''t. The shown ones are the "givens"); 

The person doing the puzzle has to fill in the blanks. Computers
are much better at doing this sort of laborious work.

Each row, column, and region must contain only one instance of
each number from 1 to 9. 

The puzzle was first published in a U.S. puzzle magazine in 1979.
The name Sodoku is a trademark in Japan

This stored procedure makes repeated attempts at a solution. It
generally finds a solution 50% of the time, but keeps at it until
it finds one. Each one is, hopefully, different.

I get no pleasure from solving Sodoku puzzles but if you do, 
you can modify the source to blank out some of the numbers once
a solution has been reached.

You will notice that you can turn it into a very good Sodoku solving
system just my modding the program with the ''Givens'' for the puzzle
instead of allowing the program to choose them all.

The stored procedure uses a function that produces a random number.
This is not allowed, but I do it to makes sure a random number is
different in each row of the result.


this is a little view that sneaks a random number generator past
the SQL Server parser
*/
	SELECT RAND() AS RandomNumber 
GO
 

CREATE FUNCTION ufsOneOf( @String VARCHAR(8000) )  --input string of a list of alternatives 
RETURNS VARCHAR(8000)--the list item selected 
AS
	/* 
	-- https://www.red-gate.com/simple-talk/sql/sql-tools/the-ultimate-excuse-database/

	requires RandomNumber view to supply RAND() values.

		Description: 
		Picks one of a delimited list. Here we have a version which has '|'
			hard-wired as the list delimiter.
		test: 
			select dbo.ufsOneOf('') 
			select dbo.ufsOneOf('|||') 
			select dbo.ufsOneOf(null) 
			select dbo.ufsOneOf('one|two|three') 

		example for delivering a random weather forecast:
		Select dbo.ufsOneOf('Rain|Mist over the hills, Clearing later|
Dry in the east, Rain spreading from the west
later|Rain heavy at times, becoming clearer
later|Generally dry|Showers, more organized
rain spreading from the west|Scattered showers|
Rain spreading from the east|Dry interludes|
Becoming overcast later')

	*/ 
    BEGIN  
        DECLARE @ii INT; 
        DECLARE @Substring VARCHAR(255); 
        DECLARE @which INT; 
        DECLARE @Delimiter CHAR(1); 
 
        SELECT  @Delimiter = '|'; 
 		--select a random integer between 1 and the number of list items 
        SELECT  @which = ( 
			SELECT RandomNumber
              FROM vRandomNumber
            ) * 
			( LEN(@String) - 
				LEN(REPLACE(@String, @Delimiter, '')) + 1 
			) + 1; 
 
        SELECT  @ii = 1 , @Substring = ''; 
		--And go to the item you want by iteration.
		--This will please the procedural boys 
        WHILE @ii <= @which
            BEGIN
			--if the impossible has happened or he has passed a null string
                IF ( @String IS NULL  OR @Delimiter IS NULL )
                    BEGIN 
                        SELECT  @Substring = ''; 
                        BREAK;  
                    END; 
                IF CHARINDEX(@Delimiter, @String) = 0
                    BEGIN  
                        SELECT  @Substring = @String; 
                        SELECT  @String = ''; 
                    END;  
                ELSE
                    BEGIN 
                        SELECT  @Substring = SUBSTRING(@String, 1,
                                                       CHARINDEX(@Delimiter,
                                                              @String) - 1); 
                        SELECT  @String = SUBSTRING(@String,
                                                    CHARINDEX(@Delimiter,
                                                              @String) + 1,
                                                    LEN(@String)); 
                    END; 
                SELECT  @ii = @ii + 1; 
            END;  
 
        RETURN (@Substring);  
    END;  
GO  



create function [dbo].[ufsSelectRandomPhrase]( 	@type char(1) 	) 
	RETURNS varchar(8000) 
AS 
BEGIN 
/*
	https://www.red-gate.com/simple-talk/sql/sql-tools/the-ultimate-excuse-database/

	now we build this function into a collection of word-banks and phrase-banks which we can then use to provide the
	basis of an IT strategy document. In this case plausible reasons for the failure of a project

	Description
	So here we have a function that returns, at random, one of a series of words, or phrases. Currently these are set to

	A--conceptual processes--
	B--excuses--
	C--inputs-- 
	D--constraints--
	E--types of projects--
	F--pergorative words
	G--things that must be good
	H--misconceptions--
	I--unpleasant results
	J--unpleasant things
	K--negatives
	L--neutral modifiers
	M--positive modifier
	N - S --the six main parts of a sentence
	T-- process
	U--Systems adjectives-- process
	V--More Systems adjectives-- process
	W-- process
	Note that the function can pass back a string containing a placeholder of the format %x where x is one of the characters
	A-T

	Test
		Select dbo.ufsSelectRandomPhrase(''A'')
		Select dbo.ufsSelectRandomPhrase(''I'')

	*/	
	return(
	  replace(
		case @type	--processes--
		when 'A' then 
			dbo.ufsOneOf('process|organization|technology|planning|methodology|documenting|design|' +
				'implemention|contingency planning|Change Control systems')
		--excuses--
		when 'B' then 
			dbo.ufsOneOf('unclear objectives|changing objectives|insufficient resources|impossible schedules|' +
				'unrealistic expectations|unclear roles and responsibilities|corporate politics|poor communication|personnel turnover|' +
				'changing technology|constraining rules and regulations|lack of %C|poor %C|unclear goals and objectives|lack of attention to %A|' +
				'objectives changing during the project|unrealistic time or resource estimates|lack of %C and %C|' +
				'failure to communicate and act as a team|inappropriate skills|scope creep|feature creep|' +
				'lack of %M change control systems|well-defined architectures|resistance to change %K definition of the requirements which could not be tested|' +
				'overrun of initial cost estimations|%K resolve to follow the plans|inadequate planning|project slip|budget overrun|' +
				'%K productivity|scope-creep|overall failure of the project to meet its targets|lack of support from senior management')
		--inputs-- 
		when 'C' then
			dbo.ufsOneOf('management support|Systems Architecture|project assumptions|senior-management buy-in|resource allocation|' +
				'project control|pre-planning|sponsorship|resource estimates|executive support|user involvement|prior expectations')
		--constraints--
		when 'D' then
			dbo.ufsOneOf('scope|resources|schedule|targets|requirements')
		--types of projects--
		when 'E' then
			dbo.ufsOneOf('software packaging and distribution|CMS|accounting|managing workflow')
		--pergorative words
		when 'F' then
			dbo.ufsOneOf('blindly|foolishly|shortsightedly|unthinkingly|incompetently')
		--things that must be good
		when 'G' then
			dbo.ufsOneOf('core services|comprensive solutions|industry best-practice|strategic goals|gap analysis|' +
				'purchaser - provider partnership|skill set|strategic plan|bottom line|positive mindset|benchmark|core business|big picture|knowledge base|core drivers')
		--misconceptions--
		when 'H' then
		dbo.ufsOneOf('over-marketing of product features by software vendors|belief that a particular technology is a silver bullet|' +
			'reluctance to invest heavily in an area that is a cost center|overambitious goals|Lack of understanding of IT processes|' +
			'belief that distributed computing is technology, not process driven|belief that technological change can be rapidly absorbed by an organization')
		--unpleasant results
		when 'I' then
			dbo.ufsOneOf('an inability to properly support or manage the technology resulting in increasing costs|' +
				'inefficiencies in the service provided to customers|an inability to meet service level agreements|' +
				'disconnect among the staff due to sudden introduction of change to their environment resulting in %J and/or %j') 
		--unpleasant things
		when 'J' then
			dbo.ufsOneOf('complexity|resistance|attrition|confusion|apathy|anxiety|inertia|low morale|clinical stress|hostility|impatience|passivity|aquiescence|intolerance')
		--negatives
		when 'K' then
			dbo.ufsOneOf('lack of|superfluous|inappropriate|flawed|unrealistic|insufficient|harmful|vague|unhelpful|inefficient|poor|inadequate|' +
				'unfocussed|under-resourced|poorly-supervised|inadequate|poorly motivated|under-developed')
		--neutral modifiers
		when 'L' then
			dbo.ufsOneOf('main|major|subtle|key|contributing|influential|high level|ameliorating|inherent')
		--positive modifier
		when 'M' then
			dbo.ufsOneOf('sufficient|adequate|focused|beneficial|client focussed|value-added|quality-driven|meaningful|homogenous|n-tier|inductive|fully integrated|fully interactive|' +
				'resilient|legitimate|appropriate')
		--sentence components
		when 'N' then 
			dbo.ufsOneOf('As with many projects,|Typically of projects of this scale,|We are now realising that|It could be true that|' +
				'Surely,|To be frank,|To be absolutely frank,|Preliminary examinations reveal that|An in-depth analysis suggests that|I think it is fair to say that|' +
				'It is generally thought that|Essentially,|We must conclude that, finally,|It probably goes without saying that|Undoubtedly,|' +
				'It is probably fair to say that|Within the project life-cycle|Within the constraints of the terms of the project|' +
				'Note that|Essentially,|To make the main points more explicit, it is fair to say that|We have heard it said, tongue-in-cheek, that|To be quite frank,|' +
				'Focussing on the agreed facts, we can say that|To be perfectly truthful,|In broad terms,|To be perfectly honest,|We must take on board that fact that|' +
				'It has hitherto been accepted that|At the end of the day,|Firming up the gaps, one can say that|To be precise,|To reiterate,|To recapitulate,|Strictly speaking,|' +
				'In a very real sense,|In any event,|In particular,|On the other hand,|It is recognized that|Taking everything into consideration,|As in so many cases, we can state that|' +
				'An initial appraisal makes it evident that|An investigation of the various factors suggests that|It is common knowledge that|The less obviously co-existential factors imply that|' +
				'To coin a phrase,|One might venture to suggest that|In all foreseeable circumstances,|However,|Similarly,|There is a strong body of opinion that affirms that|' +
				'Up to a point,|Quite frankly,|In this regard,|Based on integral subsystems,|For example,|Therefore,|Up to a certain point,It might seem reasonable to think that')

		when 'O' then 
			dbo.ufsOneOf('one of the %L causes|a %L factor which was responsible|the blame|one of the %L reasons|a %L factor|' +
				'it may not be the case that|it may be disengenuous to suggest that a factor|the %L difficulties|the constraints|the responsibility')
	
		when 'P' then 
			dbo.ufsOneOf('for the|for any of the|for all the issues around the|for what is usually termed the|for what seems to be|' +
				'for what is probably the|of the avoidance of')
		--present tense verb phrase
		when 'R' then 
			dbo.ufsOneOf('is because of|is due to|rests with|cannot be attributed to|may be linked with|is undoubtadly due to|' +
				'should be seen in the context of')
		--reasons
		when 'S' then 
			dbo.ufsOneOf('changing requirements|structural erosion|personality conflicts|%K upper management|Restricted budget|' +
				'restricted time|power struggles|%K elicitation and validation of requirements|commitment|overambitious goals|incompetent staff|' +
				'a culture dependent on maintaining the status quo|a %K transition strategy|starting from %K baseline requirements|' +
				'miscalculating the work to personnel ratio.|Inadequately trained users who did not understand the purpose of testing|' +
				'%K, %K, and generally %K requirements|the informality of all system management processes|lack of User Involvement|long or %K Time Scales|' +
				'a flawed environment integration strategy|the database|signs of poor communication|the lack of %M technical management oversight and control|' +
				'internal politics|late project deliverables|overrun cost estimations|the lack of resources|the programming environment|' +
				'a flawed strategic process|the overall project control|setting an overly ambitious project scope|the lack of project methodology|' +
				'poor user input and requirements gathering|the %K support from senior management|%K interpersonal skills')
		--processes
		when 'T' then
			dbo.ufsOneOf('business|payroll|accounting|group|management|sales|marketing')		
		/* these are the first word of a three-word buzzword. They are adjectives
		and can be used to salt nouns to make them sound more important */
		when 'U' then
			dbo.ufsOneOf('comprehensive|targeted|realigned|basic|principal|central|essential|primary|indicative|continuous|' +
				'critical|prevalent|preeminent|unequivocal|sanctioned|logical|reproducible|methodological|relative|integrated|fundamental|' +
				'cohesive|interactive|comprehensive|critical|potential|vibrant|total|additional|secondary|primary|heuristic|complex|pivotal|' +
				'quasi-effectual|dominant|characteristic|ideal|doctrine of the|key|independent|deterministic|assumptions about the|heuristic|crucial|' +
				'meaningful|implicit|analogous|explicit|integrational|non-viable|directive|consultative|collaborative|delegative|tentative|' +
				'privileged|common|hypothetical|metathetical|marginalised|systematised|evolutional|parallel|functional|responsive|optical|inductive|' +
				'objective|synchronised|compatible|prominent|three-phase|two-phase|balanced|legitimate|subordinated|complementary|proactive|' +
				'truly global|interdisciplinary|homogeneous|hierarchical|technical|alternative|strategic|environmental|closely monitored|' +
				'ad-hoc|ongoing|proactive|dynamic|flexible|verifiable|falsifiable|transitional|' +
				'mechanism-independent|synergistic|high-level')
	
		/* another nice bank of adjectives. We keep them separate from the preceding
		so that we do not accidentally choose the same adjective in a two-adjective
		buzzword */
		when 'V' then
			dbo.ufsOneOf('fast-track|transparent|results-driven|subsystem|test|configuration|mission|functional|referential|' +
				'numinous|paralyptic|radical|paratheoretical|consistent|macro|interpersonal|auxiliary|empirical|theoretical|corroborated|' +
				'management|organizational|monitored|consensus|reciprocal|unprejudiced|digital|logic|transitional|incremental|equivalent|universal|' +
				'sub-logical|hypothetical|conjectural|conceptual|empirical|spatio-temporal|third-generation|epistemological|diffusible|specific|' +
				'non-referent|overriding|politico-strategical|economico-social|on-going|extrinsic|intrinsic|multi-media|integrated|effective|overall|' +
				'principal|prime|major|empirical|definitive|explicit|determinant|precise|cardinal|' +
				'principal|affirming|harmonizing|central|essential|primary|indicative|mechanistic|continuous|critical|prevalent|preeminent|unequivocal|sanctioned|' +
				'logical |reproducible|methodological|relative|integrated|fundamental|cohesive|interactive|comprehensive|critical|potential|total|additional|secondary|' +
				'primary|heuristic|complex|pivotal|quasi-effectual|dominant|characteristic|ideal|independent|deterministic|heuristic|crucial|meaningful|implicit|' +
				'analogous|explicit|integrational|directive|collaborative|entative|privileged|common|hypothetical|metathetical|marginalised|systematised|evolutional|' +
				'parallel|functional|responsive|optical|inductive|objective|synchronised|compatible|prominent|legitimate|subordinated |complementary|homogeneous|' +
				'hierarchical|alternative|environmental|inductive|transitional|Philosophical|latent|conscious|practical|temperamental|impersonal|personal|subjective|' +
				'objective|dynamic|inclusive|paradoxical|pure|central|psychic|associative|intuitive|free-floating|empirical|superficial|predominant|actual|mutual|' +
				'arbitrary|inevitable|immediate|affirming|functional|referential|numinous|paralyptic|radical|paratheoretical|consistent|interpersonal|' +
				'auxiliary|empirical|theoretical|reciprocal|unprejudiced|transitional|incremental|equivalent|universal|sub-logical|hypothetical|conjectural|' +
				'conceptual |empirical|spatio-temporal|epistemological|diffusible|specific|non-referent|overriding|politico-strategical|economico-social|on-going|' +
				'extrinsic|intrinsic|effective|principal|prime|major|empirical|definitive|explicit|determinant|precise|cardinal|geometric|naturalistic|linear|' +
				'distinctive|phylogenetic|ethical|theoretical|economic|aesthetic|personal|social|discordant|political|religious|artificial|collective|' +
				'permanent|metaphysical|organic|mensurable|expressive|governing|subjective|empathic|imaginative|ethical|expressionistic|resonant|vibrant')
		/* some juicy nouns that make what you say sound more profound */
		when 'W' then
			dbo.ufsOneOf('development|program|baseline|reconstruction|discordance|monologism|substructure|legitimisation|principle|constraints|' +
				'management option|strategy|transposition|auto-interruption|derivation|option|flexibility|proposal|formulation|item|issue|' +
				'capability|mobility|programming|concept|time-phase|dimension|faculty|capacity|proficiency|reciprocity|fragmentation|consolidation|' +
				'projection|interface|hardware|contingency|dialog|dichotomy|concept|parameter|algorithm|milieu|terms of reference|item|vibrancy|' +
				'reaction|casuistry|theme|teleology|symbolism|resource allocation|certification project|functionality|specification|matrix|rationalization|' +
				'consolidation|remediation|facilitation|simulation|evaluation|competence|familiarisation|transformation|apriorism|conventionalism|verification|' +
				'functionality|component|factor|antitheseis|desiderata|metaphor|metalanguage|globalisation|initiative|projection|partnership|priority|' +
				'service|support|best-practice|change|delivery|funding|resources|')
		--done well
		when 'X' then
			dbo.ufsOneOf('flawlessly|beneficially|robustly|consciensiously|effectively|manifestly|eagerly')
		--bad end
		when 'Z' then
			dbo.ufsOneOf('undoubtedly fail|suffer|not meet targets|fail to match requirements|be eclipsed')
		else
			'error -bad placeholder'
		end
	  , '', '')  --end replace
	) -- end return
END 
go



CREATE  function [dbo].[ufsWaffle]( @formatString varchar(8000)  ) 
	RETURNS varchar(8000) AS 
BEGIN 
/*

	 https://www.red-gate.com/simple-talk/sql/sql-tools/the-ultimate-excuse-database/

	Now all we need to do is to have a function that substitutes phrases in the right place. Normally,
	this would have a mundane use coming up with plausible customer addresses for dummy data, but here
	we give it something more dignified.

	Description
	 searches for the next placeholder repeatedly in a string, and get it substituted by a random
	 phrase until there are no more.

	Requires
	dbo.ufsSelectRandomPhrase

	Example
		SELECT dbo.ufsWaffle('%N %O %P %Q %R %S') 
	So invoking this repeatedly will supply as many plausible reasons as you wish.
*/
	Declare @Where int
	WHILE 1 = 1 
	BEGIN 
		select @where=CHARINDEX( '%', ISNULL(@formatString,'') )
		--If we are out of % placeholders return the @formatString 
		IF @where = 0 BREAK 
			-- If the delimiter is not in the Args list then do one last replacement 
		SELECT @formatString = 
			STUFF( @formatString, @where, 2, dbo.ufsSelectRandomPhrase(substring(@formatString, @where + 1, 1)))
	END 
	RETURN (@formatString) 
END 
go




create   Procedure [dbo].[spCreateEssay]
	@Organisation varchar(50)='The Kamikaze Laxative Company',
	@ProjectName varchar(50)='The Business Re-engineering project',
	@myTeam varchar(50)='Database Department',
	@MyName varchar(50)='Phil Factor'
as
begin
/*
	 https://www.red-gate.com/simple-talk/sql/sql-tools/the-ultimate-excuse-database/

However, you will notice a certain repetitive sameness about this. A more subtle approach is to randomise
the sentence structure.

	Description
This will produce an advertising feature based on picking the built-in phrases at random and stringing them together.
Then the place-holders are substituted
	
	Example
	Execute spCreateEssay ''Red Face Software Ltd''
	example output
Select dbo.ufsWaffle(''%N %K %A %R %S'')
*/

--drop table #sentences
	Set nocount on
	create table #sentences (sentence varchar(500), theorder numeric(10,9))
	insert into #Sentences (sentence, theOrder) select 'In the <3>, Despite the %K %V %W, and the %K %V %W, %N the <1> worked %X under <2>''s supervision, achieving both the %M %G and %M %G',rand()
	insert into #Sentences (sentence, theOrder) select 'With the risk of the %K %M %A in a project such as <3>, the %U %V %W will %Z, despite the %M %A of <2>''s <1>. ',rand()
	insert into #Sentences (sentence, theOrder) select 'Despite %B, %B, %B and %B, the <2> and the <1> worked %X with a resulting %M %G and %M %G',rand()
	insert into #Sentences (sentence, theOrder) select 'Without %M %D for %A, a project such as <3> will %Z! One of the reasons why IT projects suffer from this to a greater degree than other industry projects lie in %B. ',rand()
	insert into #Sentences (sentence, theOrder) select 'A %L consequence of %H is either %I or %I. The %J of the %U %V %W, or even the %U %V %W, will have profound effects. ',rand()
	insert into #Sentences (sentence, theOrder) select 'An analogy of the link between %A %A and %A is the project management constraint triad --%D %D and %D . A change to any one of these constraints affect the others, despite the best efforts of <2>''s <1> . ',rand() 
	insert into #Sentences (sentence, theOrder) select 'If any organization such as <4> %F implements a new tool for %T without considering the underlying %T processes or the organizational structure required to operate and support the technology, then failures can and and more than likely will occur. ',rand()
	insert into #Sentences (sentence, theOrder) select 'Business environments these days are characterized by %B, and acceleration of everything from %J to %J. IT has been one of the major drivers of this. ',rand()
	insert into #Sentences (sentence, theOrder) select '%N %O %P %B %R %S. ',rand()
	insert into #Sentences (sentence, theOrder) select '%N a %K %A %R %S. ',rand()
	insert into #Sentences (sentence, theOrder) select '%N a %K %A %R %S. ',rand()
	insert into #Sentences (sentence, theOrder) select '%N we can define the main issues as %s, %s and %s, but the %K %M %A in a project such as <3>, the %U %V %W will %Z. ',rand()
	
	Declare @outputString varchar(8000)

	select @OutputString = coalesce(@OutPutString,'')+dbo.ufsOneOf(' | | |</p><p>
		') + '
		' +  dbo.ufsWaffle(sentence) --   +''<i>(''+sentence+'')</i>'' --just for debugging
	from #sentences order by theorder
	Select [theText] = replace(replace(replace(replace(@OutputString,'<1>',@MyTeam),'<2>',@MyName),'<3>',@projectName),'<4>',@Organisation)
end
go



