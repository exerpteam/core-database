-- The extract is extracted from Exerp on 2026-02-08
-- Extract to help audit for members that have participations stuck in tentative state (not cleared after cutoff)
select Participation_LastModified_time, Personkey, count(*) from (
SELECT
   distinct Date(longtodateC(participations.last_modified,136)) AS Participation_LastModified_time,
    
   participations.participant_center || 'p' || participations.participant_id AS PersonKey
   

FROM
    lifetime.participations

WHERE
-- participations.booking_center = 136
-- AND participations.booking_id = 251917  AND
STATE = 'TENTATIVE'
-- AND participant_center = 136
-- AND participant_id = 84814
AND after_sale_process = true
group by participations.participant_center, participations.participant_id, Participation_LastModified_time


) AS my_count
Group by Participation_LastModified_time, PersonKey