-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         t2.PERSONID,
         t2.BILLED_UNTIL_DATE,
         t2.SUB_START_DATE,
         t2.SUB_END_DATE,
         t2.PRODUCT_NAME,
         t2.PRODUCT_GLOBALID,
         t2.SPP_FROM_DATE,
         t2.SPP_TO_DATE,
         t2.INVOICE_DAYS,
         t2.INV_TOTAL_AMOUNT,
                 t2.CREDIT_PERIOD_START,
                 t2.CREDIT_PERIOD_END,
                 ROUND(t2.DAILY_PRICE, 2) AS DAILY_PRICE,
                 t2.CREDIT_DAYS,
                 ROUND(t2.DAILY_PRICE * t2.CREDIT_DAYS, 2) AS CREDIT_AMOUNT,
         t2.BOOK_DATE,
         'PartialCreditnote ' || t2.PRODUCT_NAME ||': ' || t2.CREDIT_PERIOD_START || ' - '|| t2.CREDIT_PERIOD_END AS CREDIT_NOTE_TEXT
 FROM
 (
         SELECT
                 t1.*,
                 t1.INV_TOTAL_AMOUNT / t1.INVOICE_DAYS AS DAILY_PRICE,
                 t1.CREDIT_PERIOD_END - t1.CREDIT_PERIOD_START + 1 AS CREDIT_DAYS
         FROM
         (
                 WITH
                         params AS
                         (
                                 SELECT
                                         /*+ materialize */
                                         c.id                               AS CENTER_ID,
                                         :FromDate AS FROM_DATE,
                                         :ToDate AS TO_DATE,
                                         TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') AS TODAYS_DATE
                                 FROM
                                         CENTERS c
                                 WHERE
                                         c.COUNTRY = 'GB'
                                                                                 AND c.ID IN (:Scope)
                         )
                 SELECT
                         s.OWNER_CENTER || 'p' || s.OWNER_ID AS PERSONID,
                         s.BILLED_UNTIL_DATE,
                         s.START_DATE AS SUB_START_DATE,
                         s.END_DATE AS SUB_END_DATE,
                         pr.NAME AS PRODUCT_NAME,
                         pr.GLOBALID AS PRODUCT_GLOBALID,
                         spp.FROM_DATE AS SPP_FROM_DATE,
                         spp.TO_DATE AS SPP_TO_DATE,
                         spp.TO_DATE - spp.FROM_DATE +1 AS INVOICE_DAYS,
                         il.TOTAL_AMOUNT AS INV_TOTAL_AMOUNT,
                         GREATEST(spp.FROM_DATE, params.FROM_DATE) AS CREDIT_PERIOD_START,
                         LEAST(spp.TO_DATE, params.TO_DATE) AS CREDIT_PERIOD_END,
                         params.TODAYS_DATE AS BOOK_DATE
                 FROM SUBSCRIPTIONS s
                 JOIN params
                         ON params.CENTER_ID = s.CENTER
                 JOIN SUBSCRIPTIONTYPES st
                         ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID AND st.ST_TYPE = 1
                 JOIN SUBSCRIPTIONPERIODPARTS spp
                         ON spp.CENTER = s.CENTER AND spp.ID = s.ID AND spp.FROM_DATE <= params.TO_DATE AND spp.TO_DATE >= params.FROM_DATE AND spp.SPP_STATE = 1
                 JOIN SPP_INVOICELINES_LINK spplink
                         ON spplink.PERIOD_CENTER = spp.CENTER AND spplink.PERIOD_ID = spp.ID AND spplink.PERIOD_SUBID = spp.SUBID
                 JOIN INVOICE_LINES_MT il
                         ON il.CENTER = spplink.INVOICELINE_CENTER AND il.ID = spplink.INVOICELINE_ID AND il.SUBID = spplink.INVOICELINE_SUBID
                 JOIN PRODUCTS pr
                         ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID
                                 WHERE
                                         pr.PTYPE = 13
                                         AND il.TOTAL_AMOUNT != 0
         ) t1
 ) t2
