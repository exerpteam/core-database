-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4008
 SELECT
     sub.owner_center || 'p' || sub.owner_id AS PersonId,
     sub.center || 'ss' || sub.id            AS SubId,
     sales.sales_date                        AS "Sales Date",
     ar.balance                              AS "Balance Amount",
     salep.fullname                          AS "Original Sales Person Name",
     other_payer.fullname                    AS "Payer" ,
     CASE  WHEN other_payer.center is null THEN '' ELSE other_payer.center||'p'||other_payer.id END AS "PayerID"
 FROM
     SUBSCRIPTION_SALES sales
 JOIN
     SUBSCRIPTIONS sub
 ON
     sales.SUBSCRIPTION_CENTER = sub.CENTER
     AND sales.SUBSCRIPTION_ID = sub.ID
 JOIN
     invoicelines ivl
 ON
     sub.invoiceline_center = ivl.center
     AND sub.invoiceline_id = ivl.id
     AND sub.invoiceline_subid = ivl.subid
 JOIN
     invoices inv
 ON
     ivl.center = inv.center
     AND ivl.id = inv.id
 JOIN
     CASHREGISTERTRANSACTIONS CRT
 ON
     CRT.CENTER = INV.CASHREGISTER_CENTER
     AND CRT.ID = INV.CASHREGISTER_ID
     AND CRT.PAYSESSIONID = INV.PAYSESSIONID
     AND CRT.CRTTYPE = 12
 JOIN
     EMPLOYEES emp
 ON
     emp.CENTER = crt.EMPLOYEECENTER
     AND emp.ID = crt.EMPLOYEEID
 JOIN
     PERSONS salep
 ON
     salep.CENTER = emp.PERSONCENTER
     AND salep.ID = emp.PERSONID
 JOIN
     AR_TRANS ART
 ON
     ART.REF_CENTER = INV.CENTER
     AND ART.REF_ID = INV.ID
     AND ART.REF_TYPE = 'INVOICE'
     AND ART.STATUS != 'CLOSED'
     AND ART.UNSETTLED_AMOUNT < 0
 JOIN
     account_receivables ar
 ON
     ar.center = art.center
     AND ar.id = art.id
 LEFT JOIN
     RELATIVES r
 ON
     r.RELATIVECENTER = sub.owner_center
     AND r.RELATIVEID = sub.owner_id
     AND r.RTYPE = 12
     AND r.STATUS < 3
 LEFT JOIN
     PERSONS other_payer
 ON
     r.ID = other_payer.ID
     AND r.CENTER = other_payer.CENTER
 WHERE
     sub.owner_center IN ($$Scope$$)
     AND sales.sales_date BETWEEN TRUNC(CAST($$DateUpto$$ AS DATE), 'MM') AND (CAST($$DateUpto$$ AS DATE))
