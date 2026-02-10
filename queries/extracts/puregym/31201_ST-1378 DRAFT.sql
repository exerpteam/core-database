-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pr.CENTER
  ,pr.id
  ,pr.SUBID
  ,ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID PersonKey
  ,p.FIRSTNAME
  ,ei.IDENTITY
  ,pr.STATE
  ,pr.REQ_AMOUNT
  ,pr.REQ_DATE
  ,prs.REF
  ,DECODE(pr.REQUEST_TYPE,1,'INVOICE',6,'REPRESENTATION','OTHER ' || pr.REQUEST_TYPE) type
  ,DECODE(pr.REQUEST_TYPE,1,'FIRST',6,'SECOND','OTHER ' || pr.REQUEST_TYPE)           email_to_be_sent
FROM
    MASTERPRODUCTREGISTER mpr
JOIN
    PRODUCTS prod
ON
    prod.GLOBALID = mpr.GLOBALID
JOIN
    SUBSCRIPTIONS s
ON
    s.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = prod.ID
    AND s.STATE IN (2,4,8)
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = s.OWNER_CENTER
    AND ar.CUSTOMERID = s.OWNER_ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
LEFT JOIN
    ENTITYIDENTIFIERS ei
ON
    ei.IDMETHOD = 5
    AND ei.REF_TYPE = 1
    AND ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.ID
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID
    AND pr.STATE = 17
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pr.INV_COLL_CENTER
    AND prs.ID = pr.INV_COLL_ID
    AND prs.SUBID = pr.INV_COLL_SUBID
    /* Make sure there is a advance notice message sent as well */
JOIN
    MESSAGES m
ON
    m.CENTER = ar.CUSTOMERCENTER
    AND m.ID = ar.CUSTOMERID
    AND m.TEMPLATETYPE = 171
    AND m.SENTTIME >= dateToLong(TO_CHAR(TRUNC(SYSDATE,'month'),'YYYY-MM-DD HH24:MI'))
WHERE
    mpr.GLOBALID IN ('PT_RENT_1000'
                   ,'PT_RENT_400'
                   ,'PT_RENT_500'
                   ,'PT_RENT_600'
                   ,'PT_RENT_700'
                   ,'PT_RENT_800')
    AND pa.CLEARINGHOUSE = 1
    AND pr.REQ_DATE >= TRUNC(SYSDATE,'month')
    AND pr.SUBID IN
    (
        SELECT
            MAX(pr2.SUBID)
        FROM
            PAYMENT_REQUESTS pr2
        WHERE
            pr2.CENTER = pr.CENTER
            AND pr2.ID = pr.ID)