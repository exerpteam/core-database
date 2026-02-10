-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER || 'p' || p.id pid
  , p.FULLNAME
  , prod.NAME                                            SUBSCRIPTION
  , s.CENTER || 'ss' || s.ID                             ssid
  , art.REF_TYPE                                         TRANSACTION_TYPE
  , nvl2(invl.CENTER,invl.TOTAL_AMOUNT,cnl.TOTAL_AMOUNT) amount
  , longToDate(art.TRANS_TIME)                           TRANS_TIME
  , art.TEXT                                             art_text
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = s.OWNER_CENTER
    AND ar.CUSTOMERID = s.OWNER_ID
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND art.REF_TYPE IN ('INVOICE'
                       ,'CREDIT_NOTE')
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = art.REF_CENTER
    AND invl.ID = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    CREDIT_NOTE_LINES cnl
ON
    cnl.CENTER = art.REF_CENTER
    AND cnl.ID = art.REF_ID
    AND art.REF_TYPE = 'CREDIT_NOTE'
LEFT JOIN
    PRODUCTS prodAdj
ON
    ((
            prodAdj.CENTER = invl.PRODUCTCENTER
            AND prodAdj.ID = invl.PRODUCTID)
        OR (
            prodAdj.CENTER = cnl.PRODUCTCENTER
            AND prodAdj.ID = cnl.PRODUCTID))
    AND prodAdj.PRODUCT_ACCOUNT_CONFIG_ID = 601
WHERE
    prod.GLOBALID IN ('PT_RENT_1000'
                    ,'PT_RENT_400'
                    ,'PT_RENT_500'
                    ,'PT_RENT_600'
                    ,'PT_RENT_700'
                    ,'PT_RENT_800')
    AND prodAdj.CENTER IS NOT NULL
ORDER BY
    s.OWNER_CENTER
  ,s.OWNER_ID
  ,s.CENTER
  ,s.id
  ,art.TRANS_TIME