-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid
    ,p.FULLNAME
  , prs.ORIGINAL_DUE_DATE
  , TO_CHAR(prs.ORIGINAL_DUE_DATE,'MONTH') FOR_MONTH
  , prs.REF
  , art.SUBID
  , SUM(
        CASE
            WHEN trans.REF_TYPE = 'INVOICE'
            THEN -1 * trans.total_amount
            ELSE trans.total_amount
        END) inv_amount
  , art.AMOUNT
  , art.UNSETTLED_AMOUNT
  , nvl2(acc.CENTER,'YES','NO') WRITE_OFF
FROM
    (
        SELECT
            'INVOICE' REF_TYPE
          , invl.CENTER
          , invl.ID
          , invl.SUBID
          , invl.TEXT
          , invl.TOTAL_AMOUNT
        FROM
            INVOICELINES invl
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = invl.PRODUCTCENTER
            AND prod.ID = invl.PRODUCTID
            AND prod.GLOBALID LIKE '%PT_RENT%'
        UNION
        SELECT
            'CREDIT_NOTE'
          , cnl.CENTER
          , cnl.ID
          , cnl.SUBID
          , cnl.TEXT
          , cnl.TOTAL_AMOUNT
        FROM
            CREDIT_NOTE_LINES cnl
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = cnl.PRODUCTCENTER
            AND prod.ID = cnl.PRODUCTID
            AND prod.GLOBALID LIKE '%PT_RENT%') trans
JOIN
    AR_TRANS art
ON
    art.REF_TYPE = trans.REF_TYPE
    AND art.REF_CENTER = trans.CENTER
    AND art.REF_ID = trans.ID
LEFT JOIN
    ART_MATCH artm
ON
    artm.ART_PAID_CENTER = art.CENTER
    AND artm.ART_PAID_ID = art.ID
    AND artm.ART_PAID_SUBID = art.SUBID
LEFT JOIN
    AR_TRANS artP
ON
    artP.CENTER = artm.ART_PAYING_CENTER
    AND artP.ID = artm.ART_PAYING_ID
    AND artP.SUBID = artm.ART_PAYING_SUBID
    AND artP.REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = artP.REF_CENTER
    AND act.ID = artP.REF_ID
    AND act.SUBID = artP.REF_SUBID
LEFT JOIN
    ACCOUNTS acc
ON
    acc.CENTER = act.DEBIT_ACCOUNTCENTER
    AND acc.ID = act.DEBIT_ACCOUNTID
    AND acc.EXTERNAL_ID = '1120'
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.ID = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
    AND ar.AR_TYPE = 4
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
    p.CENTER in ($$scope$$)
    AND prs.ORIGINAL_DUE_DATE > add_months(SYSDATE,-12)
GROUP BY
    ar.CUSTOMERCENTER
  ,ar.CUSTOMERID
  ,p.FULLNAME
  , prs.ORIGINAL_DUE_DATE
  , prs.REF
  , art.SUBID
  , art.AMOUNT
  , art.UNSETTLED_AMOUNT
  , nvl2(acc.CENTER,'YES','NO')