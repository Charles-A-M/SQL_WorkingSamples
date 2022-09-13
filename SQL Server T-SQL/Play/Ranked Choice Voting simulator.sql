/*
Ranked Choice Voting simulator
	https://ballotpedia.org/Ranked-choice_voting_(RCV)

	(C) Charles Moore, 2020-09-30, v1

	This creates tables, populates them with parties, candidates, and voters.
		to re-run, comment out everything down to the "begin voting" block.
	Then it casts votes in a weighted manner.
	Randomly:
		40% of voters rank DEMs higher. (random vote order for Democrat candidates, then Green party, then random order GOP/Libertarian at the bottom)
		40% rate REPs higher (Randomly select GOP order, then Libertarian, then random DEM/Green)
		10% vote Green/Dem higher (Green, then Dems, then GOP/Lib)
		10% vote Lib/GOP higher (Lib, then GOP, then Dems/Green)
	Then it tallies the votes in RCV manner:
	Go through and tally all votes. If someone has > 50%, they win and voting is done.
	Otherwise, remove the lowest scored candidate. Anyone who voted for that candidate now votes for their 2nd choice.
	Go back and tally again.
	Repeat until someone gets > 50% of the vote.

	Assumptions: 
	Everyone in the voters table actually votes.
	Everyone who votes votes for all candidates; no one submits a partial ballot.

	Weaknesses:
	No logic to handle ties in loser (ties default to random candidate)
	Should assign votes based on a cursor to get all voters, not a while loop (so the IDs don't have to be 1 to x)
	need to bump the tally field to BigInt and adjust the logic accordingly
	Probably need more name fields, etc., in the candidates table?
	The weights are too random for the voting?
	Is there a better way to dump the results than hard coding the number of passes required to get the output?


	A real-world version would need revising:
		Voters table would be Ballots table.
		Ballots would be assigned IDs in a manner that guarantees uniqueness:
			StateID int						-- foreign key to State/Territory list
			PrecinctID int					-- foreign key to list of polling sites within each statecode.
			VotingMachineID int				-- foreign key to list of voting machines / scanning machines
			BallotID uniqueidentifier		-- GUID assigned by the voting machine.
		A voting machine would print a receipt showing the votes and the 4 IDs above, 
			1 copy stored, 1 copy to voter, as an audit trail
		VoterVotes table probably would be partitioned in some way to improve parallel processing


		This produces two sets of outputs:

		text:

Tables created. Parties added. Candidates added. Begin voting.
Voting complete. Tallying results...
Eliminated D. Trump in round 1
Eliminated M. Rubio in round 2
Eliminated B. Sanders in round 3
Eliminated M. O'Malley in round 4
Eliminated T. Cruze in round 5
Eliminated H. Clinton in round 6
Eliminated J. Stein in round 7
WINNER in Round 8 is J. Biden with 54.956% of vote ( 54956 out of 100000).

		table:

candidate	isEliminated	winnerRound	Round_1	Round_2	Round_3	Round_4	Round_5	Round_6	Round_7	Round_8	Round_9	Round_10	Round_11
G. Johnson	0	0	20013	20013	20013	20013	20013	20013	20013	20013	NULL	NULL	NULL
J. Biden	0	8	8881	8881	8881	11728	17540	17540	34980	54956	NULL	NULL	NULL
M. Pence	0	0	6286	8425	12555	12555	12555	25031	25031	25031	NULL	NULL	NULL
D. Trump	1	0	6215	0	0	0	0	0	0	0	NULL	NULL	NULL
M. Rubio	2	0	6255	8261	0	0	0	0	0	0	NULL	NULL	NULL
B. Sanders	3	0	8625	8625	8625	0	0	0	0	0	NULL	NULL	NULL
M. O'Malley	4	0	8750	8750	8750	11566	0	0	0	0	NULL	NULL	NULL
T. Cruze	5	0	6275	8345	12476	12476	12476	0	0	0	NULL	NULL	NULL
H. Clinton	6	0	8724	8724	8724	11686	17440	17440	0	0	NULL	NULL	NULL
J. Stein	7	0	19976	19976	19976	19976	19976	19976	19976	0	NULL	NULL	NULL
TOTAL	10	0	100000	100000	100000	100000	100000	100000	100000	100000	0	0	NULL
*/
/*
Create schema Votes;
go
 */

 SET NOCOUNT ON; 
 --
 -- Start from zero
--

drop table Votes.electionresults;
drop table votes.voters;
drop table votes.votervotes;
drop table votes.Candidates;
drop table votes.PoliticalParty;

declare @i int = 0;
declare @x int = 0;
declare @HowManyVoters int = 100000;		-- how many voters in this simulation?
--
-- make some tables!
--
create table votes.PoliticalParty (
	ID int identity primary key,
	PartyName nvarchar(100)
	);

Create table votes.Candidates (
	ID int identity primary key,
	Candidate nvarchar(100) not null,
	PartyID int references votes.PoliticalParty(id) not null,
	isEliminated int not null default 0,
	WinnerRound int not null default 0
	);
	
create table votes.Voters (
	ID int identity primary key not null,
	VoterName nvarchar(100)
	);

create table votes.VoterVotes (
	ID int identity primary key,
	VoterID int references votes.voters(id) not null,
	CandidateID int references votes.candidates(id) not null,
	voteRank tinyint not null
	)
-- can't vote for same guy twice
create unique index uix_VoterVotesCandidate on votes.votervotes (voterID, candidateID);
--can't have the same rank twice per voter
create unique index uix_VoterVotesRank on votes.votervotes (voterID,  voteRank);

create table votes.electionResults(
	ID int identity primary key not null,
	CandidateID int not null references votes.candidates(id),
	PassNum int not null,  
	VoteTally int not null default 0 
	);
create unique index uix_eResultsCandidatePass on votes.electionResults (CandidateID,  PassNum);


insert into votes.PoliticalParty (PartyName) values ('Democratic');
insert into votes.PoliticalParty (PartyName) values ('Republican');
insert into votes.PoliticalParty (PartyName) values ('Green');
insert into votes.PoliticalParty (PartyName) values ('Libertarian');

insert into votes.Candidates (PartyID, Candidate) values (1, 'H. Clinton');
insert into votes.Candidates (PartyID, Candidate) values (1, 'B. Sanders');
insert into votes.Candidates (PartyID, Candidate) values (1, 'M. O''Malley');
insert into votes.Candidates (PartyID, Candidate) values (2, 'D. Trump');
insert into votes.Candidates (PartyID, Candidate) values (2, 'T. Cruze');
insert into votes.Candidates (PartyID, Candidate) values (2, 'M. Rubio');
insert into votes.Candidates (PartyID, Candidate) values (3, 'J. Stein');
insert into votes.Candidates (PartyID, Candidate) values (4, 'G. Johnson');
insert into votes.Candidates (PartyID, Candidate) values (1, 'J. Biden');
insert into votes.Candidates (PartyID, Candidate) values (2, 'M. Pence');
--
print 'Tables created. Parties added. Candidates added. Adding voters...';
--
--Setup for election:
--
while @i < @HowManyVoters
begin
	set @i = @i + 1;
	insert into Votes.Voters (voterName) values ( 'Voter-' + format(@i, '000,000,000'));
end;
--
print 'Voters added. Begin voting...';
--
set @i = 0;
declare @party int;
while @i < @HowManyVoters
begin
	set @i = @i + 1; 
	set @party = ceiling( rand() * 100 );
	if @party < 36			-- democrat
		begin
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) as RowNum from Votes.Candidates where id in (select id from votes.Candidates where PartyID = 1 ) ;
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank) values (@i, 7, 5);
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 5 as RowNum from Votes.Candidates where id in  (select id from votes.Candidates where PartyID in(2, 4)) ;
		end
	else if @party < 61		-- republican
		begin
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) as RowNum from Votes.Candidates where id in  (select id from votes.Candidates where PartyID = 2 ) ;
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank) values (@i, 8, 5);
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 5 as RowNum from Votes.Candidates where id in (select id from votes.Candidates where PartyID in(1, 3)) ;
		end
	else if  @party < 81	-- green
		begin
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank) values (@i, 7, 1);
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 1 as RowNum from Votes.Candidates where id in  (select id from votes.Candidates where PartyID = 1)  ;
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 5 as RowNum from Votes.Candidates where id in  (select id from votes.Candidates where PartyID in(2, 4))  ;
		end
	else				-- libertarian
		begin
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank) values (@i, 8, 1);
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 1 as RowNum from Votes.Candidates where id in  (select id from votes.Candidates where PartyID = 2)  ;		
			insert into Votes.VoterVotes (VoterID, CandidateID, voteRank)
				select @i, ID, row_number() over(order by newid() asc) + 5 as RowNum from Votes.Candidates where id in (select id from votes.Candidates where PartyID in(1, 3))  ;
		end;
end;
--
print 'Voting complete. Tallying results...';

   --     */
--
--	Cout the votes
--
delete from Votes.electionResults;
update votes.Candidates set isEliminated = 0;
declare @candCount int;
select @candCount = count(*) from votes.Candidates;

set @i = 0;
while @i < @candCount
begin	
	set @i = @i + 1;
	set @x = 0;
	while @x < @candCount
	begin
		set @x = @x + 1;
		insert into Votes.electionResults (CandidateID, PassNum, VoteTally) values (@x, @i, 0);
	end
end;

set @i = 0;
declare @voterID int;
declare @thisCand int;
declare @thisPct float;
declare @vTally int;
declare @ttlVotes int;
declare @winner varchar(1000);
while @i < @candCount
begin
	set @i = @i + 1;
	declare c1 cursor for 	
	select v.ID, 
	isnull(vv1.CandidateID, isnull(vv2.CandidateID, isnull(vv3.CandidateID, 
			ISNULL(vv4.CandidateID, isnull(vv5.CandidateID, isnull(vv6.CandidateID, 
			ISNULL(vv7.CandidateID, ISNULL(vv8.CandidateID, isnull(vv9.candidateID, 
			isnull(vv0.candidateID, 0))))))))))    MyCandidate
	from Votes.Voters v
	left join votes.VoterVotes vv1 on vv1.voterid = v.id and vv1.voteRank = 1 and vv1.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv2 on vv2.voterid = v.id and vv2.voteRank = 2 and vv2.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv3 on vv3.voterid = v.id and vv3.voteRank = 3 and vv3.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv4 on vv4.voterid = v.id and vv4.voteRank = 4 and vv4.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv5 on vv5.voterid = v.id and vv5.voteRank = 5 and vv5.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv6 on vv6.voterid = v.id and vv6.voteRank = 6 and vv6.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv7 on vv7.voterid = v.id and vv7.voteRank = 7 and vv7.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv8 on vv8.voterid = v.id and vv8.voteRank = 8 and vv8.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv9 on vv9.voterid = v.id and vv9.voteRank = 9 and vv9.CandidateID not in (select id from votes.Candidates where isEliminated > 0)
	left join votes.VoterVotes vv0 on vv0.voterid = v.id and vv0.voteRank = 10 and vv0.CandidateID not in (select id from votes.Candidates where isEliminated > 0);

	open c1;
	fetch next from c1 into @voterID, @ThisCand
	while @@FETCH_STATUS = 0
	begin	
		if @thisCand > 0
			update Votes.electionResults set VoteTally = VoteTally + 1 where CandidateID = @thisCand and PassNum = @i;

		fetch next from c1 into @voterID, @ThisCand
	end
	close c1;
	deallocate c1;
	set @thisCand = null;

	--have we found a winner yet?
	;with ttl as (
	select candidateID,   VoteTally, 
		  (select sum(VoteTally) from votes.electionResults where PassNum = 1) TotalVotes,
		  cast(VoteTally as float) / (select sum(VoteTally) from votes.electionResults where PassNum = @i ) * 100.0 VotePct
	from votes.electionResults
	where PassNum = @i
	) select top 1 @thisCand = CandidateID, @thisPct = votePct, @vTally = VoteTally, @ttlVotes = TotalVotes
	from ttl 
	order by votePct desc, newid();

	if @vTally > (@ttlVotes / 2.0)  --must be more than 50% to win.
	begin
		select @winner = 'WINNER in Round ' + cast(@i as varchar) + ' is ' + Candidate + ' with ' + cast(@thisPct as varchar) + '% of vote ( ' +
			cast(@vTally as varchar) + ' out of ' + cast(@ttlVotes as varchar) + ').'
		from votes.candidates where id = @thisCand

		print  @winner;
		update Votes.Candidates set WinnerRound = @i where id = @thisCand;
		break;
	end

	-- no winner found. Let's eliminate someone and try again
	select top 1 @thisCand = candidateID, @vTally = VoteTally
	from votes.electionResults
	where PassNum = @i 
	 and CandidateID not in (select id from Votes.Candidates where isEliminated > 0)
	order by VoteTally asc, newid();

	update votes.Candidates set isEliminated = @i where id = @thisCand;
	Select @winner = 'Eliminated ' + Candidate + ' in round ' + cast(@i as varchar)
	from votes.Candidates where id =  @thisCand ;
	--report the outcome of this round:
	print @winner;
end;


--provide the final results as a table. 
-- This show un-eliminated candidates first by name, then eliminated candidates by order of elimination.
select Candidate, c.isEliminated, c.winnerRound, 
	  er1.VoteTally Round_1, er2.VoteTally Round_2, er3.VoteTally Round_3, er4.VoteTally Round_4
	, er5.VoteTally Round_5, er6.VoteTally Round_6, er7.VoteTally Round_7, er8.VoteTally Round_8
	, er9.VoteTally Round_9, er0.VoteTally Round_10, era.VoteTally Round_11 
from Votes.Candidates c
left join Votes.electionResults er1 on er1.CandidateID = c.ID and er1.PassNum = 1
left join Votes.electionResults er2 on er2.CandidateID = c.ID and er2.PassNum = 2
left join Votes.electionResults er3 on er3.CandidateID = c.ID and er3.PassNum = 3
left join Votes.electionResults er4 on er4.CandidateID = c.ID and er4.PassNum = 4
left join Votes.electionResults er5 on er5.CandidateID = c.ID and er5.PassNum = 5
left join Votes.electionResults er6 on er6.CandidateID = c.ID and er6.PassNum = 6
left join Votes.electionResults er7 on er7.CandidateID = c.ID and er7.PassNum = 7
left join Votes.electionResults er8 on er8.CandidateID = c.ID and er8.PassNum = 8
left join Votes.electionResults er9 on er8.CandidateID = c.ID and er8.PassNum = 9
left join Votes.electionResults er0 on er8.CandidateID = c.ID and er8.PassNum = 10
left join Votes.electionResults era on er8.CandidateID = c.ID and er8.PassNum = 11
union 
select 'TOTAL', 
	999, 999,
	(select sum(voteTally) from Votes.electionResults where passnum = 1),
	(select sum(voteTally) from Votes.electionResults where passnum = 2),
	(select sum(voteTally) from Votes.electionResults where passnum = 3),
	(select sum(voteTally) from Votes.electionResults where passnum = 4),
	(select sum(voteTally) from Votes.electionResults where passnum = 5),
	(select sum(voteTally) from Votes.electionResults where passnum = 6),
	(select sum(voteTally) from Votes.electionResults where passnum = 7),
	(select sum(voteTally) from Votes.electionResults where passnum = 8),
	(select sum(voteTally) from Votes.electionResults where passnum = 9),
	(select sum(voteTally) from Votes.electionResults where passnum = 10),
	(select sum(voteTally) from Votes.electionResults where passnum = 11)
order by 2, 1;


-- Done!