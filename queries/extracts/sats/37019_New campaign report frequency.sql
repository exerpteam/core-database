SELECT distinct
    cp.CENTER||'p'||cp.id memberid,
    cp.FULLNAME,
    c.SHORTNAME         center,
    pea_email.TXTVALUE  AS email,
    pea_mobile.TXTVALUE AS Mobile,
    pr.NAME             AS "Subscription Name",
    s.START_DATE,
    s.END_DATE,
    SUM(
        CASE
            WHEN exerpro.longtodate(att.START_TIME) BETWEEN s.START_DATE AND s.START_DATE +14
            THEN 1
            ELSE 0
        END) AS "training frequency 2 weeks",
    COUNT(*) AS "training frequency 4 weeks"
FROM
    SATS.PERSONS cp
JOIN
    SATS.PERSONS p
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.id
JOIN
    SATS.SUBSCRIPTIONS s
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN
    SATS.ATTENDS att
ON
    att.PERSON_CENTER = s.OWNER_CENTER
    AND att.PERSON_ID = s.OWNER_ID
    AND exerpro.longtodate(att.START_TIME) BETWEEN s.START_DATE AND s.START_DATE +28
JOIN
    SATS.CENTERS c
ON
    c.id = cp.CENTER
JOIN
    SATS.PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    SATS.PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = cp.center
    AND pea_email.PERSONID = cp.id
    AND pea_email.NAME = '_eClub_Email'
LEFT JOIN
    SATS.PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = cp.center
    AND pea_mobile.PERSONID = cp.id
    AND pea_mobile.NAME = '_eClub_PhoneSMS'
WHERE
s.SUB_STATE not in (8) and 
    NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.ATTENDS att2
        WHERE
            att2.PERSON_CENTER = p.center
            AND att2.PERSON_ID = p.id
            AND att2.START_TIME BETWEEN att.START_TIME - 1000*60*60*4 AND att.START_TIME -1)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.PERSONS p2
        JOIN
            SATS.SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = p2.center
            AND s2.OWNER_ID = p2.id
            AND s2.SUB_STATE not in (8)
                
        WHERE
            p2.CURRENT_PERSON_CENTER = cp.CENTER
            AND p2.CURRENT_PERSON_ID = cp.id
            AND s2.END_DATE between add_months(s.START_DATE,-1) and s.START_DATE)
    AND s.START_DATE BETWEEN $$from_date$$ AND $$to_date$$
    AND p.CURRENT_PERSON_CENTER IN ($$scope$$)
    AND ((
            p.CURRENT_PERSON_CENTER NOT IN ($$centers_list$$) and $$action$$='Exclude')
            OR (
                p.CURRENT_PERSON_CENTER IN ($$centers_list$$) and $$action$$='Include_only')
                OR (
                    $$action$$='Include_all'))
GROUP BY
    cp.CENTER||'p'||cp.id,
    cp.FULLNAME,
    c.SHORTNAME,
    pea_email.TXTVALUE ,
    pea_mobile.TXTVALUE,
    pr.NAME ,
    s.START_DATE,
    s.END_DATE