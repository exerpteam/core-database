 WITH
     params AS
     (
         SELECT
             /*+ materialize */
 
              CAST(extract(epoch FROM timezone('Europe/Rome', CAST($$FromDate$$ AS timestamptz))) AS bigint)*1000 AS FROMDATE, 
              CAST(extract(epoch from timezone('Europe/Rome', CAST($$ToDate$$ AS timestamptz))) AS bigint)*1000 AS TODATE
         
     )
 SELECT
     club.external_id                                               AS "Club",
     TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD')      AS "Date",
     CASE sales.total_amount  WHEN 0 THEN  0  ELSE 1 END                            AS "Causale",
     credit.external_id                                             AS "AX code",
     sales.quantity                                                 AS "Quantity",
     sales.total_amount                                             AS "Amount",
     sales.vat_amount                                               AS "Taxable",
     sales.net_amount                                               AS "VAT",
     prod.external_id                                               AS "Item number"
 FROM
     SALES_VW sales
 CROSS JOIN
     PARAMS
 JOIN
     CENTERS club
 ON
     sales.CENTER = club.ID
 JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = sales.ACCOUNT_TRANS_CENTER
     AND act.ID = sales.ACCOUNT_TRANS_ID
     AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
 JOIN
     ACCOUNTS credit
 ON
     credit.CENTER = act.CREDIT_ACCOUNTCENTER
     AND credit.ID = act.CREDIT_ACCOUNTID
 JOIN
     PRODUCTS prod
 ON
     prod.center = sales.PRODUCT_CENTER
     AND prod.id = sales.PRODUCT_ID
 WHERE
     sales.product_type = 'RETAIL'
     AND sales.sales_type = 'INVOICE'
     AND sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME <= PARAMS.TODATE
     AND sales.center in ($$Scope$$)
 UNION ALL
 SELECT
     club.external_id                                               AS "Club",
     TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD')      AS "Date",
     CASE sales.total_amount  WHEN 0 THEN  0  ELSE 1 END                            AS "Causale",
     debit.external_id                                              AS "AX code",
     sales.quantity                                                 AS "Quantity",
     sales.total_amount                                             AS "Amount",
     sales.vat_amount                                               AS "Taxable",
     sales.net_amount                                               AS "VAT",
     prod.external_id                                               AS "Item number"
 FROM
     SALES_VW sales
 CROSS JOIN
     PARAMS
 JOIN
     CENTERS club
 ON
     sales.CENTER = club.ID
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
     PRODUCTS prod
 ON
     prod.center = sales.PRODUCT_CENTER
     AND prod.id = sales.PRODUCT_ID
 WHERE
     sales.product_type = 'RETAIL'
     AND sales.sales_type = 'CREDIT_NOTE'
     AND sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME <= PARAMS.TODATE
     AND sales.center in ($$Scope$$)
