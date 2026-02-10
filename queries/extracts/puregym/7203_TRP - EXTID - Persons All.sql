-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    NULL                AS remote_chain_id,
    P.CENTER            AS remote_site_id,
    p.EXTERNAL_ID       AS remote_user_id,
    1                   AS membership_type,
    --DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'
    -- ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') as membership_type,
    P.LASTNAME                                                                  AS sname,
    P.FIRSTNAME                                                                 AS fname,
    P.SEX                                                                       AS gender,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), CREATIONDATE.txtvalue)      AS joined,
    CREATIONDATE.TXTVALUE                                                            AS created,
    TO_CHAR(P.BIRTHDATE, 'YYYY-MM-DD')                                               AS dob,
    Z.ZIPCODE                                                                        AS postcode,
    HOMEPHONE.TXTVALUE                                                               AS telno,
    MOBILEPHONE.TXTVALUE                                                             AS mobno,
    EMAIL.TXTVALUE                                                                   AS email,
    NULL                                                                             AS updated,
    DECODE (P.STATUS, 0,'INACTIVE', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE') AS valid,
    NULL                                                                             AS remote_barcode,
    CASE
        WHEN active_subs.MaxEndDate IS NOT NULL
            AND active_subs.MaxEndDate < to_date('2100-01-01', 'YYYY-MM-DD')
        THEN active_subs.MaxEndDate
        ELSE NULL
    END AS expires,
    CASE
        WHEN p.status NOT IN (1,3)
        THEN P.LAST_ACTIVE_END_DATE
        ELSE NULL
    END  AS cancelled, --CHECK
    NULL AS member_category,
    CASE
        WHEN ALLOWLETTER.TXTVALUE = 'true'
            AND ALLOWNEWSLETTER.TXTVALUE = 'true'
        THEN 0
        ELSE 1
    END AS letter_opt,
    CASE
        WHEN ALLOWEMAIL.TXTVALUE = 'true'
            AND ALLOWNEWSLETTER.TXTVALUE = 'true'
        THEN 0
        ELSE 1
    END AS email_opt,
    CASE
        WHEN ALLOWSMS.TXTVALUE = 'true'
            AND ALLOWNEWSLETTER.TXTVALUE = 'true'
        THEN 0
        ELSE 1
    END AS sms_opt,
    CASE
        WHEN ALLOWPHONE.TXTVALUE = 'true'
            AND ALLOWNEWSLETTER.TXTVALUE = 'true'
        THEN 0
        ELSE 1
    END AS phone_opt,
    CASE
        WHEN SMSMARKETING.TXTVALUE = 'true'
            AND ALLOWNEWSLETTER.TXTVALUE = 'true'
        THEN 0
        ELSE 1
    END AS SMSMARKETING
FROM
    PERSONS P
JOIN
    ZIPCODES Z
ON
    (
        P.COUNTRY = Z.COUNTRY
        AND P.ZIPCODE = Z.ZIPCODE
        AND P.CITY = Z.CITY)
LEFT JOIN
    PERSON_EXT_ATTRS HOMEPHONE
ON
    (
        P.CENTER = HOMEPHONE.PERSONCENTER
        AND P.ID = HOMEPHONE.PERSONID
        AND HOMEPHONE.NAME = '_eClub_PhoneHome')
LEFT JOIN
    PERSON_EXT_ATTRS MOBILEPHONE
ON
    (
        P.CENTER = MOBILEPHONE.PERSONCENTER
        AND P.ID = MOBILEPHONE.PERSONID
        AND MOBILEPHONE.NAME = '_eClub_PhoneSMS')
LEFT JOIN
    PERSON_EXT_ATTRS EMAIL
ON
    (
        P.CENTER = EMAIL.PERSONCENTER
        AND P.ID = EMAIL.PERSONID
        AND EMAIL.NAME = '_eClub_Email')
LEFT JOIN
    PERSON_EXT_ATTRS CREATIONDATE
ON
    (
        P.CENTER = CREATIONDATE.PERSONCENTER
        AND P.ID = CREATIONDATE.PERSONID
        AND CREATIONDATE.NAME = 'CREATION_DATE')
LEFT JOIN
    PERSON_EXT_ATTRS ALLOWLETTER
ON
    (
        P.CENTER = ALLOWLETTER.PERSONCENTER
        AND P.ID = ALLOWLETTER.PERSONID
        AND ALLOWLETTER.NAME = '_eClub_AllowedChannelLetter')
LEFT JOIN
    PERSON_EXT_ATTRS ALLOWEMAIL
ON
    (
        P.CENTER = ALLOWEMAIL.PERSONCENTER
        AND P.ID = ALLOWEMAIL.PERSONID
        AND ALLOWEMAIL.NAME = '_eClub_AllowedChannelEmail')
LEFT JOIN
    PERSON_EXT_ATTRS ALLOWSMS
ON
    (
        P.CENTER = ALLOWSMS.PERSONCENTER
        AND P.ID = ALLOWSMS.PERSONID
        AND ALLOWSMS.NAME = '_eClub_AllowedChannelSMS')
LEFT JOIN
    PERSON_EXT_ATTRS ALLOWPHONE
ON
    (
        P.CENTER = ALLOWPHONE.PERSONCENTER
        AND P.ID = ALLOWPHONE.PERSONID
        AND ALLOWPHONE.NAME = '_eClub_AllowedChannelPhone')
LEFT JOIN
    PERSON_EXT_ATTRS ALLOWNEWSLETTER
ON
    (
        P.CENTER = ALLOWNEWSLETTER.PERSONCENTER
        AND P.ID = ALLOWNEWSLETTER.PERSONID
        AND ALLOWNEWSLETTER.NAME = 'eClubIsAcceptingEmailNewsLetters')
LEFT JOIN 
    PERSON_EXT_ATTRS SMSMARKETING 
ON
	(
	    P.CENTER = SMSMARKETING.PERSONCENTER 
		AND P.ID = SMSMARKETING.PERSONID 
		AND SMSMARKETING.NAME = 'SMSMARKETING')
LEFT JOIN
    (
        SELECT
            sub.owner_center,
            sub.owner_id,
            MAX(NVL(sub.end_date, to_date('2100-01-01', 'YYYY-MM-DD'))) AS MaxEndDate
        FROM
            PUREGYM.SUBSCRIPTIONS sub
        WHERE
            sub.state IN (2,4,8)
        GROUP BY
            sub.owner_center,
            sub.owner_id ) active_subs
ON
    active_subs.owner_center = p.center
    AND active_subs.owner_id = p.id
WHERE
    p.center IN (:scope)
    AND p.LAST_ACTIVE_START_DATE IS NOT NULL
    AND p.status < 4
    AND p.sex != 'C'
    AND p.persontype NOT IN (2)