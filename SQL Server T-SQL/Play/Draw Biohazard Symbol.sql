DECLARE @ VARCHAR(MAX)=REPLACE(REPLACE(REPLACE('DECLARE @a5MULTIPOINT((0 31),(19 -2),(-19 -2))'',@b5MULTIPOINT((0 39),(26 -6),(-26 -6))'',@5POINT(0 9)'',@d5LINESTRING(0 9,0 99,90 -43,0 9,-90 -43)''SELECT @a830%b821)%86)%d81)%d84%819))).STUnion(@827%820)).STIntersection(@b819)))'
,8,'.STBuffer('),5,' GEOMETRY='''),'%',').STDifference(@')EXEC(@)

--https://codegolf.stackexchange.com/questions/191294/draw-the-biohazard-symbol


--geo-spatial features / geometry functions.
-- Annotated code:

Declare @a GEOMETRY='MULTIPOINT((0 31),(19 -2),(-19 -2))'  		-- centers of 3 larger circles
      , @b GEOMETRY='MULTIPOINT((0 39),(26 -6),(-26 -6))'  		-- centers of 3 smaller circles
	  , @  GEOMETRY='POINT(0 9)'						   		-- center point
	  , @d GEOMETRY='LINESTRING(0 9,0 99,90 -43,0 9,-90 -43)'	-- 3 lines from center 
	  
Select @a.STBuffer(30)											-- main shape outline
	.STDifference(@b.STBuffer(21))								-- Remove 3 large circles
	.STDifference(@.STBuffer(6))								-- remove small center circles
	.STDifference(@d.STBuffer(1))								-- remove thin segments at center
	.STDifference(@d.STBuffer(4).STDifference(@.STBuffer(10))))	-- remove wider segments at edge
	.STUnion(@.STBuffer(27)										-- add extra ring
		.STDifference(@.STBuffer(20))								-- with middle ring removed
		.STIntersection(@b.STBuffer(19)))								-- and a gap from rest of shape