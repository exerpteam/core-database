-- The extract is extracted from Exerp on 2026-02-08
--  
select pCenter, C, count (C) as Members_participating_C_times
from
(select
participations.PARTICIPANT_CENTER as pCenter, participations.PARTICIPANT_ID as
pId , count(*) as C
 from 
eclub2.participations
where
PARTICIPANT_CENTER between 
(:center_fra ) and
(:center_til )
and (TO_DATE('1970-01-01','yyyy-mm-dd') + start_time/(24*3600*1000) + 1/24)
between 
:fra AND
:til
group by 
PARTICIPANT_CENTER, PARTICIPANT_ID
)
group by pCenter, C
order by C
