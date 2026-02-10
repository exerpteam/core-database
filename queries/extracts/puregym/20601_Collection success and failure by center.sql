-- The extract is extracted from Exerp on 2026-02-08
--  
 -- Parameters: scope(SCOPE),FromDate(DATE),ToDate(DATE)
 SELECT
       CASE   WHEN per_center.name IS NULL THEN  '-Total'  ELSE per_center.name END  AS "Club Name",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
             THEN 1
             ELSE 0
         END) AS "Submitted payments",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
             THEN pr.REQ_AMOUNT
             ELSE 0
         END) AS "Submitted payments amount",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 3
             THEN 1
             ELSE 0
         END) AS "Paid payments",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 3
             THEN pr.REQ_AMOUNT
             ELSE 0
         END) AS "Paid payments amount",
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
                 END) * 100.00 / count(*), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Paid payments ratio %",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 17
             THEN 1
             ELSE 0
         END) AS "Failed payments",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT,0) = 0
                 AND pr.state = 17
             THEN pr.REQ_AMOUNT
             ELSE 0
         END) AS "Failed payments amount",
     CASE
         WHEN SUM (
                 CASE
                     WHEN pr.state = 17
                     THEN 1
                     ELSE 0
                 END)<> 0
         THEN TO_CHAR(SUM(
                 CASE
                     WHEN pr.state = 17
                     THEN 1
                     ELSE 0
                 END) * 100.00 / count(*), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Failed payments ratio %"
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     CLEARING_OUT clo
 ON
     pr.REQ_DELIVERY = clo.ID
 JOIN
     centers per_center
 ON
     per_center.id = pr.center
 LEFT JOIN
     INVOICELINES il
 ON
     il.center = pr.COLL_FEE_INVLINE_CENTER
     AND il.id = pr.COLL_FEE_INVLINE_ID
     AND il.subid = pr.COLL_FEE_INVLINE_SUBID
 WHERE
     pr.REQ_DATE >= cast(:FromDate as date)
     AND pr.req_date <= cast(:ToDate as date)
     AND pr.REQUEST_TYPE = 1
     and pr.CENTER in (:scope)
 group by grouping sets ( (per_center.name),  ())
