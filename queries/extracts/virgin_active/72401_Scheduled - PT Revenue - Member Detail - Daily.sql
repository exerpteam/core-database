WITH
     params AS
     (
         SELECT
             /*+ materialize */
            CAST(datetolongC(TO_CHAR(DATE_TRUNC('month', (TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day')), 'YYYY-MM-DD'), c.id) AS BIGINT) AS fromdate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT) AS todate,
            c.id AS centerid
            FROM
            centers c
            where
            c.country = 'GB'
         
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
     subs.rec_clipcard_clips,
     sales.PRODUCT_GROUP_NAME,
     sales.PRODUCT_TYPE,
     ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     SUM(sales.QUANTITY) quantity,
     debit.EXTERNAL_ID debit,
     credit.EXTERNAL_ID credit,
         pu.LAST_ACTIVE_START_DATE
 FROM
     SALES_VW sales
JOIN
     PARAMS
ON
     params.centerid = sales.center
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = sales.PRODUCT_CENTER
     AND prod.ID = sales.PRODUCT_ID
 JOIN
     CENTERS cMember
 ON
     cMember.ID = sales.PERSON_CENTER
and cmember.country = 'GB'
 JOIN
     CENTERS cSales
 ON
     cSales.ID = sales.ACCOUNT_TRANS_CENTER
 and csales.country = 'GB'
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
and crebook.country = 'GB'
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
LEFT JOIN
            SPP_INVOICELINES_LINK spil
        ON
            spil.INVOICELINE_CENTER = sales.CENTER
            AND spil.INVOICELINE_ID = sales.ID
            AND spil.INVOICELINE_SUBID = sales.SUB_ID
            AND sales.SALES_TYPE = 'INVOICE'
        LEFT JOIN
            SUBSCRIPTIONS subs
        ON
            subs.CENTER = spil.PERIOD_CENTER
            AND subs.ID = spil.PERIOD_ID
            and subs.rec_clipcard_clips is not null

 WHERE
     sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME < PARAMS.TODATE
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN (:scope))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN (:scope)))
     AND (
         debit.EXTERNAL_ID IN ('101100',
                               '101120',
                               '101105',
                               '101177')
         OR credit.EXTERNAL_ID IN ('101100',
                                   '101120',
                                   '101105',
                                   '101177') )
 GROUP BY
 pu.LAST_ACTIVE_START_DATE,
     cMember.SHORTNAME ,
     cRebook.SHORTNAME,
     cSales.SHORTNAME ,
     prod.NAME ,
     pp.FULLNAME,
     pu.FULLNAME,
     sales.PRODUCT_TYPE,
     sales.PRODUCT_GROUP_NAME,
     sales.SALES_TYPE,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID ,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID ,
     longToDate(sales.TRANS_TIME),
     debit.EXTERNAL_ID ,
     credit.EXTERNAL_ID,
     subs.rec_clipcard_clips 
