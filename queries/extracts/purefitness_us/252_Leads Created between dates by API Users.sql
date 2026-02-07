WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST(dateToLongC(TO_CHAR(CAST($$From_Date$$ AS DATE),'YYYY-MM-DD') || ' 00:00', c.id) AS BIGINT)                from_date ,
            CAST(dateToLongC(TO_CHAR(CAST($$To_Date$$ AS DATE),'YYYY-MM-DD') || ' 00:00', c.id) AS BIGINT)+ 1000*60*60*24 to_date
        FROM
            centers c
    )
SELECT
    cen.NAME,
    p.center || 'p' || p.id AS PersonKey,
    p.FULLNAME,
    CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                                                        AS "PaymentAgreementState",
    TO_CHAR(longtodateC(pag.CREATION_TIME,pag.center),'YYYY-MM-DD HH24:MI')    AS DDICreationTime,
    e.IDENTITY                                                                 AS PIN,
    email.TXTVALUE                                                             AS Email,
    mobile.TXTVALUE                                                            AS Mobile,
    homephone.TXTVALUE                                                         AS HomePhone,
    TO_CHAR(longtodateC(j.CREATION_TIME,j.PERSON_CENTER),'YYYY-MM-DD HH24:MI') AS PersonCreationTime,
    newsletter.TXTVALUE                                                        AS "Accepting Newsletter",
    offers.TXTVALUE                                                            AS "Accepting 3rd party offers"
FROM
    PERSONS p
JOIN
    params
ON
    params.id = p.center
JOIN
    ACCOUNT_RECEIVABLES acr
ON
    acr.CUSTOMERCENTER = p.CENTER
    AND acr.CUSTOMERID = p.ID
    AND acr.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = acr.CENTER
    AND pac.ID = acr.ID
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pac.ACTIVE_AGR_CENTER
    AND pag.ID = pac.ACTIVE_AGR_ID
    AND pag.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.NAME = 'Person created'
LEFT JOIN
    EMPLOYEES emp
ON
    j.CREATORCENTER = emp.CENTER
    AND j.CREATORID = emp.id
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.personcenter = p.center
    AND email.personid = p.id
    AND email.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    mobile.personcenter = p.center
    AND mobile.personid = p.id
    AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS homephone
ON
    homephone.personcenter = p.center
    AND homephone.personid = p.id
    AND homephone.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS newsletter
ON
    newsletter.personcenter = p.center
    AND newsletter.personid = p.id
    AND newsletter.name = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS offers
ON
    offers.personcenter = p.center
    AND offers.personid = p.id
    AND offers.name = 'eClubIsAcceptingThirdPartyOffers'
WHERE
    j.CREATION_TIME BETWEEN params.from_date AND params.to_date
    AND p.STATUS = 0
    /* Only payment agreement state 'OK' */
    AND pag.STATE = 4
    AND emp.USE_API = 1