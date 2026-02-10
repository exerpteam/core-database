-- The extract is extracted from Exerp on 2026-02-08
--  
 select
         CONCAT(CONCAT(cast(p1.CENTER as char(3)), 'p'), cast(p1.ID as varchar(8))) as personId,
         CASE
                 WHEN
                 --pr.CLEARINGHOUSE_ID = 803 THEN '98'
                 pr.CLEARINGHOUSE_ID IN (803,
                                                                 2801,
                                                                 2802,
                                                                 2803,
                                                                 2804) THEN '98'
                 ELSE '02'
         END as PAYMENT_METHOD,
         c.EXTERNAL_ID,
         CASE
                 WHEN prs.OPEN_AMOUNT > 0 THEN prs.REQUESTED_AMOUNT - prs.OPEN_AMOUNT
                 ELSE prs.REQUESTED_AMOUNT
         END AS AMOUNT,
         pr.REQ_DATE as scadenza,
         vat.EXTERNAL_ID,
         vat.RATE,
         TRUNC(CURRENT_TIMESTAMP,
         'DAY') AS IMPORTDATE
 FROM
         PERSONS p1
 JOIN ACCOUNT_RECEIVABLES ar on
         ar.CUSTOMERCENTER = p1.CENTER
         AND ar.CUSTOMERID = p1.ID
         AND ar.AR_TYPE = 4
 LEFT JOIN PAYMENT_ACCOUNTS pac ON
         pac.CENTER = ar.CENTER
         AND pac.ID = ar.ID
 LEFT JOIN PAYMENT_REQUESTS pr ON
         pr.CENTER = ar.CENTER
         AND pr.ID = ar.id
 LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs ON
         pr.INV_COLL_CENTER = prs.CENTER
         AND pr.INV_COLL_ID = prs.ID
         AND pr.INV_COLL_SUBID = prs.SUBID
 LEFT JOIN AR_TRANS art ON
         art.PAYREQ_SPEC_SUBID = prs.SUBID
         and art.PAYREQ_SPEC_ID = prs.ID
         and art.PAYREQ_SPEC_CENTER = prs.CENTER
 LEFT JOIN AR_TRANS ART3 on
         Art.CENTER = ART3.center
         and Art.ID = ART3.ID
         and art3.SUBID > art.SUBID
         and art3.AMOUNT > 0
         and art3.TEXT NOT LIKE 'Automatic%'
         and art3.TEXT NOT LIKE 'Transfer to%'
         and art3.REF_TYPE = 'ACCOUNT_TRANS'
 LEFT JOIN INVOICELINES invl on
         invl.ID = art.REF_ID
         AND invl.CENTER = art.REF_CENTER
 INNER JOIN CENTERS c ON
         C.ID = PR.CENTER
 LEFT JOIN ACCOUNT_TRANS act ON
         act.CENTER = art3.REF_CENTER
         AND act.ID = art3.REF_ID
         AND act.SUBID = art3.REF_SUBID
 LEFT JOIN AGGREGATED_TRANSACTIONS agr ON
         agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
         AND agr.ID = act.AGGREGATED_TRANSACTION_ID
 LEFT JOIN ACCOUNT_TRANS act1 ON
         act1.CENTER = invl.VAT_ACC_TRANS_CENTER
         AND act1.ID = invl.VAT_ACC_TRANS_ID
         AND act1.SUBID = invl.VAT_ACC_TRANS_SUBID
 LEFT JOIN VAT_TYPES vat ON
         vat.CENTER = act1.VAT_TYPE_CENTER
         AND vat.ID = act1.VAT_TYPE_ID
 LEFT JOIN CENTERS c2 ON
         c2.ID = P1.CENTER
 where
         c.COUNTRY = 'IT'
         --pr.center = 102
         and ((pr.req_date > TO_DATE('30/09/2016',
         'dd/mm/YYYY')
         --AND pr.CLEARINGHOUSE_ID != 803)
         AND pr.CLEARINGHOUSE_ID NOT IN (803,
         2801,
         2802,
         2803,
         2804))
         OR
         --(pr.CLEARINGHOUSE_ID = 803
 (pr.CLEARINGHOUSE_ID IN (803,
         2801,
         2802,
         2803,
         2804)
         AND pr.req_date > TO_DATE('31/12/2016',
         'dd/mm/YYYY')))
         and pr.req_date <= add_months(date_trunc('month', NOW() + interval '1 month') - interval '1 day',-2)
         and extract(DAY
 FROM
         pr.req_date) <= 2
         --and art1.PAYREQ_SPEC_CENTER = select c.ID from CENTERS c where  c.COUNTRY = 'IT' and art1.PAYREQ_SPEC_ID = 21020  and art1.PAYREQ_SPEC_SUBID = 2
         and Extract(MONTH
 FROM
         (longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(MONTH
 FROM
         (ADD_MONTHS(CURRENT_TIMESTAMP,
         -1)))
         and Extract(YEAR
 FROM
         (longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = Extract(YEAR
 FROM
         (ADD_MONTHS(CURRENT_TIMESTAMP,
         -1)))
         and Extract(MONTH
 FROM
         (longtodate(art3.ENTRY_TIME))) = Extract(MONTH
 FROM
         (ADD_MONTHS(CURRENT_TIMESTAMP,
         -1)))
         and Extract(YEAR
 FROM
         (longtodate(art3.ENTRY_TIME))) = Extract(YEAR
 FROM
         (ADD_MONTHS(CURRENT_TIMESTAMP,
         -1)))
         AND pr.STATE IS NOT NULL
         AND ART.REF_TYPE = 'INVOICE'
         AND OPEN_AMOUNT < REQUESTED_AMOUNT
 group by
         p1.center,
         p1.id,
         prs.OPEN_AMOUNT,
         prs.REQUESTED_AMOUNT,
         --pr.CLEARINGHOUSE_ID,
  CASE
                 WHEN
                         --pr.CLEARINGHOUSE_ID = 803 THEN '98'
                         pr.CLEARINGHOUSE_ID IN (803,
                                                                 2801,
                                                                 2802,
                                                                 2803,
                                                                 2804) THEN '98'
                 ELSE '02'
         END,
         c.EXTERNAL_ID,
         prs.OPEN_AMOUNT,
         pr.REQ_DATE,
         prs.LAST_MODIFIED,
         vat.EXTERNAL_ID,
         vat.RATE
