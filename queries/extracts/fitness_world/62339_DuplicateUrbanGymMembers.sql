-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-173
SELECT DISTINCT
    p.center                                                                                                                                                                          AS PersonCenter,
    p.center || 'p' || p.id                                                                                                                                                           AS PersonId,
    p.external_id                                                                                                                                                                     AS ExternalId,
    p.fullname                                                                                                                                                                        AS PersonName,
    p.birthdate                                                                                                                                                                       AS PersonDOB,
    pemail.txtvalue                                                                                                                                                                   AS PersonEmail,
    p.ssn                                                                                                                                                                             AS PersonCPR,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PersonType,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN')   AS PersonStatus,
    dup.center                                                                                                                                                                        AS DupPersonCenter,
    dupcen.name                                                                                                                                                                       AS DupPerCenterName,
    dup.center || 'p' || dup.id                                                                                                                                                       AS DupPersonId,
    dup.external_id                                                                                                                                                                   AS DupPerExternalId,
    dup.fullname                                                                                                                                                                      AS DupPerName,
    dup.birthdate                                                                                                                                                                     AS DupPerDOB,
    dupemail.txtvalue                                                                                                                                                                 AS DupPerEmail,
    dup.ssn                                                                                                                                                                           AS DupPerCPR,
    DECODE ( dup.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                       AS DupPersonType,
    DECODE (dup.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS DupPersonStatus,
    pd.name                                                                                                                                                                           AS DupMembershipName,
    payment_ar.balance                                                                                                                                                                AS DupPaymentAccountBalance,
    cash_ar.balance                                                                                                                                                                   AS DupCashAccountBalance,
    debt_ar.balance                                                                                                                                                                   AS DupDebtAccountBalance,
    inst_ar.balance                                                                                                                                                                   AS DupInstallAccountBalance,
    CASE
        WHEN otherpayrel.CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,
    CASE
        WHEN paidbyrel.CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS PAID_BY_OTHER,
    CASE
        WHEN clips.CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CLIP_CARD,
    CASE
        WHEN ccc.CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_OPEN_DEBT_CASE
FROM
    persons p
JOIN
    person_ext_attrs pea
ON
    pea.NAME='_eClub_OldSystemPersonId'
    AND pea.personcenter = p.center
    AND pea.personid = p.id
JOIN
    converter_entity_state c
ON
    c.newentitycenter = p.center
    AND c.newentityid = p.id
    AND c.writername = 'ClubLeadPersonWriter'
    AND c.oldentityid LIKE 'URGYM%'
JOIN
    persons dup
ON
    dup.status NOT IN (4,5,7,8)
    AND (
        dup.center <> p.center
        OR dup.id <> p.id)
JOIN
    fw.centers dupcen
ON
    dupcen.id = dup.center
JOIN
    PERSON_EXT_ATTRS pemail
ON
    pemail.PERSONCENTER = p.CENTER
    AND pemail.PERSONID = p.ID
    AND pemail.NAME = '_eClub_Email'
JOIN
    PERSON_EXT_ATTRS dupemail
ON
    dupemail.PERSONCENTER = dup.CENTER
    AND dupemail.PERSONID = dup.ID
    AND dupemail.NAME = '_eClub_Email'
LEFT JOIN
    subscriptions sub
ON
    sub.owner_center = dup.center
    AND sub.owner_id = dup.id
    AND sub.STATE IN (2,4,8)
LEFT JOIN
    PRODUCTS pd
ON
    pd.center = sub.subscriptiontype_center
    AND pd.id = sub.subscriptiontype_id
LEFT JOIN
    RELATIVES otherpayrel
ON
    otherpayrel.center = dup.center
    AND otherpayrel.id = dup.id
    AND otherpayrel.RTYPE = 12
    AND otherpayrel.STATUS < 3
LEFT JOIN
    RELATIVES paidbyrel
ON
    paidbyrel.relativecenter = dup.center
    AND paidbyrel.relativeid = dup.id
    AND paidbyrel.RTYPE = 12
    AND paidbyrel.STATUS < 3
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = dup.center
    AND payment_ar.CUSTOMERID = dup.id
	AND payment_ar.state = 0
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=dup.center
    AND cash_ar.CUSTOMERID=dup.id
	AND cash_ar.state = 0
    AND cash_ar.AR_TYPE = 1
LEFT JOIN
    ACCOUNT_RECEIVABLES debt_ar
ON
    debt_ar.CUSTOMERCENTER=dup.center
    AND debt_ar.CUSTOMERID=dup.id
	AND debt_ar.state = 0
    AND debt_ar.AR_TYPE = 5
LEFT JOIN
    ACCOUNT_RECEIVABLES inst_ar
ON
    inst_ar.CUSTOMERCENTER=dup.center
    AND inst_ar.CUSTOMERID=dup.id
	AND inst_ar.state = 0
    AND inst_ar.AR_TYPE = 6
LEFT JOIN
    clipcards clips
ON
    clips.OWNER_CENTER = dup.center
    AND clips.OWNER_ID = dup.id
    AND clips.CLIPS_LEFT > 0
    AND clips.FINISHED = 0
    AND clips.CANCELLED = 0
    AND clips.BLOCKED = 0
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = dup.center
    AND ccc.PERSONID = dup.id
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
WHERE
    p.center IN (100,287,112,113,155,264,284,285,286,601,617)
    AND p.status NOT IN (4,5,7,8)
    AND dup.birthdate = p.birthdate
    AND dup.fullname = p.fullname
    AND pemail.txtvalue = dupemail.txtvalue
    AND p.ssn = dup.ssn
    AND dup.center NOT IN
    (
        SELECT
            ac.center
        FROM
            fw.area_centers ac
        WHERE
            ac.area IN (33,34))