
/*
Rules:
* Should missed both payment and representation
* Payment agreements should be OK
* Day passes should not be included
* The period before missed payments should contain at least 6 month of payments with no bounce fee
* Blacklisted and suspended members should be filtered out
* Remove members with no phone number
*/
SELECT DISTINCT
    c.name                                             AS "Club Name"
  , p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS "Member Id"
  , p.FULLNAME                                         AS "Full Name"

FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
    /*
    ST-1870: Since a representation was created we know that there was an active agreement
    */
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
    AND pr.REQUEST_TYPE = 6
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = prs.CENTER
    AND ar.ID = prs.ID
    /* ST-1870: The person should not be BLACKLISTED or SUSPENDED */
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND p.BLACKLISTED NOT IN (1,2)
    /*
    ST-1870: Just make sure he has/had some none day pass sub
    */
JOIN
    STATE_CHANGE_LOG scl
ON
    scl.CENTER = p.CENTER
    AND scl.ID = p.ID
    AND scl.ENTRY_TYPE = 1
    AND scl.STATEID = 2
    AND scl.BOOK_END_TIME IS NULL
    AND scl.BOOK_START_TIME BETWEEN dateToLongC(TO_CHAR(TRUNC(SYSDATE),'YYYY-MM-DD HH24:MI'),p.CENTER) AND dateToLongC(TO_CHAR(TRUNC(SYSDATE+1),'YYYY-MM-DD HH24:MI'),p.CENTER)-1
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
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK link
ON
    link.PRODUCT_CENTER = prod.CENTER
    AND link.PRODUCT_ID = prod.ID
    AND link.PRODUCT_GROUP_ID != 603
JOIN
    PUREGYM.CENTERS c
ON
    c.Id = p.CENTER
WHERE
    /*
    ST-1870: Both normal payment and representation should have been neglected. Checked by user having both a rejection fee, collection fee and that the open amount > 0
    */
    prs.COLLECTION_FEE != 0
    AND prs.REJECTION_FEE != 0
    --and prs.OPEN_AMOUNT > 0
    AND prs.ORIGINAL_DUE_DATE BETWEEN add_months(SYSDATE,-1) AND SYSDATE
    --AND prs.REF = '50-57507'
    /*
    ST-1870: There should be at least 6 continuos payment before the filed paymentwithout any collection or rejection fees
    */
    AND EXISTS
    (
        SELECT
            COUNT(1)
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs2
        WHERE
            prs2.COLLECTION_FEE = 0
            AND prs2.REJECTION_FEE = 0
            AND prs2.CENTER = prs.CENTER
            AND prs2.ID = prs.ID
            AND prs2.OPEN_AMOUNT = 0
            AND prs2.ORIGINAL_DUE_DATE < prs.ORIGINAL_DUE_DATE
            AND prs2.ORIGINAL_DUE_DATE >= add_months(TRUNC(prs.ORIGINAL_DUE_DATE,'mm'),-2)
        HAVING
            COUNT(1) >= 2)
    /*
    ST-1870: Filter out so we only get the latest sub
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