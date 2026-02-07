 SELECT
     pr.REQ_DELIVERY                                          AS "Sent File ID",
     arc.CUSTOMERCENTER||'p'||arc.CUSTOMERID                  AS MemberID,
     cc.CENTER||'cc'||cc.ID||'id'||cc.SUBID                   AS "PT clip cardID",
     c.NAME                                                   AS "Sold in club",
     prd.NAME                                                 AS "Product name",
     TO_CHAR(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') AS "Sales date",
     ip.AMOUNT                                                AS "Amount",
     ip.INSTALLEMENTS_COUNT                                   AS "Number of installments",
     pr.REQ_DATE,
     ROUND(ip.AMOUNT / ip.INSTALLEMENTS_COUNT,2) AS "single installment price"
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr.INV_COLL_CENTER = prs.center
     AND pr.INV_COLL_ID = prs.id
     AND pr.INV_COLL_SUBID = prs.subid
 JOIN
     ar_trans ar
 ON
     prs.center = ar.payreq_spec_center
     AND prs.id = ar.payreq_spec_id
     AND prs.subid = ar.payreq_spec_subid
     AND ar.COLLECTED = 1
     AND ar.REF_TYPE IN ('INVOICE')
 JOIN
     ACCOUNT_RECEIVABLES arc
 ON
     pr.center = arc.center
     AND pr.id = arc.id
 JOIN
     invoices inv
 ON
     ar.ref_center = inv.center
     AND ar.ref_id = inv.id
     AND ar.REF_TYPE = 'INVOICE'
 JOIN
     invoicelines invl
 ON
     inv.center = invl.center
     AND inv.id = invl.id
 JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     inv.PAYSESSIONID = crt.PAYSESSIONID
 JOIN
     INSTALLMENT_PLANS ip
 ON
     ip.ID = crt.INSTALLMENT_PLAN_ID
 JOIN
     CLIPCARDS cc
 ON
     cc.INVOICELINE_CENTER = invl.CENTER
     AND cc.INVOICELINE_ID = invl.id
     AND cc.INVOICELINE_SUBID = invl.SUBID
 JOIN
     CENTERS c
 ON
     inv.CENTER = c.ID
 JOIN
     PRODUCTS prd
 ON
     invl.PRODUCTCENTER = prd.CENTER
     AND invl.PRODUCTID = prd.ID
 WHERE
     pr.REQ_DATE BETWEEN $$from_date$$ AND $$to_date$$ and pr.CENTER in ($$scope$$)
