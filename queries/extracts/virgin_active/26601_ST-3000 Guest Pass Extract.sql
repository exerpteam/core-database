 SELECT
     per.EXTERNAL_ID AS "External Person ID",
     i.PAYER_CENTER || 'p' || i.PAYER_ID AS "Member ID",
     p.CENTER AS "CENTER",
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
 WHERE
     p.GLOBALID like '%GP%'
     AND per.STATUS = 0
     AND p.CENTER in (:scope)
     AND i.TRANS_TIME Between :Date_Start and :Date_End
