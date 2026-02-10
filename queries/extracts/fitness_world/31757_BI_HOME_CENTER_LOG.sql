-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cp.external_id AS                                                   "PERSON_ID",
    pcl.person_center                                                   "HOME_CENTER_ID",
    TO_CHAR(longtodateC(entry_time, pcl.person_center),'yyyy-MM-dd') AS "FROM_DATE",
    pcl.person_center                                                AS "CENTER_ID",
    REPLACE(TO_CHAR(entry_time,'FM999G999G999G999G999'),',','.')     AS "ETS"   
FROM
    person_change_logs pcl
JOIN
    PERSONS p
ON
    p.center = pcl.person_center
AND p.id = pcl.person_id
JOIN
    PERSONS cp
ON
    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    pcl.PREVIOUS_ENTRY_ID IS NULL
AND pcl.change_attribute = 'CREATION_DATE'
AND cp.SEX <> 'C'
AND entry_time BETWEEN 
CAST(datetolong(TO_CHAR(CURRENT_DATE - $$offset$$ * interval '1 day', 'yyyy-MM-dd HH24:MI')) AS BIGINT) 
AND 
CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day','yyyy-MM-dd HH24:MI')) AS BIGINT)