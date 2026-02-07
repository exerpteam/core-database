 SELECT
     pr.REQ_DATE,
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
             THEN 1
             ELSE 0
         END) AS "Submitted Bounce fees",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                 AND pr.state = 3
             THEN 1
             ELSE 0
         END) AS "Paid Bounce fees",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                 AND pr.state = 3
             THEN il.TOTAL_AMOUNT
             ELSE 0
         END) AS "Paid Bounce fees total £",
     CASE
         WHEN SUM (
                 CASE
                     WHEN (COALESCE(il.TOTAL_AMOUNT,0) > 0 and pr.state = 3)
                     THEN 1
                     ELSE 0
                 END)> 0
         THEN TO_CHAR(cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                         AND pr.state = 3
                     THEN 1
                     ELSE 0
                 END) as float) * 100/ cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT,0) > 0
                     THEN 1
                     ELSE 0
                 END) as float), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Bounces success ratio" ,
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
             THEN 1
             ELSE 0
         END) AS "Submitted Free Bounce fees",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 3
             THEN 1
             ELSE 0
         END) AS "Paid Free Bounce fees",
     CASE
         WHEN SUM (
                 CASE
                     WHEN (COALESCE(il.TOTAL_AMOUNT,0) = 0 and pr.state = 3)
                     THEN 1
                     ELSE 0
                 END)<> 0
         THEN TO_CHAR(cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                         AND pr.state = 3
                     THEN 1
                     ELSE 0
                 END) as float) * 100/ cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                     THEN 1
                     ELSE 0
                 END) as float), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Free Bounces success ratio"
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
     pr.REQ_DATE >= :fromDate
     AND pr.req_date <= :toDate
     AND pr.REQUEST_TYPE = 6
     and pr.CENTER in (:scope)
 GROUP BY
     pr.REQ_DATE
 ORDER BY
     pr.REQ_DATE
