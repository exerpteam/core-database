-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT gc.* FROM
 GIFT_CARDS gc
 INNER JOIN
 CENTERS c
 ON  c.ID = gc.CENTER
 WHERE
 c.COUNTRY = 'IT'
 AND
 LongToDate(gc.USE_TIME) BETWEEN $$dateFrom$$ AND $$dateTo$$
