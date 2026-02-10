-- The extract is extracted from Exerp on 2026-02-08
--  
 select
 MAX(c.ID) as CENTERID, p.EXTERNAL_ID
 FROM PRODUCTS p
 INNER JOIN
 CENTERS C
 on p.CENTER = c.ID
 WHERE c.COUNTRY = 'IT'
 GROUP BY p.EXTERNAL_ID
