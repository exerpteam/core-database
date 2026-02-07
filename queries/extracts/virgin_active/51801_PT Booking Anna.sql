 SELECT
     p.CENTER || 'p' || p.ID AS "Person ID",
     p.CENTER AS "Club",
     p.LASTNAME || ', ' || p.FIRSTNAME AS "Full Name",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "Member Status",
     pr.NAME AS "Membership Type",
     s.CENTER||'ss'||s.ID AS "ID Subscription",
     cc_prod.NAME AS "ClipCard Name",
     TO_CHAR(LongtodateC(i.ENTRY_TIME,i.CENTER),'YYYY-MM-DD') AS "Sales Date",
     TO_CHAR(LongtodateC(cc.VALID_FROM,cc.CENTER),'YYYY-MM-DD') AS "Cut Date",
     TO_CHAR(LongtodateC(cc.VALID_UNTIL,cc.CENTER),'YYYY-MM-DD') AS "Stop Date",
     cc.CLIPS_LEFT AS "Clips Left",
         cc_prod.PRICE
 FROM
     CLIPCARDS cc
 JOIN
     INVOICE_LINES_MT invl
 ON
     invl.CENTER = cc.INVOICELINE_CENTER
     AND invl.ID = cc.INVOICELINE_ID
     AND invl.SUBID = cc.INVOICELINE_SUBID
 JOIN
     INVOICES i
 ON
     invl.CENTER = i.CENTER
     AND invl.ID = i.ID
 JOIN
     PERSONS p
 ON
     p.CENTER= cc.OWNER_CENTER
     AND p.ID = cc.OWNER_ID
 JOIN
     PRODUCTS cc_prod
 ON
     cc_prod.CENTER = cc.CENTER
     AND cc_prod.ID = cc.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
     AND s.STATE in (2,4,8)
 JOIN
     PRODUCTS pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 WHERE
     cc.CENTER IN (:scope)
     AND i.ENTRY_TIME BETWEEN :FromDate AND :EndDate + 24*3600*1000
