-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4510
SELECT
    s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
    p.fullname,
    s.CENTER || 'ss' || s.ID sid ,
    s.BINDING_PRICE,
    s.SUBSCRIPTION_PRICE,
    prod.NAME,
    DECODE(comp.TXTVALUE,'H','HR','M','Marketing','P', 'Partner',comp.TXTVALUE)  "Complimentary Reason",
    prod.GLOBALID,
    s.end_date,
    TO_CHAR(longtodateC(last_visit.lasttime, p.center),'dd.mm.yyyy') "Last Visit",
    last_3_months.visitcount "Visits in Last 3 Months"
FROM
    SUBSCRIPTIONS s
JOIN
    persons p
ON
    p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PERSON_EXT_ATTRS comp
ON
    comp.NAME = 'CompReason'
    AND comp.PERSONCENTER = p.CENTER
    AND comp.PERSONID = p.ID
LEFT JOIN
    (
    SELECT max(ch.CHECKIN_TIME) lasttime, ch.PERSON_CENTER, ch.PERSON_ID
    FROM CHECKINS ch
    GROUP BY ch.PERSON_CENTER,  ch.PERSON_ID
    )
    last_visit
ON
    last_visit.PERSON_CENTER = p.CENTER
    AND last_visit.PERSON_ID = p.ID
LEFT JOIN
    (
    SELECT count(*) visitcount, c2.PERSON_CENTER, c2.PERSON_ID
    FROM CHECKINS c2
    WHERE c2.CHECKIN_TIME >= datetolongC(TO_CHAR(add_months(last_day(trunc(sysdate))+1,-4),'YYYY-MM-DD HH24:MI'),c2.CHECKIN_CENTER)
    AND  c2.CHECKIN_TIME < datetolongC(TO_CHAR(add_months(last_day(trunc(sysdate)),-1),'YYYY-MM-DD HH24:MI'),c2.CHECKIN_CENTER)+86400*1000
    GROUP BY c2.PERSON_CENTER,  c2.PERSON_ID
    )
    last_3_months
ON
    last_3_months.PERSON_CENTER = p.CENTER
    AND last_3_months.PERSON_ID = p.ID

WHERE
    s.STATE IN (2,4,8)
    AND s.OWNER_CENTER IN (:Scope)
    AND (comp.TXTVALUE in (:Complimentary_Values)  OR 'ALL' in :Complimentary_Values)
    /* No scheduled price change > zero in the future*/
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SUBSCRIPTION_PRICE sp
        WHERE
            sp.SUBSCRIPTION_CENTER = s.CENTER
        AND sp.SUBSCRIPTION_ID = s.ID
        AND (
                sp.TO_DATE > SYSDATE
            OR  sp.TO_DATE IS NULL )
        AND sp.PRICE > 0
        AND sp.CANCELLED = 0 )
AND 
    prod.NAME NOT LIKE '%Gymflex%'