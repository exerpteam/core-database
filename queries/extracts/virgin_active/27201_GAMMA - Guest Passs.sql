-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     i.PAYER_CENTER || 'p' || i.PAYER_ID AS "Member ID",
     TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS "Using Date/Time",
     TO_CHAR(longtodate(i.ENTRY_TIME), 'YYYY-MM-DD') AS "Sale Date",
     p.GLOBALID AS "Guest Pass ID"
 FROM
     invoice_lines_mt il
 JOIN
     INVOICES i
 ON
     il.center = i.center AND il.id = i.id
 JOIN
     PRODUCTS p
 ON
     p.CENTER = il.PRODUCTCENTER AND p.id = il.PRODUCTID
 JOIN
     PERSONS per
 ON
     per.center = il.PERSON_CENTER  AND per.id = il.PERSON_ID
 JOIN CENTERS c
 ON c.ID = p.CENTER
 WHERE
     p.GLOBALID like '%GUEST%'
     AND per.STATUS = 0
     AND c.COUNTRY = 'IT'
     AND TRUNC(longtodate(i.TRANS_TIME)) = TRUNC(CURRENT_TIMESTAMP) -1
