-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT --count(distinct p.CENTER || 'p' || p.ID)
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id MemberID,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY                                                         AS PIN,
    email.TXTVALUE                                                     AS Email,
    home.TXTVALUE                                                      AS PHONEHOME,
    mobile.TXTVALUE                                                    AS MOBILE,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue) AS MemberSinceDate,
    sub.END_DATE                                                       AS Sub_End_Date,
    sub.SUBSCRIPTION_PRICE,
    pr.NAME as Sub_Name
FROM
    PUREGYM.SUBSCRIPTIONS sub
CROSS JOIN
    (
        SELECT
            $$scope$$                                                                                 AS Center,
            datetolongTZ(TO_CHAR(TRUNC(sysdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS DATETIME
        FROM
            dual) params
JOIN
    STATE_CHANGE_LOG SCL1
ON
    (
        SCL1.CENTER = SUB.CENTER
        AND SCL1.ID = SUB.ID
        AND SCL1.ENTRY_TYPE = 2 )
INNER JOIN
    SUBSCRIPTIONTYPES ST
ON
    (
        SUB.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SUB.SUBSCRIPTIONTYPE_ID = ST.ID)
JOIN
    PUREGYM.PERSONS p
ON
    p.center = sub.OWNER_CENTER
    AND p.id = sub.owner_id
JOIN
    PUREGYM.SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = sub.center
    AND sc.OLD_SUBSCRIPTION_ID = sub.id
    AND sc.TYPE = 'END_DATE'
    AND sc.CHANGE_TIME <= params.DATETIME
LEFT JOIN
    PUREGYM.SUBSCRIPTION_CHANGE sc2
ON
    sc2.OLD_SUBSCRIPTION_CENTER = sub.center
    AND sc2.OLD_SUBSCRIPTION_ID = sub.id
    AND sc2.TYPE = 'END_DATE'
    AND sc2.CHANGE_TIME <= params.DATETIME
    AND sc2.id > sc.id
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    p.center=pea.PERSONCENTER
    AND p.id=pea.PERSONID
    AND pea.name='CREATION_DATE'
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = sub.SUBSCRIPTIONTYPE_ID
WHERE
    sc.EFFECT_DATE >= longtodateTZ(params.datetime, 'Europe/London')
    AND sc.EFFECT_DATE < (LAST_DAY(longtodateTZ(params.datetime, 'Europe/London')) + 1)
    AND SCL1.STATEID IN (2,4,8)
    AND SCL1.BOOK_START_TIME < params.DATETIME
    AND (
        SCL1.BOOK_END_TIME IS NULL
        OR SCL1.BOOK_END_TIME >= params.DATETIME)
    AND SCL1.ENTRY_START_TIME < params.DATETIME
    AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
    AND sc2.id IS NULL
    AND sub.center IN ($$scope$$)
    AND (
        sc.CANCEL_TIME IS NULL
        OR sc.CANCEL_TIME > params.DATETIME)
    -- exclude if the member has another DD subscription with an end date that is later or null,
    -- taking into account transfers
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.SUBSCRIPTIONS SU2
        JOIN
            persons p2
        ON
            p2.center = su2.OWNER_CENTER
            AND p2.id = su2.OWNER_ID
        JOIN
            STATE_CHANGE_LOG SCL2
        ON
            (
                SCL2.CENTER = SU2.CENTER
                AND SCL2.ID = SU2.ID
                AND SCL2.ENTRY_TYPE = 2 )
        INNER JOIN
            SUBSCRIPTIONTYPES ST2
        ON
            (
                SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID)
        WHERE
            SCL2.STATEID IN (2,4,8)
            AND SCL2.BOOK_START_TIME < params.DATETIME
            AND (
                SCL2.BOOK_END_TIME IS NULL
                OR SCL2.BOOK_END_TIME >= params.DATETIME)
            AND SCL2.ENTRY_START_TIME < params.DATETIME
    		AND (ST2.CENTER, ST2.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
            --            AND SU2.owner_center = SUB.owner_center and  SU2.owner_id = SUB.owner_id
            AND p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
            AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
            AND (
                SU2.id != SUB.id
                OR su2.center != sub.center)
            AND (
                SU2.END_DATE IS NULL
                OR su2.END_DATE > sub.END_DATE) )