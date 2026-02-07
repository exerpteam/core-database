SELECT
   "Member ID",
   "External ID",
   "Member Name",
   "Subscription Start Date",
   CASE
       WHEN dat2.START_DATE < '2023-09-06'
           THEN "Initial_AMF"
       WHEN dat2.START_DATE >= '2023-09-06'
           AND dat2.START_DATE < '2024-08-23'
               THEN "Initial_AMF_AFTER1SEP23"
       WHEN dat2.START_DATE >= '2024-08-23'
           THEN "Initial_AMF_AFTER_AUGUST_2024"
               ELSE "Initial_AMF"
   END AS "Initial_AMF",
   "Last_Sale_Date",
   CASE
       WHEN "Last_Sale_Date" IS NULL
           AND dat2.START_DATE < '2023-09-06'
               THEN "Initial_AMF"
       WHEN "Last_Sale_Date" IS NULL
           AND dat2.START_DATE >= '2023-09-06'
           AND dat2.START_DATE < '2024-08-23'
               THEN "Initial_AMF_AFTER1SEP23"
       WHEN "Last_Sale_Date" IS NULL
           AND dat2.START_DATE >= '2024-08-23'
               THEN "Initial_AMF_AFTER_AUGUST_2024"
       WHEN add_months("Last_Sale_Date",12) >= "Initial_AMF"
           THEN add_months("Last_Sale_Date",12)
               ELSE "Initial_AMF"
   END AS "Next_Deduction_Date",
   coalesce (pea_price, amf.PRICE) AS PRICE

FROM
   (
       SELECT DISTINCT
           p.center||'p'||p.id                                     AS "Member ID",
           p.center,
           p.external_id                                           AS "External ID",
           p.fullname                                              AS "Member Name",
           MIN(sub.START_DATE)                                     AS "Subscription Start Date",
           MIN(sub.START_DATE) + 86                                AS "Initial_AMF",
           MIN(sub.START_DATE) + 41                                AS "Initial_AMF_AFTER1SEP23",
           MIN(sub.START_DATE) + 12                                AS "Initial_AMF_AFTER_AUGUST_2024",
           CAST(longtodate(MAX(latest_sale.TRANS_TIME)) AS date)   AS "Last_Sale_Date",
           pea.txtvalue::numeric                                   AS "pea_price",
           sub.START_DATE

       FROM
           PERSONS p
       JOIN 
           SUBSCRIPTIONS sub
       ON
           sub.OWNER_CENTER = p.center
           AND sub.OWNER_ID = p.id
           AND sub.REFMAIN_CENTER IS NULL
           AND sub.state IN (2,4,8)
           -- AND sub.START_DATE <= :deduction_date
           AND (sub.END_DATE IS NULL OR sub.END_DATE > sub.billed_until_date)
       JOIN
           SUBSCRIPTIONTYPES st
       ON
           st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
           AND st.id = sub.SUBSCRIPTIONTYPE_ID
           AND st.ST_TYPE = 1  -- EFT
           AND st.IS_ADDON_SUBSCRIPTION = 0
       JOIN
           products pr
       ON
           pr.center = st.center
           AND pr.id = st.id
       LEFT JOIN
           person_ext_attrs pea
       ON
           p.center = pea.personcenter
           AND p.id = pea.personid
           AND pea.name = 'AMFPRICE'
       LEFT JOIN
           (
               SELECT
                   ptrans.CURRENT_PERSON_CENTER,
                   ptrans.CURRENT_PERSON_ID,
                   MAX(i.TRANS_TIME) AS TRANS_TIME
                   FROM
                       INVOICE_LINES_MT il
                   JOIN
                       INVOICES i
                   ON
                       i.center = il.center
                       AND i.id = il.id
                   JOIN
                       PRODUCTS pd
                   ON
                       pd.CENTER = il.productCENTER
                       AND pd.ID = il.productid
                   JOIN
                       PERSONS ptrans
                   ON
                       il.PERSON_CENTER = ptrans.center
                       AND il.person_id = ptrans.id
                   WHERE
                       pd.GLOBALID = 'ANNUAL_MAINTENANCE_FEE'  
                   GROUP BY
                       ptrans.CURRENT_PERSON_CENTER,
                       ptrans.CURRENT_PERSON_ID
           ) latest_sale
           ON
               (latest_sale.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
               AND latest_sale.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID)
		LEFT JOIN
		    PERSON_EXT_ATTRS pe
		ON
			pe.PERSONCENTER = p.CURRENT_PERSON_CENTER
			AND pe.PERSONID = p.CURRENT_PERSON_ID
			AND pe.NAME = 'noAMF'
       WHERE
           p.center in (:center)
           -- p.center||'p'||p.id = '535p14828'
           AND p.PERSONTYPE NOT IN (2, 3, 6)
           AND (pe.TXTVALUE IS NULL OR pe.TXTVALUE = 'false')
       GROUP BY
           p.center,
           p.id,
           pea.txtvalue,
           sub.START_DATE) dat2
LEFT JOIN
  PRODUCTS amf
ON 
  amf.GLOBALID = 'ANNUAL_MAINTENANCE_FEE' AND amf.CENTER = dat2.center

WHERE
   (
       dat2."Last_Sale_Date" IS NULL
   OR  add_months(dat2."Last_Sale_Date", 12) <= $$deduction_date$$ )
AND ( (
           dat2."Initial_AMF" <= $$deduction_date$$
       AND dat2.START_DATE < '2023-09-06' )
   OR  (
           dat2."Initial_AMF_AFTER1SEP23" <= $$deduction_date$$
       AND dat2.START_DATE >= '2023-09-06'
       AND dat2.START_DATE < '2024-08-23' )
   OR  (
           dat2."Initial_AMF_AFTER_AUGUST_2024" <= $$deduction_date$$
       AND dat2.START_DATE >= '2024-08-23' ) )