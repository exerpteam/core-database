SELECT DISTINCT
    c.name                                             AS "Club Name"
  , p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS "Member Id"
  , p.FULLNAME                                         AS "Full Name"
  , pem.TXTVALUE                                       AS Email
  , ph.TXTVALUE                                        AS PhoneHome
  , pm.TXTVALUE                                        AS Mobile
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
    --and pr.STATE in (3,4)
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pr.CENTER
    AND pa.id = pr.id
    AND pa.SUBID = pr.AGR_SUBID
    AND pa.STATE NOT IN (4)
/* ST-2281 Limit by when the state changed in relation to when the report was ran */    
JOIN
    AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = pa.CENTER
    AND acl.AGREEMENT_ID = pa.ID
    AND acl.AGREEMENT_SUBID = pa.SUBID
    AND acl.STATE = pa.STATE
    AND TRUNC(longToDateC(acl.ENTRY_TIME,pa.CENTER)) > TRUNC(SYSDATE-4)
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = prs.CENTER
    AND ar.ID = prs.ID
    /* ST-1872The person should not be BLACKLISTED or SUSPENDED */
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND p.BLACKLISTED NOT IN (1,2)
    AND p.STATUS = 1
    /*
    ST-1872Just make sure he has/had some none day pass sub
    */
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
JOIN
    PUREGYM.CENTERS c
ON
    c.Id = p.CENTER
WHERE
    c.id IN ($$scope$$)
    AND prs.ORIGINAL_DUE_DATE >= TRUNC(SYSDATE,'MM')
    AND prs.PAID_STATE = 'CLOSED'
    AND
    /* I guess this means more than six month of good payment history before the bad one */
    EXISTS
    (
        SELECT
            COUNT(1)
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs2
        JOIN
            PAYMENT_REQUESTS pr2
        ON
            pr2.INV_COLL_CENTER = prs2.CENTER
            AND pr2.INV_COLL_id = prs2.id
            AND pr2.INV_COLL_SUBID = prs2.SUBID
            AND pr2.STATE IN (3,4)
        WHERE
            prs2.COLLECTION_FEE = 0
            AND prs2.REJECTION_FEE = 0
            AND prs2.CENTER = prs.CENTER
            AND prs2.ID = prs.ID
            AND prs2.OPEN_AMOUNT = 0
            AND prs2.ORIGINAL_DUE_DATE < prs.ORIGINAL_DUE_DATE
            AND prs2.ORIGINAL_DUE_DATE >= add_months(TRUNC(prs.ORIGINAL_DUE_DATE,'mm'),-6)
        HAVING
            COUNT(1) > 5)
    AND prs.SUBID =
    (
        SELECT
            MAX(prs2.subid)
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs2
        WHERE
            prs2.CENTER = prs.CENTER
            AND prs2.id = prs.id)
    /*
    The member should have some kind of phone number
    */
    AND EXISTS
    (
        SELECT
            1
        FROM
            PERSON_EXT_ATTRS atts
        WHERE
            atts.PERSONCENTER = p.CENTER
            AND atts.PERSONID = p.ID
            AND atts.NAME IN ('_eClub_PhoneSMS'
                            ,'_eClub_PhoneHome') )
    /*
    ST-1872Filter out so we only get the latest sub
    */
    AND s.START_DATE =
    (
        SELECT
            MAX(s2.start_date)
        FROM
            SUBSCRIPTIONS s2
        WHERE
            s2.OWNER_CENTER = s.OWNER_CENTER
            AND s2.OWNER_ID = s.OWNER_ID)