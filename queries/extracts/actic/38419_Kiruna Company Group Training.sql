SELECT 
	per.CENTER ||'p'||per.ID AS "MEMBERID",
	per.FULLNAME AS "NAME",
	p.NAME AS "PRODUCT",
	il.TEXT AS "DESCRIPTION",
	LONGTODATE(inv.TRANS_TIME) AS "SALESDATE",
	comp.COMPANY_NAME as "COMPANY_NAME",
	il.TOTAL_AMOUNT AS "AMOUNT", 
	comp.SPLIT_RATE_COMMUNITY "SPLIT_RATE",
	(il.TOTAL_AMOUNT - (ROUND(il.TOTAL_AMOUNT * (1 - (1 / (1 + IL.RATE))),2))) * comp.SPLIT_RATE_COMMUNITY AS "COMMUNITY_AMOUNT",
	ROUND(IL.TOTAL_AMOUNT * (1 - (1 / (1 + IL.RATE))),2) AS "VAT",
	il.TOTAL_AMOUNT - (ROUND(il.TOTAL_AMOUNT * (1 - (1 / (1 + IL.RATE))),2)) AS "EXCL_VAT",
	comp.ADDRESS1 "ADDRESS1",
  	comp.ADDRESS2 "ADDRESS2",
  	comp.ZIPCODE "ZIPCODE",
  	comp.CITY "CITY",
	TO_CHAR(longtodate(:startDate),'YYYY-MM-DD') AS "PERIODFROM",
	TO_CHAR(longtodate(:endDate),'YYYY-MM-DD') AS "PERIODTO"
FROM INVOICELINES il
JOIN PRODUCTS p ON
	il.PRODUCTCENTER = p.CENTER
	AND il.PRODUCTID = p.ID
JOIN INVOICES inv ON
	inv.CENTER = il.CENTER
	AND inv.ID = il.ID
JOIN PERSONS per ON
	per.CENTER = inv.PAYER_CENTER
	AND per.ID = inv.PAYER_ID
JOIN
    (
        SELECT
          company.LASTNAME                      COMPANY_NAME,
          company.ADDRESS1                      ADDRESS1,
          company.ADDRESS2                      ADDRESS2,
          company.ZIPCODE                       ZIPCODE,
          company.CITY                       CITY,
          (atts.TXTVALUE)::decimal / 100 SPLIT_RATE_COMMUNITY
        FROM
            PERSONS company
        JOIN
            CENTERS c
        ON
            c.id = :center
        JOIN
            PERSON_EXT_ATTRS atts
        ON
            atts.PERSONCENTER = company.CENTER
            AND atts.PERSONID = company.ID
            AND atts.NAME = 'SPLIT_RATE_COMMUNITY'
        WHERE
            (company.LASTNAME LIKE '9' || REPLACE(lpad((:center)::varchar,3),' ','0') || ' %') or (company.LASTNAME LIKE '9' || REPLACE(lpad((:center)::varchar,4),' ','0') || ' %')) comp
ON
    1 = 1
WHERE 
	(
		p.GLOBALID = '1_CLIP_COMPANY_GROUP_TRAINING'
		OR
		p.GLOBALID = '10_CLIP_COMPANY_FITNESS'
	)
	AND inv.TRANS_TIME > :startDate
	AND inv.TRANS_TIME < :endDate + (86400000)
	AND p.CENTER = :center
