SELECT
    cen.NAME as MainGym,
    p.center || 'p' || p.id AS personid,
    p.FULLNAME,
    e.IDENTITY as PIN,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    email.TXTVALUE as email,
    phone.TXTVALUE as phone,
    mobile.TXTVALUE as mobile,    
    FrzPerMem.LatestFreeze as LastFrozenDay,
    cen1.NAME as lastGymVisit,
    EXERP_CI.MaxExerp as LatestCheckin,
    --to_date(SYSDATE,'DD-MM-YYYY'),
    to_date(SYSDATE) - FrzPerMem.LatestFreeze                                                                                                                          AS "Days since last freeze",
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS
FROM
    PUREGYM.PERSONS p
JOIN
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            MAX(frz.Lastfreeze) AS LatestFreeze
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            (
                SELECT
                    sfp.SUBSCRIPTION_ID,
                    sfp.SUBSCRIPTION_CENTER,
                    MAX ( sfp.END_DATE) AS Lastfreeze
                FROM
                    PUREGYM.SUBSCRIPTION_FREEZE_PERIOD sfp
                WHERE
                    sfp.STATE = 'ACTIVE'
                GROUP BY
                    sfp.SUBSCRIPTION_ID,
                    sfp.SUBSCRIPTION_CENTER ) frz
        ON
            frz.SUBSCRIPTION_CENTER = s.CENTER
            AND frz.SUBSCRIPTION_ID = s.ID
        GROUP BY
            s.OWNER_CENTER,
            s.OWNER_ID ) FrzPerMem
ON
    p.ID = FrzPerMem.OWNER_ID
    AND p.CENTER = FrzPerMem.OWNER_CENTER
    
LEFT JOIN
        PUREGYM.PERSON_EXT_ATTRS email
        on email.PERSONCENTER = p.CENTER and email.PERSONID = p.ID and email.NAME = '_eClub_Email'
LEFT JOIN
        PUREGYM.PERSON_EXT_ATTRS mobile
        on mobile.PERSONCENTER = p.CENTER and mobile.PERSONID = p.ID and mobile.NAME = '_eClub_PhoneSMS'        

LEFT JOIN
        PUREGYM.PERSON_EXT_ATTRS phone
        on phone.PERSONCENTER = p.CENTER and phone.PERSONID = p.ID and phone.NAME = '_eClub_PhoneHome'
        
JOIN PUREGYM.CENTERS cen
        on cen.ID = p.CENTER
        

LEFT JOIN
            PUREGYM.ENTITYIDENTIFIERS e
        ON
            e.IDMETHOD = 5
            AND e.ENTITYSTATUS = 1
            AND e.REF_CENTER = p.CENTER
            AND e.REF_ID = p.ID
            AND e.REF_TYPE = 1       

LEFT JOIN
            (
                SELECT
                    p.center,
                    p.id,
                    ci.CHECKIN_CENTER,
                    TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'),
                    'YYYY-MM-DD HH24:MI') AS MaxExerp
                FROM
                    PUREGYM.PERSONS p
                LEFT JOIN
                    PUREGYM.CHECKINS ci
                ON
                    ci.PERSON_CENTER = p.center
                    AND ci.PERSON_ID = p.id
                GROUP BY
                    p.center,
                    p.id, ci.CHECKIN_CENTER ) EXERP_CI
        ON
            EXERP_CI.center = p.center
            AND EXERP_CI.id = p.id
            
Left join PUREGYM.CENTERS cen1
on cen1.ID = EXERP_CI.CHECKIN_CENTER
    
WHERE
    p.STATUS IN (:status)
    AND p.CENTER IN(:scope)