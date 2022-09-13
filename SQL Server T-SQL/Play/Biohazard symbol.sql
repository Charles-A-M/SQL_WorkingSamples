--https://codegolf.stackexchange.com/questions/191294/draw-the-biohazard-symbol/191323#191323

DECLARE @z VARCHAR(MAX)=REPLACE(REPLACE(REPLACE('DECLARE @a5MULTIPOINT((0 31),(19 -2),(-19 -2))'',@b5MULTIPOINT((0 39),(26 -6),(-26 -6))'',@5POINT(0 9)'',@d5LINESTRING(0 9,0 99,90 -43,0 9,-90 -43)''SELECT @a830%b821)%86)%d81)%d84%819))).STUnion(@827%820)).STIntersection(@b819)))'
,8,'.STBuffer('),5,' GEOMETRY='''),'%',').STDifference(@')EXEC(@z)

--above expands into below via select @z
DECLARE @a GEOMETRY='MULTIPOINT((0 31),(19 -2),(-19 -2))',	--centers of 3 larger circles
	@b GEOMETRY='MULTIPOINT((0 39),(26 -6),(-26 -6))',		--centers of 3 smaller circles
	@ GEOMETRY='POINT(0 9)',								--center point
	@d GEOMETRY='LINESTRING(0 9,0 99,90 -43,0 9,-90 -43)'	--3 lines from center

SELECT @a.STBuffer(30)				-- main shape outline
	.STDifference(@b.STBuffer(21))	--remove 3 large circles
	.STDifference(@.STBuffer(6))	--remove small center circle
	.STDifference(@d.STBuffer(1))	--remove thin segments at center
	.STDifference(@d.STBuffer(4).STDifference(@.STBuffer(19)))	--remove wider segments at edge
	.STUnion(@.STBuffer(27)			--add extra ring
	.STDifference(@.STBuffer(20))	--	with middle removed
	.STIntersection(@b.STBuffer(19))) --	and gap from rest of shape