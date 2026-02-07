WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$FromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS fromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$ToDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS toDate
        FROM
            centers c
    )
SELECT DISTINCT
    t1.ReferralDate               AS "ReferralDate",
    t1.ReferrerCenter             AS "ReferrerCenter",
    t1.ReferrerName               AS "ReferrerName",
    t1.ReferrerCode               AS "ReferrerCode",
    t1.ReferrerEmail              AS "ReferrerEmail",
    t1.ReferrerExternalID         AS "ReferrerExternalID",
    t1.ReferrerStatus             AS "ReferrerStatus",
    t1.ReferrerSex                AS "ReferrerSex",
    t1.ReferrerAddress1           AS "ReferrerAddress1",
    t1.ReferrerAddress2           AS "ReferrerAddress2",
    t1.ReferrerAddress3           AS "ReferrerAddress3",
    t1.ReferrerZipCode            AS "ReferrerZipCode",
    t1.ReferrerCity               AS "ReferrerCity",
    t1.ReferrerMobile             AS "ReferrerMobile",
    t1.ReferrerPhoneHome          AS "ReferrerPhoneHome",
    t1.ReferrerOldCode            AS "ReferrerOldCode",
    t2.referrerGlobalId           AS "ReferrerSubID",
    t1.ReferrerSubPrice           AS "ReferrerSubPrice",
    t1.ReferrerDeductionDay       AS "ReferrerDeductionDay",
    t1.ReferrerNextCollectionDate AS "ReferrerNextCollectionDate",
    t1.ReferralCenter             AS "ReferralCenter",
    currentReferral.FULLNAME      AS "ReferralName",
    t1.ReferralCode               AS "ReferralCode",
    t1.ReferralEmail              AS "ReferralEmail",
    currentReferral.EXTERNAL_ID   AS "ReferralExternalID",
    t1.ReferralStatus             AS "ReferralStatus",
    t1.ReferralSex                AS "ReferralSex",
    currentReferral.ADDRESS1      AS "ReferralAddress1",
    currentReferral.ADDRESS2      AS "ReferralAddress2",
    currentReferral.ADDRESS3      AS "ReferralAddress3",
    currentReferral.ZIPCODE       AS "ReferralZipCode",
    currentReferral.CITY          AS "ReferralCity",
    t1.ReferralMobile             AS "ReferralMobile",
    t1.ReferralPhoneHome          AS "ReferralPhoneHome",
    t1.ReferralOldCode            AS "ReferralOldCode",
    t3.referralGlobalId           AS "ReferralSubID"
FROM
    (
        SELECT
            TO_CHAR(longtodateC(t1.ENTRY_START_TIME, t1.referrerCENTER), 'YYYY-MM-DD HH24:MI:SS') AS ReferralDate,
            longtodateC(t1.ENTRY_START_TIME, t1.referrerCENTER)                                   AS ReferralDateComp,
            cen.NAME                                                                              AS ReferrerCenter,
            referrer.FULLNAME                                                                     AS ReferrerName,
            referrer.CENTER || 'p' || referrer.ID                                                 AS ReferrerCode,
            referrerEmail.TXTVALUE                                                                AS ReferrerEmail,
            referrer.EXTERNAL_ID                                                                  AS ReferrerExternalID,
            CASE referrer.STATUS
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
            END AS ReferrerStatus,
            (
                CASE referrer.SEX
                    WHEN 'M'
                    THEN 'Male'
                    WHEN 'F'
                    THEN 'Female'
                    ELSE 'Undefined'
                END)                            AS ReferrerSex,
            referrer.ADDRESS1                   AS ReferrerAddress1,
            referrer.ADDRESS2                   AS ReferrerAddress2,
            referrer.ADDRESS3                   AS ReferrerAddress3,
            referrer.ZIPCODE                    AS ReferrerZipCode,
            referrer.CITY                       AS ReferrerCity,
            referrerMobile.TXTVALUE             AS ReferrerMobile,
            referrerPhoneHome.TXTVALUE          AS ReferrerPhoneHome,
            referrerOldCode.TXTVALUE            AS ReferrerOldCode,
            s.SUBSCRIPTION_PRICE                AS ReferrerSubPrice,
            pa.INDIVIDUAL_DEDUCTION_DAY         AS ReferrerDeductionDay,
            s.BILLED_UNTIL_DATE +1              AS ReferrerNextCollectionDate,
            cen2.NAME                           AS ReferralCenter,
            referral.center ||'p'|| referral.id AS ReferralCode,
            referralEmail.TXTVALUE              AS ReferralEmail,
            CASE referral.STATUS
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
            END AS ReferralStatus,
            (
                CASE referral.SEX
                    WHEN 'M'
                    THEN 'Male'
                    WHEN 'F'
                    THEN 'Female'
                    ELSE 'Undefined'
                END)                   AS ReferralSex,
            referralMobile.TXTVALUE    AS ReferralMobile,
            referralPhoneHome.TXTVALUE AS ReferralPhoneHome,
            referralOldCode.TXTVALUE   AS ReferralOldCode,
            referrer.CENTER            AS ferrerCenter,
            referrer.ID                AS ferrerId,
            referral.CENTER            AS ferralCenter,
            referral.ID                AS ferralId,
            referral.CURRENT_PERSON_CENTER,
            referral.CURRENT_PERSON_ID
        FROM
            (
                SELECT
                    referrer.CENTER AS referrerCENTER,
                    referrer.ID     AS referrerID,
                    referral.CENTER AS referralCENTER,
                    referral.ID     AS referralID,
                    scl.ENTRY_START_TIME,
                    rank() over (partition BY referrer.CENTER, referrer.ID, referral.TRANSFERS_CURRENT_PRS_CENTER, referral.TRANSFERS_CURRENT_PRS_ID ORDER BY scl.ENTRY_START_TIME ASC) AS RNK
                FROM
                    PERSONS referrer
                JOIN
                    RELATIVES rel
                ON
                    rel.RELATIVECENTER = referrer.center
                    AND rel.RELATIVEID = referrer.id
                    --AND rel.STATUS < 3
                    AND rel.RTYPE = 13
                JOIN
                    STATE_CHANGE_LOG scl
                ON
                    scl.center = rel.center
                    AND scl.id = rel.id
                    AND scl.subid = rel.SUBID
                    AND scl.ENTRY_TYPE = 4
                    AND scl.STATEID = 1
                JOIN
                    PERSONS referral
                ON
                    referral.center = rel.center
                    AND referral.id = rel.id
                WHERE
                    referrer.center IN ($$Scope$$) ) t1
        JOIN
            PARAMS
        ON
            PARAMS.id = t1.referrerCENTER
        LEFT JOIN
            CENTERS cen
        ON
            cen.ID = t1.referrerCENTER
        LEFT JOIN
            PERSONS referrer
        ON
            referrer.CENTER = t1.referrerCENTER
            AND referrer.ID = t1.referrerID
        LEFT JOIN
            PERSON_EXT_ATTRS referrerMobile
        ON
            referrerMobile.PERSONCENTER = referrer.CENTER
            AND referrerMobile.PERSONID = referrer.ID
            AND referrerMobile.NAME = '_eClub_PhoneSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS referrerPhoneHome
        ON
            referrerPhoneHome.PERSONCENTER = referrer.CENTER
            AND referrerPhoneHome.PERSONID = referrer.ID
            AND referrerPhoneHome.NAME = '_eClub_PhoneHome'
        LEFT JOIN
            PERSON_EXT_ATTRS referrerEmail
        ON
            referrerEmail.PERSONCENTER = referrer.CENTER
            AND referrerEmail.PERSONID = referrer.ID
            AND referrerEmail.NAME = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS referrerOldCode
        ON
            referrerOldCode.PERSONCENTER = referrer.CENTER
            AND referrerOldCode.PERSONID = referrer.ID
            AND referrerOldCode.NAME = 'OLD_REFER_CODE'
        LEFT JOIN
            SUBSCRIPTIONS s -- THIS JOIN WILL RETURN DUPLICATES
        ON
            s.OWNER_CENTER = referrer.CENTER
            AND s.OWNER_ID = referrer.ID
            AND s.STATE IN (2,4)
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = referrer.CENTER
            AND ar.CUSTOMERID = referrer.ID
            AND ar.AR_TYPE = 4
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.id = ar.ID
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pac.ACTIVE_AGR_CENTER
            AND pa.id = pac.ACTIVE_AGR_ID
            AND pa.SUBID = pac.ACTIVE_AGR_SUBID
        LEFT JOIN
            CENTERS cen2
        ON
            cen2.ID = t1.referralCENTER
        LEFT JOIN
            PERSONS referral
        ON
            referral.CENTER = t1.referralCENTER
            AND referral.ID = t1.referralID
        LEFT JOIN
            PERSON_EXT_ATTRS referralMobile
        ON
            referralMobile.PERSONCENTER = referral.CURRENT_PERSON_CENTER
            AND referralMobile.PERSONID = referral.CURRENT_PERSON_ID
            AND referralMobile.NAME = '_eClub_PhoneSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS referralPhoneHome
        ON
            referralPhoneHome.PERSONCENTER = referral.CURRENT_PERSON_CENTER
            AND referralPhoneHome.PERSONID = referral.CURRENT_PERSON_ID
            AND referralPhoneHome.NAME = '_eClub_PhoneHome'
        LEFT JOIN
            PERSON_EXT_ATTRS referralEmail
        ON
            referralEmail.PERSONCENTER = referral.CURRENT_PERSON_CENTER
            AND referralEmail.PERSONID = referral.CURRENT_PERSON_ID
            AND referralEmail.NAME = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS referralOldCode
        ON
            referralOldCode.PERSONCENTER = referral.CURRENT_PERSON_CENTER
            AND referralOldCode.PERSONID = referral.CURRENT_PERSON_ID
            AND referralOldCode.NAME = 'OLD_REFER_CODE'
        WHERE
            t1.RNK = 1
            AND t1.ENTRY_START_TIME >= PARAMS.fromDate
            AND t1.ENTRY_START_TIME < PARAMS.toDate ) t1
LEFT JOIN
    (
        SELECT
            referrer.CENTER AS referrerCENTER,
            referrer.ID     AS referrerID,
            pr.GLOBALID     AS referrerGlobalId,
            sclsub.*
        FROM
            PERSONS referrer
        JOIN
            PARAMS
        ON
            PARAMS.id = referrer.CENTER
        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = referrer.center
            AND rel.RELATIVEID = referrer.id
            AND rel.RTYPE = 13
        JOIN
            PERSONS referral
        ON
            referral.center = rel.center
            AND referral.id = rel.id -- new member
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = rel.center
            AND scl.id = rel.id
            AND scl.subid = rel.SUBID
            AND scl.ENTRY_TYPE = 4
            AND scl.STATEID = 1
        JOIN
            SUBSCRIPTIONS sref
        ON
            sref.OWNER_CENTER = referrer.CENTER
            AND sref.OWNER_ID = referrer.ID
        JOIN
            STATE_CHANGE_LOG sclsub
        ON
            sclsub.CENTER = sref.CENTER
            AND sclsub.ID = sref.ID
            AND sclsub.ENTRY_TYPE = 2
            AND sclsub.ENTRY_START_TIME <= scl.ENTRY_START_TIME + (10*60*1000)
            AND (
                sclsub.ENTRY_END_TIME IS NULL
                OR sclsub.ENTRY_END_TIME > scl.ENTRY_START_TIME)
            AND sclsub.STATEID IN (2,4)
        JOIN
            PRODUCTS pr
        ON
            sref.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
            AND sref.SUBSCRIPTIONTYPE_ID = pr.ID
        WHERE
            referrer.center IN ($$Scope$$)
            AND (
                referrer.STATUS IN (1,3)
                OR referrer.PERSONTYPE = 2)
            AND referral.STATUS < 5
            AND scl.ENTRY_START_TIME >= PARAMS.fromDate
            AND scl.ENTRY_START_TIME < PARAMS.toDate ) t2
ON
    t1.ferrerCenter = t2.referrerCENTER
    AND t1.ferrerId = t2.referrerID
LEFT JOIN
    (
        SELECT
            referral.CENTER AS referralCENTER,
            referral.ID     AS referralID,
            pr.GLOBALID     AS referralGlobalId,
            sclsub.*,
            longtodateC(sref.CREATION_TIME, referral.CENTER) AS SubCreationTime
        FROM
            PERSONS referrer
        JOIN
            PARAMS
        ON
            PARAMS.id = referrer.CENTER
        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = referrer.center
            AND rel.RELATIVEID = referrer.id
            AND rel.RTYPE = 13
        JOIN
            PERSONS referral
        ON
            referral.center = rel.center
            AND referral.id = rel.id -- new member
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = rel.center
            AND scl.id = rel.id
            AND scl.subid = rel.SUBID
            AND scl.ENTRY_TYPE = 4
            AND scl.STATEID = 1
        JOIN
            SUBSCRIPTIONS sref
        ON
            sref.OWNER_CENTER = referral.CENTER
            AND sref.OWNER_ID = referral.ID
        JOIN
            STATE_CHANGE_LOG sclsub
        ON
            sclsub.CENTER = sref.CENTER
            AND sclsub.ID = sref.ID
            AND sclsub.ENTRY_TYPE = 2
            AND sclsub.ENTRY_START_TIME <= scl.ENTRY_START_TIME + (10*60*1000)
            AND (
                sclsub.ENTRY_END_TIME IS NULL
                OR sclsub.ENTRY_END_TIME > scl.ENTRY_START_TIME)
            AND sclsub.STATEID IN (2,4,8)
        JOIN
            PRODUCTS pr
        ON
            sref.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
            AND sref.SUBSCRIPTIONTYPE_ID = pr.ID
        WHERE
            referrer.center IN ($$Scope$$)
            AND (
                referrer.STATUS IN (1,3)
                OR referrer.PERSONTYPE = 2)
            AND referral.STATUS < 5
            AND scl.ENTRY_START_TIME >= PARAMS.fromDate
            AND scl.ENTRY_START_TIME < PARAMS.toDate ) t3
ON
    t1.ferralCenter = t3.referralCENTER
    AND t1.ferralId = t3.referralID
JOIN
    PERSONS currentReferral
ON
    currentReferral.CENTER = t1.CURRENT_PERSON_CENTER
    AND currentReferral.ID = t1.CURRENT_PERSON_ID
WHERE
    t3.SubCreationTime IS NOT NULL
    AND DATE_TRUNC('day', t3.SubCreationTime) = DATE_TRUNC('day', t1.ReferralDateComp)