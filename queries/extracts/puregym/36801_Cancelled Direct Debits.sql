SELECT distinct 
    c.name                                             AS "Club Name"
  , p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS "Member Id"
  , p.FULLNAME                                         AS "Full Name"
  , pem.TXTVALUE                                       AS Email
  , ph.TXTVALUE                                        AS PhoneHome
  , pm.TXTVALUE                                        AS Mobile
--  , TO_CHAR(s.START_DATE,'yyyy-MM-dd')                 AS "Membership Start"
--  , TO_CHAR(s.END_DATE,'yyyy-MM-dd')                   AS "Membership End"
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
    --and pr.STATE in (3,4)
join PAYMENT_AGREEMENTS pa on pa.CENTER = pr.CENTER and pa.id = pr.id and pa.SUBID = pr.AGR_SUBID and pa.STATE not in (4)    
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
    and p.STATUS = 1
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
    c.id in ($$scope$$)
    and prs.ORIGINAL_DUE_DATE >= trunc(sysdate,'MM')
    and prs.PAID_STATE = 'CLOSED'
    and
    EXISTS
    (
        SELECT
            COUNT(1)
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs2
            join PAYMENT_REQUESTS pr2 on pr2.INV_COLL_CENTER = prs2.CENTER and 
            pr2.INV_COLL_id = prs2.id and 
            pr2.INV_COLL_SUBID = prs2.SUBID
            and pr2.STATE in (3,4) 
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
     and prs.SUBID = (select max(prs2.subid) from PAYMENT_REQUEST_SPECIFICATIONS prs2 where prs2.CENTER = prs.CENTER and prs2.id = prs.id)       
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