SELECT
    p.CURRENT_PERSON_CENTER                                                                                                                           AS remote_site_id ,
    p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                                                                                               AS remote_user_id ,
    TO_CHAR(longtodateC(ci.CHECKIN_TIME, ci.PERSON_CENTER),'YYYY/MM/dd HH24:MI:SS')                                                                   AS in_timestamp ,
    ci.CHECKIN_CENTER                                                                                                                                 AS location_site_id ,
    CAST (EXTRACT(YEAR FROM AGE(now(), CAST(p.birthdate AS TIMESTAMP))) * 12 + EXTRACT(MONTH FROM AGE(now(), CAST(p.birthdate AS TIMESTAMP))) AS INT) AS Age,
    pc.sex ,
    CASE p.persontype
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS Person_Type,
    pc.external_id ,
    first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) subscription_name
FROM
    CHECKINS ci
JOIN
    PERSONS p
ON
    p.CENTER = ci.PERSON_CENTER
    AND p.id = ci.PERSON_ID
JOIN
    PERSONS pc
ON
    pc.CENTER = p.CURRENT_PERSON_CENTER
    AND pc.id = p.CURRENT_PERSON_ID
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = pc.CENTER
    AND s.OWNER_ID = pc.ID
    AND s.STATE IN (2,4,8)
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
WHERE
    ci.PERSON_CENTER IN ($$Scope$$)
    AND ci.CHECKIN_TIME >= dateToLongC(TO_CHAR(CAST(now() AS DATE)-$$offset$$,'YYYY-MM-dd HH24:MI'), p.CENTER)
    AND ci.CHECKIN_TIME < dateToLongC(TO_CHAR(CAST(now() AS DATE)+1,'YYYY-MM-dd HH24:MI'), p.CENTER)
UNION ALL
SELECT
    p.CURRENT_PERSON_CENTER                                                                                                                           AS remote_site_id ,
    p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                                                                                               AS remote_user_id ,
    TO_CHAR(longtodateC(ou.TIMESTAMP, ou.PERSON_CENTER),'YYYY/MM/dd HH24:MI:SS')                                                                      AS in_timestamp ,
    ou.CENTER                                                                                                                                         AS location_site_id,
    CAST (EXTRACT(YEAR FROM AGE(now(), CAST(p.birthdate AS TIMESTAMP))) * 12 + EXTRACT(MONTH FROM AGE(now(), CAST(p.birthdate AS TIMESTAMP))) AS INT) AS Age,
    pc.sex,
    CASE p.persontype
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS Person_Type,
    pc.external_id ,
    first_value(prod.NAME) over (partition BY pc.CENTER,pc.ID ORDER BY s.CREATION_TIME DESC) subscription_name
FROM
    OFFLINE_USAGES ou
JOIN
    PERSONS p
ON
    p.CENTER = ou.PERSON_CENTER
    AND p.id = ou.PERSON_ID
JOIN
    PERSONS pc
ON
    pc.CENTER = p.CURRENT_PERSON_CENTER
    AND pc.id = p.CURRENT_PERSON_ID
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = pc.CENTER
    AND s.OWNER_ID = pc.ID
    AND s.STATE IN (2,4,8)
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
WHERE
    ou.PERSON_CENTER IN ($$Scope$$)
    AND ou.TIMESTAMP >= dateToLongC(TO_CHAR(CAST(now() AS DATE)-$$offset$$,'YYYY-MM-dd HH24:MI'), p.CENTER)
    AND ou.TIMESTAMP < dateToLongC(TO_CHAR(CAST(now() AS DATE)+1,'YYYY-MM-dd HH24:MI'), p.CENTER)
    AND ou.DEVICE_PART = 0
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            CHECKINS c
        WHERE
            c.PERSON_CENTER = ou.PERSON_CENTER
            AND c.PERSON_ID = ou.PERSON_ID
            AND c.CHECKIN_TIME >= dateToLongC(TO_CHAR(CAST(now() AS DATE)-$$offset$$,'YYYY-MM-dd HH24:MI'), p.CENTER)
            AND c.CHECKIN_TIME < dateToLongC(TO_CHAR(CAST(now() AS DATE)+1,'YYYY-MM-dd HH24:MI'), p.CENTER)
            --NOTE: if there is upto 1 minute difference between offline usage and checkin then don't count it
            AND ABS(c.CHECKIN_TIME - ou.timestamp) <= 60000 )