-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS MATERIALIZED
    (
        SELECT
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$Start_Date$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS startDate,
            CAST((dateToLongC(TO_CHAR(CAST($$End_Date$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS endDate
        FROM
            centers c
    )
SELECT
    p.CENTER,
    p.ID,
    p.FULLNAME      AS "Member Name",
    email.TXTVALUE  AS Email,
    mobile.TXTVALUE AS Mobile,
    Home.TXTVALUE   AS "Home tel",
    c.NAME          AS Club,
    p.ZIPCODE       AS PostCode,
    p.SEX           AS Sex,
    pro.NAME        AS Subscription_Name,
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END                                                                            AS P_STATUS,
    TO_CHAR(longtodateC(je.CREATION_TIME, je.PERSON_CENTER), 'YYYY-MM-DD HH24:MI') AS "Date contact",
    je.NAME                                                                        AS "Note Subject",
    CAST(convert_from(je.big_text_encrypted, 'UTF-8') AS VARCHAR)                            AS "Note Details"
FROM
    JOURNALENTRIES je
JOIN
    PARAMS
ON
    PARAMS.id = je.PERSON_CENTER
JOIN
    PERSONS p
ON
    p.ID = je.PERSON_ID
    AND p.CENTER = je.PERSON_CENTER
JOIN
    CENTERS c
ON
    je.PERSON_CENTER = c.ID
    and c.country = 'DK'    
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = je.PERSON_CENTER
    AND email.PERSONID = je.PERSON_ID
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
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8)
LEFT JOIN
    PRODUCTS pro
ON
    pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pro.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN 
	fw.product_group prog
on
    pro.PRIMARY_PRODUCT_GROUP_ID = prog.id
WHERE
    je.CREATION_TIME BETWEEN PARAMS.startDate AND PARAMS.endDate
    AND je.PERSON_CENTER IN ($$Scope$$)
	AND je.name = 'Ordre id'
	--AND pro.PRIMARY_PRODUCT_GROUP_ID = 32801
    