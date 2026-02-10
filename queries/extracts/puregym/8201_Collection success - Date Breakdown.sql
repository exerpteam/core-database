-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     pr.REQ_DATE,
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
             THEN 1
             ELSE 0
         END) AS "Submitted",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 3
             THEN 1
             ELSE 0
         END) AS "Paid",
     CASE
         WHEN SUM (
                 CASE
                     WHEN pr.state = 3
                     THEN 1
                     ELSE 0
                 END)<> 0
         THEN TO_CHAR(SUM(
                 CASE
                     WHEN pr.state = 3
                     THEN 1
                     ELSE 0
                 END) * CAST(100 AS DECIMAL(9,2))  / count(*), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Success ratio"
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     CLEARING_OUT clo
 ON
     pr.REQ_DELIVERY = clo.ID
 LEFT JOIN
     INVOICELINES il
 ON
     il.center = pr.COLL_FEE_INVLINE_CENTER
     AND il.id = pr.COLL_FEE_INVLINE_ID
     AND il.subid = pr.COLL_FEE_INVLINE_SUBID
 WHERE
     pr.REQ_DATE >= $$FromDate$$
     AND pr.req_date <= $$ToDate$$
     AND pr.REQUEST_TYPE = 1
     and pr.CENTER in ($$scope$$)
 GROUP BY
     pr.REQ_DATE
 ORDER BY
     pr.REQ_DATE
