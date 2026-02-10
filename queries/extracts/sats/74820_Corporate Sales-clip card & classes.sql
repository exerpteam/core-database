-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4125
https://clublead.atlassian.net/browse/ES-12237
 WITH
     params AS materialized
     (
         SELECT
  cast(datetolongC(TO_CHAR(CURRENT_DATE-30,'yyyy-MM-dd hh24:mi'),c.id) as bigint) AS from_date,
  cast(datetolongC(TO_CHAR(CURRENT_DATE,'yyyy-MM-dd hh24:mi'),c.id) as bigint) AS to_date,
             c.id
         FROM
             centers c
     )
 SELECT
     DISTINCT
     longtodateC(art.ENTRY_TIME, art.center) AS "Sales Date",
     c.NAME                                  AS "Center Name",
     c.id                                    AS "Center ID",
     csales_person.FULLNAME                  AS "Sales Person Name",
     staff.center||'emp'||staff.id           AS "Sales person ID",
     p.FULLNAME                              AS "Company name",
     p.center||'p'||p.id                     AS "Company ID",
     pr.NAME                                 AS "Product",
     il.QUANTITY                             AS "Quantity",
     il.TOTAL_AMOUNT                         AS "Sales Amount",
     CASE  WHEN cnl.center IS NULL THEN '' ELSE 'Credited' END   AS "Is Credited",
     cnl.TOTAL_AMOUNT                        AS "Credited Amount"
 FROM
     PRODUCT_GROUP pg
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgl
 ON
     pgl.PRODUCT_GROUP_ID = pg.ID
 JOIN
     PRODUCTS pr
 ON
     pgl.PRODUCT_CENTER = pr.CENTER
     AND pgl.PRODUCT_ID = pr.ID
 JOIN
     INVOICE_LINES_MT il
 ON
     il.PRODUCTCENTER = pr.CENTER
     AND il.PRODUCTID = pr.ID
 JOIN
     params
 ON
     params.id = il.center
 JOIN
     INVOICES inv
 ON
     inv.CENTER = il.CENTER
     AND inv.ID = il.ID
 JOIN
     AR_TRANS art
 ON
     inv.CENTER = art.REF_CENTER
     AND inv.ID = art.REF_ID
     AND art.REF_TYPE = 'INVOICE'
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = art.CENTER
     AND ar.ID = art.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = ar.CUSTOMERCENTER
     AND p.ID = ar.CUSTOMERID
 JOIN
     centers c
 ON
     c.id = il.center
 LEFT JOIN
     EMPLOYEES staff
 ON
     staff.center = inv.EMPLOYEE_CENTER
     AND staff.id = inv.EMPLOYEE_ID
 LEFT JOIN
     PERSONS sales_person
 ON
     sales_person.center = staff.personcenter
     AND sales_person.ID = staff.personid
 LEFT JOIN
     PERSONS csales_person
 ON
     csales_person.center = sales_person.TRANSFERS_CURRENT_PRS_CENTER
     AND csales_person.ID = sales_person.TRANSFERS_CURRENT_PRS_ID
 LEFT JOIN
     CREDIT_NOTE_LINES cnl
 ON
     cnl.INVOICELINE_CENTER = il.center
     AND cnl.INVOICELINE_ID = il.id
     AND cnl.INVOICELINE_SUBID = il.SUBID
 WHERE
     pg.NAME IN ('Föreläsningar + Tilläggspriser',
                 'Klasser + Tilläggspriser',
                 'Friskvårdspaket',
                 'Friskvårdspaketen',
                 'Rehab',
                 'Corporate ST-4125')
     AND p.SEX = 'C'
     AND il.center IN ($$scope$$)
   and   art.ENTRY_TIME >= from_date and art.ENTRY_TIME <= to_date
 --order by  art.ENTRY_TIME
