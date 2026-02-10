-- The extract is extracted from Exerp on 2026-02-08
--  
Select
ext.TXTVALUE as companyname,
p.center ||'p'|| p.id as memberID,
p.fullname as fullname,
pr.name as subscription,
s.END_DATE as enddate,
to_char(longtodatec(maxcheckin.lastcheckin, maxcheckin.person_center), 'dd-MM-YYYY HH24:MI')  as last_checkin_time
from
persons p

join
PERSON_EXT_ATTRS ext
ON
            ext.PERSONCENTER = p.CENTER
            AND ext.PERSONID = p.ID
            AND ext.NAME = 'COMPANYNAME'
left JOIN
    (
        SELECT
            ch.PERSON_CENTER,
            ch.PERSON_ID,
            MAX(ch.CHECKIN_TIME) AS lastcheckin
        FROM
            checkins ch
        GROUP BY
            ch.PERSON_CENTER,
            ch.PERSON_ID) maxcheckin
ON
    p.center = maxcheckin.PERSON_CENTER
AND p.id = maxcheckin.PERSON_ID
       
LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4)
        JOIN
            products pr
        ON
            s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
            AND s.SUBSCRIPTIONTYPE_ID = pr.ID
            
where
ext.TXTVALUE is not null
