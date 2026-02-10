-- The extract is extracted from Exerp on 2026-02-08
-- Used to highlight any GIPT sales done online
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$FromDate$$ AS FROMDATE,
             $$ToDate$$ + (1000*60*60*24) AS TODATE
         
     )
 SELECT
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID MEMBER_ID,
     pu.FULLNAME MEMBER_NAME,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID payer_id,
     pp.FULLNAME PAYER_NAME,
     TO_CHAR(longToDate(sales.TRANS_TIME), 'YYYY-MM-DD HH24:MI') transaction_time,
     sales.SALES_TYPE,
     cMember.SHORTNAME HOME_CENTRE,
     CASE
         WHEN cRebook.SHORTNAME IS NOT NULL
         THEN cRebook.SHORTNAME
         ELSE cSales.SHORTNAME
     END PT_CENTRE,
     prod.NAME,
         SALES.Employee_Center,
         SALES.Employee_ID,
     sales.PRODUCT_GROUP_NAME,
     sales.PRODUCT_TYPE,
     ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     SUM(sales.QUANTITY) quantity,
         pu.LAST_ACTIVE_START_DATE
 FROM
     SALES_VW sales
 CROSS JOIN
     PARAMS
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = sales.PRODUCT_CENTER
     AND prod.ID = sales.PRODUCT_ID
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
     pp.CENTER = sales.PAYER_CENTER
     AND pp.id = sales.PAYER_ID
 LEFT JOIN
     PERSONS pu
 ON
     pu.CENTER = sales.PERSON_CENTER
     AND pu.id = sales.PERSON_ID
 WHERE
     sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME < PARAMS.TODATE
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN ($$scope$$)))
         AND prod.GlobalID = 'GET_INTO_PT_2_SESSIONS_*NEW_ON'
         AND SALES.Employee_Center = '4'
         AND SALES.Employee_ID = '13601'
 GROUP BY
 pu.LAST_ACTIVE_START_DATE,
     cMember.SHORTNAME ,
     cRebook.SHORTNAME,
     cSales.SHORTNAME ,
     prod.NAME ,
         SALES.Employee_Center,
         SALES.Employee_ID,
     pp.FULLNAME,
     pu.FULLNAME,
     sales.PRODUCT_TYPE,
     sales.PRODUCT_GROUP_NAME,
     sales.SALES_TYPE,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID ,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID ,
     longToDate(sales.TRANS_TIME),
     debit.EXTERNAL_ID ,
     credit.EXTERNAL_ID
