-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
    SELECT
        EXTRACT(EPOCH FROM $$FromDate$$::TIMESTAMP) * 1000 AS PeriodStart,
        (EXTRACT(EPOCH FROM $$ToDate$$::TIMESTAMP) * 1000 + 86400 * 1000) - 1 AS PeriodEnd
)
 SELECT
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID MEMBER_ID,
     pu.FULLNAME MEMBER_NAME,
     inv.PAYER_CENTER || 'p' || inv.PAYER_ID payer_id,
     pp.FULLNAME PAYER_NAME,
TO_CHAR(to_timestamp(inv.TRANS_TIME / 1000), 'HH24:MI') transaction_time,
     sales.SALES_TYPE,
     cMember.SHORTNAME HOME_CENTRE,
     CASE
         WHEN cRebook.SHORTNAME IS NOT NULL
         THEN cRebook.SHORTNAME
         ELSE cSales.SHORTNAME
     END PT_CENTRE,
     prod.NAME,
     subs.rec_clipcard_clips,
     --sales.PRODUCT_GROUP_NAME,
     prod.PTYPE,
     ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     SUM(sales.QUANTITY) quantity,
     debit.EXTERNAL_ID debit,
     credit.EXTERNAL_ID credit,
         pu.LAST_ACTIVE_START_DATE
 FROM
     INVOICE_LINES_MT sales
 CROSS JOIN
     PARAMS
 JOIN 
	 INVOICES inv
 ON
	 inv.CENTER = sales.CENTER
	 and inv.ID = sales.ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = sales.PRODUCTCENTER
     AND prod.ID = sales.PRODUCTID
 JOIN
     CENTERS cMember
 ON
     cMember.ID = sales.PERSON_CENTER
 JOIN
     CENTERS cSales
 ON
     cSales.ID = sales.ACCOUNT_TRANS_CENTER
 JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = sales.ACCOUNT_TRANS_CENTER
     AND act.ID = sales.ACCOUNT_TRANS_ID
     AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
 JOIN
     ACCOUNTS debit
 ON
     debit.CENTER = act.DEBIT_ACCOUNTCENTER
     AND debit.ID = act.DEBIT_ACCOUNTID
 JOIN
     ACCOUNTS credit
 ON
     credit.CENTER = act.CREDIT_ACCOUNTCENTER
     AND credit.ID = act.CREDIT_ACCOUNTID
 LEFT JOIN
     CENTERS cRebook
 ON
     cRebook.ID = sales.REBOOKING_TO_CENTER
 LEFT JOIN
     PERSONS pp
 ON
     pp.CENTER = inv.PAYER_CENTER
     AND pp.id = inv.PAYER_ID
 LEFT JOIN
     PERSONS pu
 ON
     pu.CENTER = sales.PERSON_CENTER
     AND pu.id = sales.PERSON_ID
LEFT JOIN
            SPP_INVOICELINES_LINK spil
        ON
            spil.INVOICELINE_CENTER = sales.CENTER
            AND spil.INVOICELINE_ID = sales.ID
            AND spil.INVOICELINE_SUBID = sales.SUBID
            AND sales.SALES_TYPE in (1,2,3,4,5,6,7,8,9)
        LEFT JOIN
            SUBSCRIPTIONS subs
        ON
            subs.CENTER = spil.PERIOD_CENTER
            AND subs.ID = spil.PERIOD_ID
            and subs.rec_clipcard_clips is not null

 WHERE
     inv.TRANS_TIME >= PARAMS.PeriodStart
     AND inv.TRANS_TIME < PARAMS.PeriodEnd
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN ($$scope$$)))
     AND (
         debit.EXTERNAL_ID IN ('1100','1110','1105','1120')
         OR credit.EXTERNAL_ID IN ('1100','1110','1105','1120') )
 GROUP BY
 pu.LAST_ACTIVE_START_DATE,
     cMember.SHORTNAME ,
     cRebook.SHORTNAME,
     cSales.SHORTNAME ,
     prod.NAME ,
     pp.FULLNAME,
     pu.FULLNAME,
     prod.PTYPE,
     --sales.PRODUCT_GROUP_NAME,
     sales.SALES_TYPE,
     inv.PAYER_CENTER || 'p' || inv.PAYER_ID ,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID ,
     longToDate(inv.TRANS_TIME),
     debit.EXTERNAL_ID ,
     credit.EXTERNAL_ID,
     subs.rec_clipcard_clips,
     inv.TRANS_TIME	 
