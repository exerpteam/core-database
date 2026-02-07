 select distinct * from (
 SELECT
     TO_CHAR(ss.SALES_DATE, 'YYYY-MM-DD') salesdate,
     owner.CENTER || 'p' || owner.ID personId,
     owner.FULLNAME,
     prod.NAME MEMBERSHIP,
     ss.PRICE_NEW joining_fee,
         invl.TOTAL_AMOUNT admin_fee,
     CASE
         WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1
         THEN (COALESCE(ss.PRICE_INITIAL, 0) + COALESCE(ss.PRICE_PRORATA, 0))
         ELSE 0
     END PRO_RATA,
     case when position('HOUSHOLD' in upper(prod.name))!=0 OR position('HOUSE HOLD' in upper(prod.name))!=0 then 0
     else
     COALESCE(notice.notice_amount, 0)
     end NOTICE_DAYS,
     CASE
         WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0
         THEN (COALESCE(ss.PRICE_INITIAL, 0) + COALESCE(ss.PRICE_PRORATA, 0))
         ELSE 0
     END PREPAID,
     COALESCE(ss.PRICE_NEW, 0) + COALESCE(ss.PRICE_INITIAL, 0) + COALESCE(ss.PRICE_PRORATA, 0) + COALESCE(notice.notice_amount, 0) + COALESCE(invl.TOTAL_AMOUNT,0)
     TOTAL_CASH,
     TO_CHAR(ss.START_DATE, 'YYYY-MM-DD') startdate,
     staff.FULLNAME staff
 FROM
     SUBSCRIPTION_SALES ss
 JOIN SUBSCRIPTIONS su
 ON
     ss.SUBSCRIPTION_CENTER = su.CENTER
     AND ss.SUBSCRIPTION_ID = su.ID
 left join INVOICELINES invl on invl.CENTER = su.INVOICELINE_CENTER and invl.ID = su.INVOICELINE_ID and invl.SUBID = su.ADMINFEE_INVOICELINE_SUBID
 JOIN PRODUCTS prod
 ON
     prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
     AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
 JOIN PERSONS owner
 ON
     su.OWNER_CENTER = owner.CENTER
     AND su.OWNER_ID = owner.ID
 LEFT JOIN
     (
         SELECT
             il.CENTER,
             il.ID,
             il.TOTAL_AMOUNT notice_amount
         FROM
             INVOICELINES il
         JOIN INVOICES i
         ON
             i.CENTER = il.CENTER
             AND i.ID = il.ID
         JOIN PRODUCTS pr
         ON
             pr.CENTER = il.PRODUCTCENTER
             AND pr.ID = il.PRODUCTID
         WHERE
             i.CENTER = :Center
             AND i.TRANS_TIME >= :FromDate
             AND i.TRANS_TIME < :ToDate + (1000*60*60*24) 
             AND pr.GLOBALID = '30_DAY_NOTICE'
     )
     notice
 ON
     su.INVOICELINE_CENTER = notice.CENTER
     AND su.INVOICELINE_ID = notice.ID
 LEFT JOIN EMPLOYEES emp
 ON
     ss.EMPLOYEE_CENTER = emp.CENTER
     AND ss.EMPLOYEE_ID = emp.ID
 JOIN PERSONS staff
 ON
     emp.PERSONCENTER = staff.CENTER
     AND emp.PERSONID = staff.ID
 WHERE
     owner.CENTER = :Center
     AND ss.SALES_DATE >= longtodateTZ(:FromDate, 'Europe/London')
     AND ss.SALES_DATE <= longtodateTZ(:ToDate, 'Europe/London')
     AND EXISTS
     (
         SELECT
             1
         FROM
             PRODUCT_AND_PRODUCT_GROUP_LINK pgl
         JOIN PRODUCT_GROUP pg
         ON
             pg.ID = pgl.PRODUCT_GROUP_ID
         WHERE
             pgl.PRODUCT_CENTER = prod.CENTER
             AND pgl.PRODUCT_ID = prod.ID
             AND pg.NAME = 'Commission Reporting'
     )
 ORDER BY
     ss.SALES_DATE,
     owner.CENTER,
     owner.ID
 ) t1
