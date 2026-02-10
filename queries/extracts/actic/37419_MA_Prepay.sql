-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')+7) AS DaysAhead,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID

    )

SELECT
        
per.CENTER || 'p' || per.ID AS PersonID,
per.fullname,
TO_CHAR(longToDate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS Trans_Time,
i.text,
substr(i.text,-11) AS END_DATE_PREPAY

FROM
    PERSONS per 
	
JOIN PARAMS params 
ON params.CenterID = per.center

LEFT JOIN INVOICELINES il
ON
il.PERSON_CENTER = per.center
AND il.PERSON_ID = per.id

LEFT JOIN INVOICES i
ON il.center = i.center
AND il.id = i.id


LEFT JOIN PRODUCTS prod
ON prod.center = il.PRODUCTCENTER
AND prod.id = il.PRODUCTID


LEFT JOIN
    CENTERS cen
ON
    per.center = cen.id


WHERE
    per.CENTER = :center
	AND prod.ptype = 10
	AND i.text LIKE '%Butik%'  
  
AND to_date(substr(i.text,-11),'YYYY-MM-DD') = params.DaysAhead