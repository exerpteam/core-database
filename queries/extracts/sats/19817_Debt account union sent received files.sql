SELECT
    TO_CHAR(longToDate(art.ENTRY_TIME),'YYYY-MM-DD') "date",
    'ACCOUNT' TYPE,
    art.TEXT,
    longToDate(art.ENTRY_TIME) trans_time,
    art.AMOUNT,
    (
        SELECT
            SUM(art1.AMOUNT)
        FROM
            AR_TRANS art1
        WHERE
            art1.CENTER = art.CENTER
            AND art1.id = art.id
            AND art1.SUBID > art.SUBID
    )
    balance,
    2 "order"
FROM
    ACCOUNT_RECEIVABLES ar
JOIN AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.id = ar.id
WHERE
    ar.AR_TYPE = 5
    AND ar.CUSTOMERCENTER = :center
    AND ar.CUSTOMERID = :id
UNION
SELECT
    TO_CHAR(ccr.REQ_DATE,'YYYY-MM-DD') ,
    'FILE_OUT' TYPE,
    'Sent= ' || cout.SENT_DATE || ' file id = ' || cout.id || ' cc service= ' || ccs.NAME || ' pr deduction date= ' || pr.REQ_DATE info,
    NULL,
    ccr.REQ_AMOUNT,
    NULL,
    3
FROM
    CASHCOLLECTIONCASES ccc
JOIN PERSONS p
ON
    p.CENTER = ccc.PERSONCENTER
    AND p.id = ccc.PERSONID
JOIN CASHCOLLECTION_REQUESTS ccr
ON
    ccr.CENTER = ccc.CENTER
    AND ccr.ID = ccc.ID
JOIN CASHCOLLECTION_OUT cout
ON
    cout.ID = ccr.REQ_DELIVERY
JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = ccr.PRSCENTER
    AND prs.ID = ccr.PRSID
    AND prs.SUBID = ccr.PRSSUBID
JOIN PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN CASHCOLLECTIONSERVICES ccs
ON
    ccs.ID = cout.CASHCOLLECTIONSERVICE
WHERE
    ccc.PERSONCENTER = :center
    AND ccc.PERSONID = :id
UNION
SELECT
    TO_CHAR(longToDate(art.ENTRY_TIME),'YYYY-MM-DD') "date",
    'FILE_IN' TYPE,
    'Received= ' || cin.RECEIVED_DATE || ' file id = ' || cin.id || ' cc service =' || ccs.NAME info,
    NULL,
    act.AMOUNT,
    NULL,
    1
FROM
    ACCOUNT_RECEIVABLES ar
JOIN AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.id = ar.id
JOIN ACCOUNT_TRANS act
ON
    act.CENTER = art.REF_CENTER
    AND act.ID = art.REF_ID
    AND act.SUBID = art.REF_SUBID
    AND act.INFO_TYPE = 4
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
JOIN CASHCOLLECTION_IN cin
ON
    cin.ID = act.INFO
JOIN CASHCOLLECTIONSERVICES ccs
ON
    ccs.ID = cin.CASHCOLLECTIONSERVICE
WHERE
    ar.AR_TYPE = 5
    AND ar.CUSTOMERCENTER = :center
    AND ar.CUSTOMERID = :id
ORDER BY
    1 DESC,
    7 DESC,
    4 DESC