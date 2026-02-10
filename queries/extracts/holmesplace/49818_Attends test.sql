-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
AT.Center,
AT.start_time,
TO_CHAR(AT.START_TIME, 'YYYY-MM-D HH24:MI:SS') as "DATE",
AT.person_id,
P.fullname, 
AT.state

FROM
ATTENDS AT
JOIN persons P
ON AT.person_id = P.id

WHERE
AT.CENTER IN (:Scope)
AND AT.START_TIME BETWEEN $$from_date$$ AND $$to_date$$
