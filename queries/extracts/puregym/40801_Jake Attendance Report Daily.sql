-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CURRENT_PERSON_CENTER                                                      AS remote_site_id ,
    p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID                          AS remote_user_id ,
    TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'),'YYYY-MM-dd HH24:MI') AS in_timestamp ,
    ci.CHECKIN_CENTER                                                            AS location_site_id ,
    TRUNC(months_between(SYSDATE,p.BIRTHDATE) / 12)                                 AGE ,
    pc.sex ,
    DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS Person_Type ,
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
    ci.CHECKIN_TIME >= (TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000
    AND ci.CHECKIN_TIME < (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000
    AND ci.PERSON_CENTER IN ($$scope$$)