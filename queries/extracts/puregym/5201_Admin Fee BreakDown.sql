-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
             THEN 1
             ELSE 0
         END) AS "Submitted Admin fees",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                 AND pr3.state = 3
             THEN 1
             ELSE 0
         END) AS "Paid Admin fees",
     SUM(
         CASE
             WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                 AND pr3.state = 3
             THEN il.TOTAL_AMOUNT
             ELSE 0
         END) AS "Paid Admin fees total £",
     CASE
         WHEN SUM (
                 CASE
                     WHEN (COALESCE(il.TOTAL_AMOUNT,0) > 0
                             AND pr3.state = 3)
                     THEN 1
                     ELSE 0
                 END)> 0
         THEN TO_CHAR(cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT, 0) > 0
                         AND pr3.state = 3
                     THEN 1
                     ELSE 0
                 END) as float) * 100/ cast(SUM(
                 CASE
                     WHEN COALESCE(il.TOTAL_AMOUNT,0) > 0
                     THEN 1
                     ELSE 0
                 END) as float), 'FM999.00') || ' %'
         ELSE '0 %'
     END AS "Admins success ratio"
 FROM
     INVOICELINES il
 JOIN
     PAYMENT_REQUESTS pr
 ON
     pr.REJECT_FEE_INVLINE_CENTER = il.CENTER
     AND pr.REJECT_FEE_INVLINE_ID = il.ID
     AND pr.REJECT_FEE_INVLINE_SUBID = il.SUBID
 JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr.INV_COLL_CENTER = prs.CENTER
     AND pr.INV_COLL_ID = prs.ID
     AND pr.INV_COLL_SUBID = prs.SUBID
 JOIN
     (
         SELECT
             pr2.CENTER,
             pr2.ID,
             MAX(pr2.SUBID) SUBID,
             pr2.INV_COLL_CENTER,
             pr2.INV_COLL_ID,
             pr2.INV_COLL_SUBID
         FROM
             PAYMENT_REQUESTS pr2
         GROUP BY
             pr2.CENTER,
             pr2.ID,
             pr2.INV_COLL_CENTER,
             pr2.INV_COLL_ID,
             pr2.INV_COLL_SUBID ) pr2
 ON
     pr2.INV_COLL_CENTER =prs.CENTER
     AND pr2.INV_COLL_ID = prs.id
     AND pr2.INV_COLL_SUBID=prs.SUBID
 JOIN
     PAYMENT_REQUESTS pr3
 ON
     pr2.CENTER = pr3.CENTER
     AND pr2.ID = pr3.id
     AND pr2.SUBID = pr3.SUBID
 WHERE
     pr3.REQUEST_TYPE = 6
     AND pr3.REQ_DATE >= :fromDate
     AND pr3.req_date <= :toDate
     AND pr3.CENTER IN (:scope)
