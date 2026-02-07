select
                      CONCAT(CONCAT(cast(p1.CENTER as char(3)),'p'), cast(p1.ID as varchar(8))) as personId
         , CASE
                      WHEN pr.CLEARINGHOUSE_ID IN (803,
                               2801,
                               2802,
                               2803,
                               2804)
                                 THEN '99'
                                 ELSE '02'
           END as PAYMENT_METHOD
         , c.EXTERNAL_ID
         , agr.TEXT
         , CASE
                      WHEN art3.ID IS NULL
                                 THEN prs.OPEN_AMOUNT
                                 ELSE art3.AMOUNT
           END                         as OPEN_AMOUNT
         , pr.REQ_DATE                 AS DUE_DATE
         , longtodate(art1.ENTRY_TIME) as BOOK_DATE
         , vat.EXTERNAL_ID             AS VAT_TYPE
         , vat.RATE                    AS VAT_RATE
FROM
           PERSONS p1
           JOIN
                      ACCOUNT_RECEIVABLES ar
                      on
                                 ar.CUSTOMERCENTER = p1.CENTER
                                 AND ar.CUSTOMERID = p1.ID
                                 AND ar.AR_TYPE    = 4
           LEFT JOIN
                      PAYMENT_ACCOUNTS pac
                      ON
                                 pac.CENTER = ar.CENTER
                                 AND pac.ID = ar.ID
           LEFT JOIN
                      PAYMENT_REQUESTS pr
                      ON
                                 pr.CENTER = ar.CENTER
                                 AND pr.ID = ar.id
           LEFT JOIN
                      PAYMENT_REQUEST_SPECIFICATIONS prs
                      ON
                                 pr.INV_COLL_CENTER    = prs.CENTER
                                 AND pr.INV_COLL_ID    = prs.ID
                                 AND pr.INV_COLL_SUBID = prs.SUBID
           LEFT JOIN
                      AR_TRANS art
                      ON
                                 art.PAYREQ_SPEC_SUBID      = prs.SUBID
                                 and art.PAYREQ_SPEC_ID     = prs.ID
                                 and art.PAYREQ_SPEC_CENTER = prs.CENTER
           LEFT JOIN
                      AR_TRANS art1
                      ON
                                 art1.PAYREQ_SPEC_SUBID      = prs.SUBID
                                 and art1.PAYREQ_SPEC_ID     = prs.ID
                                 and art1.PAYREQ_SPEC_CENTER = prs.CENTER
                                 and art1.DUE_DATE IS NOT NULL
                                 and art1.REF_TYPE           = 'ACCOUNT_TRANS'
           LEFT JOIN
                      AR_TRANS ART2
                      on
                                 Art1.CENTER                 = ART2.center
                                 and Art1.ID                 = ART2.ID
                                 AND art1.PAYREQ_SPEC_SUBID  = ART2.PAYREQ_SPEC_SUBID
                                 and art1.DUE_DATE IS NOT NULL
                                 AND ART2.INFO     IS NOT NULL
           LEFT JOIN
                      AR_TRANS ART3
                      on
                                 Art2.CENTER      = ART3.center
                                 and Art2.ID      = ART3.ID
                                 and Art2.INFO    = art3.INFO
                                 and art3.AMOUNT  > 0
                                 and art3.TEXT LIKE 'Transfer to cash collection account%'
           LEFT JOIN
                      ACCOUNT_TRANS act
                      ON
                                 act.CENTER    = art1.REF_CENTER
                                 AND act.ID    = art1.REF_ID
                                 AND act.SUBID = art1.REF_SUBID
           LEFT JOIN
                      AGGREGATED_TRANSACTIONS agr
                      ON
                                 agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
                                 AND agr.ID = act.AGGREGATED_TRANSACTION_ID
           LEFT JOIN
                      INVOICELINES invl
                      on
                                 invl.ID         = art.REF_ID
                                 AND invl.CENTER = art.REF_CENTER
           INNER JOIN
                      CENTERS c
                      ON
                                 C.ID = PR.CENTER
           LEFT JOIN
                      ACCOUNT_TRANS act1
                      ON
                                 act1.CENTER    = invl.VAT_ACC_TRANS_CENTER
                                 AND act1.ID    = invl.VAT_ACC_TRANS_ID
                                 AND act1.SUBID = invl.VAT_ACC_TRANS_SUBID
           LEFT JOIN
                      VAT_TYPES vat
                      ON
                                 vat.CENTER = act1.VAT_TYPE_CENTER
                                 AND vat.ID = act1.VAT_TYPE_ID
WHERE
           c.country                           = 'IT'
           and Extract(MONTH FROM pr.REQ_DATE) = Extract(MONTH FROM(ADD_MONTHS(SYSDATE,-1)))
           and Extract(YEAR FROM pr.REQ_DATE)  = Extract(YEAR FROM(ADD_MONTHS(SYSDATE,-1)))
           and extract(day from pr.req_date)  <= 2
           AND pr.STATE              IS NOT NULL
           AND ART.REF_TYPE                    = 'INVOICE'
           AND PR.STATE IN (3, 5, 12, 17)
           AND
           (
                      ART3.SUBID IS NOT NULL
                      OR OPEN_AMOUNT       > 0
           )
           AND art1.ID IS NOT NULL
GROUP BY
           p1.CENTER
         , P1.ID
         , pr.CLEARINGHOUSE_ID
         , CASE
                      WHEN pr.CLEARINGHOUSE_ID IN (803,
                               2801,
                               2802,
                               2803,
                               2804)
                                 THEN '99'
                                 ELSE '02'
           END
         , agr.TEXT
         , pr.REQ_DATE
         , longtodate(art1.ENTRY_TIME)
         , vat.EXTERNAL_ID
         , vat.RATE
         , c.EXTERNAL_ID
         , CASE
                      WHEN art3.ID IS NULL
                                 THEN prs.OPEN_AMOUNT
                                 ELSE art3.AMOUNT
           END