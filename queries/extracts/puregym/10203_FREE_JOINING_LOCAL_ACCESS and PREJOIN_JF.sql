-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     c.name,
     CASE MAX(CASE pr.GLOBALID WHEN 'PREJOIN_JF' THEN 1 ELSE 0 END) WHEN 1 THEN 'yes' ELSE 'no' END                 AS PREJOIN_JF,
     CASE  MAX(CASE pr.GLOBALID WHEN 'FREE_JOINING_LOCAL_ACCESS' THEN 1 ELSE 0 END) WHEN 1 THEN 'yes' ELSE 'no' END AS FREE_JOINING_LOCAL_ACCESS
 FROM
     CENTERS c
 JOIN
     PRODUCTS pr
 ON
     pr.center = c.id
     AND pr.GLOBALID IN ('PREJOIN_JF',
                         'FREE_JOINING_LOCAL_ACCESS')
     AND pr.BLOCKED = 0
 GROUP BY
     c.name
