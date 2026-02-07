-- This is the version from 2026-02-05
--  
Select
 p.center ||'p'|| p.id                                   AS MemberID,
            p.firstname || ' ' || p.middlename || ' ' || p.lastname AS CustomerName ,
           s.START_DATE                                            AS "Start date of subscription",
          to_char(longtodate(s.creation_time),'YYYY-MM-DD hh24:mi:ss') as creationdate
FROM
    Subscriptions s
JOIN
    persons p
    ON
    s.owner_center = p.center
AND s.owner_id = p.id

where
s.creation_time between :fromdate and :todate
and
p.center in (:scope)