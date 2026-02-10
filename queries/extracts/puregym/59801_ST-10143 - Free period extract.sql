-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS MEMBER_ID,
    pag.INDIVIDUAL_DEDUCTION_DAY,
    prs.OPEN_AMOUNT    Open_amount_still_unpaid,
    ar.balance      AS Account_Balance
FROM
    SUBSCRIPTION_REDUCED_PERIOD srp
JOIN
    SUBSCRIPTIONS sub
ON
    srp.SUBSCRIPTION_CENTER = sub.CENTER
AND srp.SUBSCRIPTION_ID = sub.ID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    sub.OWNER_CENTER = ar.CUSTOMERCENTER
AND sub.OWNER_ID = ar.CUSTOMERID
JOIN
    PERSONS p
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    PAYMENT_ACCOUNTS pm
ON
    pm.center = ar.center
AND pm.id = ar.id
    -- Condition to check deduction date for the member.
JOIN
    PAYMENT_AGREEMENTS pag
ON
    ar.CENTER = pag.CENTER
AND ar.ID = pag.ID
AND pm.ACTIVE_AGR_SUBID = pag.subid
    -- Open amount
JOIN
    AR_TRANS atr
ON
    ar.CENTER = atr.CENTER
AND ar.ID = atr.ID
JOIN
    PAYMENT_REQUESTS pr
ON
    ar.CENTER = pr.CENTER
AND ar.ID = pr.ID
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID

JOIN SUBSCRIPTION_PRICE sup 

ON sub.ID = sup.SUBSCRIPTION_ID
AND sub.CENTER = sup.SUBSCRIPTION_CENTER
    -- Free period check.
WHERE
    srp.TEXT = 'CLOSURE'
AND srp.START_DATE = TO_DATE('26-11-2019', 'dd-MM-yyyy')
AND srp.END_DATE = TO_DATE('31-01-2020', 'dd-MM-yyyy')
AND sup.FROM_DATE > TO_DATE('01-11-2019', 'dd-MM-yyyy') 
