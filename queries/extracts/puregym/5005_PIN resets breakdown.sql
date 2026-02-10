-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.NAME                                   AS CenterName,
    bl.PERSON_CENTER||'p'||                       bl.PERSON_ID,
    e.IDENTITY                                 AS PIN,
    prod.NAME                                  AS Subscription,
    DECODE (subtyp.ST_TYPE, 0,'CASH', 1,'EFT') AS SubscriptionType,
    CASE
        WHEN (
                SELECT
                    1
                FROM
                    PUREGYM.SUBSCRIPTIONS s
                WHERE
                    s.STATE =3
                    AND s.OWNER_CENTER = bl.PERSON_CENTER
                    AND s.OWNER_ID = bl.PERSON_ID
                    AND s.SUB_STATE IN (3,4)
                    AND rownum = 1
                    AND s.END_DATE BETWEEN longtodate(bl.CREATION_TIME)-14 AND longtodate(bl.CREATION_TIME)) IS NOT NULL
        THEN 1
        ELSE 0
    END                                                                  AS Changed,
    TO_CHAR( longtodatetz(att.fa,'Europe/London'),'yyyy-MM-dd')          AS FirstAttend,
    TO_CHAR(longtodatetz(att.la,'Europe/London') ,'yyyy-MM-dd')          AS LastAttend,
    TO_CHAR(longtodatetz(BL.CREATION_TIME,'Europe/London'),'yyyy-MM-dd') AS ResetDate,
    TO_CHAR(longtodatetz(BL.CREATION_TIME,'Europe/London'),'HH24:MI')    AS ResetTime,
    TO_CHAR(sub.START_DATE,'yyyy-MM-dd')                                 AS START_DATE,
    bl.NAME,
    UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(bl.BIG_TEXT, 4000,1), 'UTF8')AS Notes,
    empp.FULLNAME                             AS "Staff"
FROM
    PUREGYM.JOURNALENTRIES BL
JOIN
    PUREGYM.JOURNALENTRIES UBL
ON
    UBL.PERSON_CENTER = bl.PERSON_CENTER
    AND ubl.PERSON_ID = BL.PERSON_ID
    AND ubl.CREATION_TIME - bl.CREATION_TIME BETWEEN 0 AND 1000*60*5
    AND ubl.name = 'Blacklist cancelled'
JOIN
    PUREGYM.CENTERS cen
ON
    bl.PERSON_CENTER = cen.ID
    -- PIN
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=bl.PERSON_CENTER
    AND e.REF_ID = bl.PERSON_ID
    AND e.REF_TYPE = 1
LEFT JOIN
    (
        SELECT
            MIN (a.START_TIME) fa,
            MAX(a.START_TIME)  la,
            a.person_center,
            a.person_id
        FROM
            PUREGYM.ATTENDS a
        GROUP BY
            a.person_center,
            a.person_id) att
ON
    att.person_center = bl.PERSON_CENTER
    AND att.person_id=bl.PERSON_ID
JOIN
    PUREGYM.SUBSCRIPTIONS sub
ON
    sub.OWNER_CENTER = bl.PERSON_CENTER
    AND sub.OWNER_ID = bl.PERSON_ID
    AND sub.STATE = 2
JOIN
    PUREGYM.SUBSCRIPTIONTYPES subtyp
ON
    subtyp.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subtyp.ID = sub.SUBSCRIPTIONTYPE_ID
JOIN
    PUREGYM.PRODUCTS prod
ON
    prod.CENTER = subtyp.CENTER
    AND prod.ID = subtyp.ID
LEFT JOIN
    PUREGYM.EMPLOYEES emp
ON
    emp.center = bl.CREATORCENTER
    AND emp.id = bl.CREATORID
LEFT JOIN
    PUREGYM.PERSONS empp
ON
    empp.center = emp.PERSONCENTER
    AND empp.id = emp.PERSONID
WHERE
    BL.name='Blacklisted'
    AND BL.CREATION_TIME BETWEEN :start_date AND :end_date