 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$ToDate$$ + (1000*60*60*24)             AS TODATE,
             longToDate($$ToDate$$ + (1000*60*60*24) ) AS TODATE_DATE
         
     )
 SELECT
     sales.SALES_TYPE,
     cMember.SHORTNAME HOME_CENTRE,
         CASE
             WHEN cRebook.SHORTNAME IS NOT NULL
             THEN cRebook.SHORTNAME
             ELSE cSales.SHORTNAME
         END PT_CENTRE,
     sales.PRODUCT_NAME,
     sales.PRODUCT_GROUP_NAME,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription'  WHEN 13 THEN  'Subscription add-on' END PT_TYPE,
     sales.PRODUCT_TYPE                                                                                                                                                                                                        PT_TYPE_2,
     TO_CHAR( SUM(sales.TOTAL_AMOUNT ), 'FM999999999999,9990.09' )                                                                                                                                                                       Year_to_date_Revenue,
     TO_CHAR( SUM(sales.NET_AMOUNT), 'FM999999999999,9990.09' )                                                                                                                                                                          Year_to_date_Revenue_excl_vat ,
     SUM(sales.QUANTITY)                                                                                                                                                                                                        year_to_date_count,
     TO_CHAR(SUM(
         CASE
             WHEN sales.TRANS_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(PARAMS.TODATE_DATE-1,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(PARAMS.TODATE_DATE, 'YYYY-MM-dd HH24:MI'))
             THEN sales.TOTAL_AMOUNT
             ELSE 0
         END), 'FM999999999999,9990.09' ) Month_to_date_Revenue,
     TO_CHAR(SUM(
         CASE
             WHEN sales.TRANS_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(PARAMS.TODATE_DATE-1,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(PARAMS.TODATE_DATE, 'YYYY-MM-dd HH24:MI'))
             THEN sales.NET_AMOUNT
             ELSE 0
         END), 'FM999999999999,9990.09' ) Month_to_date_Revenue_excl_vat,
     SUM(
         CASE
             WHEN sales.TRANS_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(PARAMS.TODATE_DATE-1,'MM'), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(PARAMS.TODATE_DATE, 'YYYY-MM-dd HH24:MI'))
             THEN 1 * sales.QUANTITY
             ELSE 0
         END) month_to_date_count
     --    CASE
     --        WHEN cRebook.SHORTNAME IS NOT NULL
     --        THEN cRebook.SHORTNAME
     --        ELSE cSales.SHORTNAME
     --    END PT_CENTRE,
     --    prod.NAME,
     --    sales.PRODUCT_GROUP_NAME,
     --    sales.PRODUCT_TYPE,
     --    ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     --    ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     --    ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     --    SUM(sales.QUANTITY) quantity,
     --    debit.EXTERNAL_ID debit,
     --    credit.EXTERNAL_ID credit
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
     sales.TRANS_TIME >= dateToLong(TO_CHAR(TRUNC(PARAMS.TODATE_DATE,'YYYY'),'YYYY-MM-dd HH24:MI'))
     AND sales.TRANS_TIME < PARAMS.TODATE
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN ($$scope$$)))
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
     sales.SALES_TYPE,
     cMember.SHORTNAME ,
     sales.PRODUCT_NAME,
     sales.PRODUCT_GROUP_NAME,
     CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription'  WHEN 13 THEN  'Subscription add-on' END ,
     sales.PRODUCT_TYPE,
         CASE
             WHEN cRebook.SHORTNAME IS NOT NULL
             THEN cRebook.SHORTNAME
             ELSE cSales.SHORTNAME
         END
