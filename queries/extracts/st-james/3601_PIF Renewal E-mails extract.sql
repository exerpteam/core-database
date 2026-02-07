SELECT
        t1.center,
        t1.id,
        t1.personId AS "PERSONKEY",
        TO_CHAR(t1.expiredate,'MM/DD/YYYY') AS EXPIREDATE
FROM
(
WITH 
    params AS MATERIALIZED
    (   SELECT
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + INTERVAL '5 day'  AS fiveDays,
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + INTERVAL '15 day' AS fifteenDays,
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + INTERVAL '30 day' AS thirtyDays,
            extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')))  AS executionDate,
            c.ID                                                           AS CenterID
        FROM
            CENTERS c
        WHERE
            id in (:center)    
    )
SELECT DISTINCT
    s.owner_center||'p'||s.owner_id as personid,
    s.owner_center as center,
    s.owner_id as id,
    s.end_date as expiredate
FROM
    params
JOIN    
    subscriptions s
ON
    params.centerid = s.center
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND st.st_type = 0 -- PIF
WHERE 
   s.state IN (2,4,8)
  AND s.end_date in (params.fiveDays, params.fifteenDays, params.thirtyDays)
) t1   
