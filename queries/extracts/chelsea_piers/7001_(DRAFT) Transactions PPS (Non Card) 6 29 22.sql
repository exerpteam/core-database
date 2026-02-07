SELECT 
  t."PPS Transaction ID / Reference",
  t."Transaction Date",
  t."Center",
  t."Amount",
  string_agg(t."Aggr. Transaction ID",';') AS "Aggr. Transaction ID",
  t."Entry Time",
  t."Invoice",
  t."Owner ID",
  t."Person External ID",
  t."Payment Type",
  t."Payer ID"
FROM
(
WITH
    params AS materialized
    (
        SELECT
            c.id                                                                          AS center,
	    CAST(datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) AS FROM_DATE,
            CAST(datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS')+1,'YYYY-MM-DD HH24:MI:SS'), c.id)-1 AS BIGINT) AS TO_DATE
        FROM
            centers c
    )
SELECT DISTINCT
    crt.coment        AS "PPS Transaction ID / Reference", 
    to_char(longtodateC(crt.transtime,crt.center),'MM/DD/YYYY') AS "Transaction Date",
    crt.center AS "Center",
    crt.amount AS "Amount",
    CASE WHEN act.aggregated_transaction_center IS NOT NULL 
    THEN act.aggregated_transaction_center || 'agt' || act.aggregated_transaction_id
    ELSE null
    END AS "Aggr. Transaction ID",
    to_char(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS "Entry Time",
    i.center||'inv'||i.id AS "Invoice",
    il.person_center||'p'||il.person_id AS "Owner ID",
    p.external_id   AS "Person External ID",
    CASE WHEN crt.CRTTYPE = 1 THEN 'CASH' WHEN CRTTYPE = 2 THEN 'CHANGE' WHEN CRTTYPE = 3 THEN 'RETURN ON CREDIT' WHEN CRTTYPE = 4 THEN 'PAYOUT CASH' WHEN CRTTYPE = 5 THEN 'PAID BY CASH AR ACCOUNT' WHEN CRTTYPE = 6 THEN 'DEBIT CARD' WHEN CRTTYPE = 7 THEN 'CREDIT CARD' WHEN CRTTYPE = 8 THEN 'DEBIT OR CREDIT CARD' WHEN CRTTYPE = 9 THEN 'GIFT CARD' WHEN CRTTYPE = 10 THEN 'CASH ADJUSTMENT' WHEN CRTTYPE = 11 THEN 'CASH TRANSFER' WHEN CRTTYPE = 12 THEN 'PAYMENT AR' WHEN CRTTYPE = 13 THEN 'CONFIG PAYMENT METHOD' WHEN CRTTYPE = 14 THEN 'CASH REGISTER PAYOUT' WHEN CRTTYPE = 15 THEN 'CREDIT CARD ADJUSTMENT' WHEN CRTTYPE = 16 THEN 'CLOSING CASH ADJUST' WHEN CRTTYPE = 17 THEN 'VOUCHER' WHEN CRTTYPE = 18 THEN 'PAYOUT CREDIT CARD' WHEN CRTTYPE = 19 THEN 'TRANSFER BETWEEN REGISTERS' WHEN CRTTYPE = 20 THEN 'CLOSING CREDIT CARD ADJ' WHEN CRTTYPE = 21 THEN 'TRANSFER BACK CASH COINS' WHEN CRTTYPE = 22 THEN 'INSTALLMENT PLAN' WHEN CRTTYPE = 100 THEN 'INITIAL CASH' WHEN CRTTYPE = 101 THEN 'MANUAL' ELSE 'Undefined' 
    END AS "Payment Type",
    i.payer_center||'p'||i.payer_id AS "Payer ID"
FROM
    CASHREGISTERTRANSACTIONS crt    
JOIN
    PARAMS
ON 
    params.center =  crt.center
JOIN
    CASHREGISTERS cr
ON
    cr.center = crt.center 
    AND cr.id = crt.id
    AND cr.type = 'WEB'
LEFT JOIN
    invoices i
ON
    crt.PAYSESSIONID = i.PAYSESSIONID    
LEFT JOIN     
    invoice_lines_mt il
ON
    i.center = il.center
    AND i.id = il.id    
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = il.ACCOUNT_TRANS_CENTER
    AND act.ID = il.ACCOUNT_TRANS_ID
    AND act.SUBID = il.ACCOUNT_TRANS_SUBID     
LEFT JOIN
    persons p
ON
    il.person_center = p.center          
    AND il.person_id = p.id    
WHERE
  crt.coment is not null
  AND crt.CENTER in ($$Scope$$) 
  AND crt.transtime between params.FROM_DATE AND params.TO_DATE 
  AND crt.crttype = 13 
  ) t
GROUP BY 
 t."PPS Transaction ID / Reference",
 t."Transaction Date",   
 t."Center",
 t."Amount",
 t."Entry Time",
 t."Invoice",
 t."Owner ID",
 t."Person External ID",
 t."Payment Type",
 t."Payer ID"