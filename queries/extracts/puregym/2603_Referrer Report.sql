-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    dat.CenterName                                 AS "Gym Location",
    dat.name                                       AS "Name",
    dat.AffiliateCode                              AS "Active Affiliate Code",
    dat.OldAffiliateCode                           AS "Old Affiliate Code",
    dat.ReferrerEmail                              AS "Email",
    COUNT(*)                                       AS "Referrals",
    SUM(DECODE(dat.ReferralStatus, 1, 1, 3, 1, 0)) AS "Active Member Referrals",
    SUM(DECODE(dat.ReferralStatus, 1, 0, 3, 0, 1)) AS "Inactive Member Referrals"
FROM
    (
        SELECT
            referrer.center,
            referrer.center || 'p' || referrer.id AS AffiliateCode,
            referral.center ReferralCenter,
            referral.center ||'p'|| referral.id                         AS Referral,
            longtodateTZ(scl.ENTRY_START_TIME, 'Europe/London') AS ReferralDate,
            referral.status                                             AS ReferralStatus,
            cen.NAME                                                    AS CenterName,
            referrer.FULLNAME                                           AS Name,
            ReferrerEmail.TXTVALUE                                      AS ReferrerEmail,
            oldcode.TXTVALUE                                            AS OldAffiliateCode
        FROM
            persons referrer -- old member
        JOIN PUREGYM.RELATIVES rel
        ON
            rel.RELATIVECENTER = referrer.center
            AND rel.RELATIVEID = referrer.id
            AND rel.STATUS < 3
            AND rel.RTYPE = 13
        JOIN PUREGYM.persons referral
        ON
            referral.center = rel.center
            AND referral.id = rel.id -- new member
        JOIN PUREGYM.STATE_CHANGE_LOG scl
        ON
            scl.center = rel.center
            AND scl.id = rel.id
            AND scl.subid = rel.SUBID
            AND scl.ENTRY_TYPE = 4
            AND scl.STATEID = 1
        LEFT JOIN PUREGYM.CENTERS cen
        ON
            cen.ID = referrer.CENTER
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS oldcode
        ON
            oldcode.PERSONCENTER = referrer.CENTER
            AND oldcode.PERSONID = referrer.ID
            AND oldcode.NAME = 'OLD_REFER_CODE'
        LEFT JOIN
         PUREGYM.PERSON_EXT_ATTRS ReferrerEmail
         on ReferrerEmail.PERSONCENTER = referrer.CENTER 
         and  ReferrerEmail.PERSONID = referrer.ID 
         and ReferrerEmail.NAME = '_eClub_Email'    
            
        WHERE
            referrer.center IN (:scope)
            AND (referrer.STATUS IN (1,3) or referrer.PERSONTYPE = 2)
            AND referral.STATUS < 4
            AND scl.ENTRY_START_TIME >= :datefrom
            AND scl.ENTRY_START_TIME < :dateto
            
    )
    dat
GROUP BY
    dat.Name,
    dat.CenterName,
    dat.AffiliateCode,
    dat.OldAffiliateCode,
    dat.ReferrerEmail