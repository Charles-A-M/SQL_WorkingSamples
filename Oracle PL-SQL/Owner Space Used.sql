select 
  Owner,
  --segment_type, 
  Round((sum(bytes)/2014), 4) SpaceUsed
 --distinct    owner 
from 
   dba_segments
where 
   owner in 
   (select username 
    from dba_users
    where default_tablespace not in ('SYSTEM','SYSAUX')
   )
group by Owner --, Segment_Type
order by Owner --, Segment_Type
;

