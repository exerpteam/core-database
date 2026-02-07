SELECT
    cen.NAME                                                                                                                                                 AS ReferralCenter,
    referrer.FULLNAME                                                                                                                                        AS ReferrerName,
    s.SUBSCRIPTION_PRICE                                                                                                                                     AS REFERRERSUBAMOUNT,
    pa.INDIVIDUAL_DEDUCTION_DAY                                                                                                                              AS REFERRERDEDUCTIONDAY,
    s.BILLED_UNTIL_DATE +1                                                                                                                                   AS REFERRERNEXTCOLLECTIONDATE,
    referrer.ADDRESS1                                                                                                                                        AS referrerAddress1,
    referrer.ADDRESS2                                                                                                                                        AS referrerAddress2,
    referrer.ADDRESS3                                                                                                                                        AS referrerAddress3,
    referrer.ZIPCODE                                                                                                                                         AS referrerZIP,
    referrer.CITY                                                                                                                                            AS referrerCity,
    referrer.center || 'p' || referrer.id                                                                                                                    AS AffliateCode,
    ReferrerMobile.TXTVALUE                                                                                                                                  AS ReferrerMobile,
    ReferrerPhoneHome.TXTVALUE                                                                                                                               AS ReferrerPhoneHome,
    ReferrerEmail.TXTVALUE                                                                                                                                   AS ReferrerEmail,
    ReferrerOldCode.TXTVALUE                                                                                                                                 AS ReferrerOldCode,
    DECODE ( Referrer.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS ReferrerSTATUS,
    referral.center ||'p'|| referral.id                                                                                                                      AS ReferralAffliateCode,
    cen2.NAME                                                                                                                                                AS ReferralCenterName,
    referral.FULLNAME                                                                                                                                        AS ReferralName,
    referral.ADDRESS1                                                                                                                                        AS ReferralAddress1,
    referral.ADDRESS2                                                                                                                                        AS ReferralAddress2,
    referral.ADDRESS3                                                                                                                                        AS ReferralAddress3,
    referral.ZIPCODE                                                                                                                                         AS ReferralZIP,
    referral.CITY                                                                                                                                            AS ReferralCity,
    referralMobile.TXTVALUE                                                                                                                                  AS referralMobile,
    referralPhoneHome.TXTVALUE                                                                                                                               AS referralPhoneHome,
    referralEmail.TXTVALUE                                                                                                                                   AS referralEmail,
    referralOldCode.TXTVALUE                                                                                                                                 AS referralOldCode,
    DECODE ( referral.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS ReferralSTATUS,
    longtodateTZ(scl.ENTRY_START_TIME, 'Europe/London')                                                                                              AS ReferralDate
FROM
    persons referrer -- old member
JOIN
    PUREGYM.RELATIVES rel
ON
    rel.RELATIVECENTER = referrer.center
    AND rel.RELATIVEID = referrer.id
    AND rel.STATUS < 3
    AND rel.RTYPE = 13
JOIN
    PUREGYM.persons referral
ON
    referral.center = rel.center
    AND referral.id = rel.id -- new member
JOIN
    PUREGYM.STATE_CHANGE_LOG scl
ON
    scl.center = rel.center
    AND scl.id = rel.id
    AND scl.subid = rel.SUBID
    AND scl.ENTRY_TYPE = 4
    AND scl.STATEID = 1
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = referrer.CENTER
LEFT JOIN
    PUREGYM.CENTERS cen2
ON
    cen2.ID = referral.CENTER
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ReferrerMobile
ON
    ReferrerMobile.PERSONCENTER = referrer.CENTER
    AND ReferrerMobile.PERSONID = referrer.ID
    AND ReferrerMobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ReferrerPhoneHome
ON
    ReferrerPhoneHome.PERSONCENTER = referrer.CENTER
    AND ReferrerPhoneHome.PERSONID = referrer.ID
    AND ReferrerPhoneHome.NAME = '_eClub_PhoneHome'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ReferrerEmail
ON
    ReferrerEmail.PERSONCENTER = referrer.CENTER
    AND ReferrerEmail.PERSONID = referrer.ID
    AND ReferrerEmail.NAME = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ReferrerOldCode
ON
    ReferrerOldCode.PERSONCENTER = referrer.CENTER
    AND ReferrerOldCode.PERSONID = referrer.ID
    AND ReferrerOldCode.NAME = 'OLD_REFER_CODE'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS referralMobile
ON
    referralMobile.PERSONCENTER = referral.CENTER
    AND referralMobile.PERSONID = referral.ID
    AND referralMobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS referralPhoneHome
ON
    referralPhoneHome.PERSONCENTER = referral.CENTER
    AND referralPhoneHome.PERSONID = referral.ID
    AND referralPhoneHome.NAME = '_eClub_PhoneHome'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS referralEmail
ON
    referralEmail.PERSONCENTER = referral.CENTER
    AND referralEmail.PERSONID = referral.ID
    AND referralEmail.NAME = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS referralOldCode
ON
    referralOldCode.PERSONCENTER = referral.CENTER
    AND referralOldCode.PERSONID = referral.ID
    AND referralOldCode.NAME = 'OLD_REFER_CODE'
LEFT JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = referrer.CENTER
    AND s.OWNER_ID = referrer.ID
    AND s.STATE IN (2,4)
LEFT JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = REFERRER.CENTER
    AND ar.CUSTOMERID = referrer.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PUREGYM.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.id = ar.ID
LEFT JOIN
    PUREGYM.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    referrer.center IN ($$scope$$)
    AND (
        referrer.STATUS IN (1,3)
        OR referrer.PERSONTYPE = 2)
    AND referral.STATUS < 4
    AND scl.ENTRY_START_TIME >= $$dateFrom$$
    AND scl.ENTRY_START_TIME < $$dateTo$$