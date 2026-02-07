-- This is the version from 2026-02-05
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS
            bigint) AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS bigint
            )+(1000*60*60*24)-1 AS toDate,
            c.id              AS centerID,
            c.name            AS Centername
        FROM
            centers c
          where
             c.country = 'DK' and (c.id in (:MEMBER_HOME_CLUB)) 
    )
select
t1."CENTER_ID",
t1.name,
t1."CHECK_IN_DATE",    
count(t1."PERSON_ID") as "antal (staff included)",
count(t1.staff) as "staff visit"



from    
(    
SELECT distinct
    c.CHECKIN_CENTER AS "CENTER_ID",
    ce.name,
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER), 'yyyy-MM-dd') AS "CHECK_IN_DATE",
       CASE
        WHEN c.CHECKIN_CENTER <> p.CENTER THEN 'TRUE'
        ELSE 'FALSE'
    END AS "non-local visit", -- New column indicating if the visit is non-local,
/*    case when c.checkin_result in (1,2)
      then '1'
      end as antal,*/
    c.checkin_result,
       cp.center ||'p'|| cp.id AS "PERSON_ID",
       case when cp.persontype = 2
       then 'staff' end as staff  
    
FROM checkins c

join params
on params.centerid = c.CHECKIN_CENTER 
and c.CHECKIN_TIME BETWEEN params.FROMDATE AND params.TODATE

join centers ce
on
ce.id = c.CHECKIN_CENTER

JOIN
    persons p ON p.CENTER = c.PERSON_CENTER AND p.id = c.PERSON_ID
    
JOIN
    PERSONS cp ON cp.CENTER = p.CURRENT_PERSON_CENTER AND cp.id = p.CURRENT_PERSON_ID
  
    
WHERE
    c.CHECKIN_TIME BETWEEN params.FROMDATE AND params.TODATE
   AND c.CHECKIN_CENTER IN (:MEMBER_HOME_CLUB) 
  --  and p.status in  (1,3)
    and c.checkin_result in (1,2)


   
)t1    

group by
t1."CENTER_ID",
t1."CHECK_IN_DATE",    
t1.name