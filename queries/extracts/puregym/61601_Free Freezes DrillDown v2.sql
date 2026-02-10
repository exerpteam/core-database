-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-10965
 SELECT
   DISTINCT
     cen.NAME              AS CENTERNAME,
     p.CENTER ||'p'|| p.ID AS PREF,
     p.FULLNAME            AS Customer_Name,
     p.EXTERNAL_ID         AS External_ID,
     CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 
     'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
     pro.NAME                                                        AS Subscription_Name,
     s.SUBSCRIPTION_PRICE                                            AS Subscription_Price,
     sfp.START_DATE                                                  AS Freeze_Start_Date,
     sfp.END_DATE                                                    AS Freeze_End_Date,
     sfp.TYPE                                                        AS Freeze_Type,
     pemp.FULLNAME                                                   AS Employee_Name,
     COALESCE(inv.TOTAL_AMOUNT,0)                                                                                     AS Freeze_Amount,
     TO_CHAR(longtodateC(sfp.ENTRY_TIME, sfp.SUBSCRIPTION_CENTER),'YYYY/MM/DD HH24:MI')       AS Freeze_Create_Date,
     CASE
         WHEN rpa.id IS NOT NULL
         THEN rpa.individual_deduction_day
         ELSE pa.individual_deduction_day
     END             AS "Deduction day"
 FROM
     SUBSCRIPTION_FREEZE_PERIOD sfp
 JOIN
     SUBSCRIPTIONS s
 ON
     sfp.SUBSCRIPTION_CENTER = s.center
 AND sfp.SUBSCRIPTION_ID = s.id
 AND s.STATE = 4
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = st.ID
 JOIN
     (
         SELECT
             sfp2.SUBSCRIPTION_CENTER,
             sfp2.SUBSCRIPTION_ID,
             MAX(sfp2.START_DATE) START_DATE
         FROM
             SUBSCRIPTION_FREEZE_PERIOD sfp2
         WHERE
             sfp2.STATE <> 'CANCELLED'
             AND sfp2.START_DATE <= current_date
             AND sfp2.END_DATE+1 >= current_date
         GROUP BY
             sfp2.SUBSCRIPTION_CENTER,
             sfp2.SUBSCRIPTION_ID
     ) current_freeze
 ON
     current_freeze.SUBSCRIPTION_CENTER = sfp.SUBSCRIPTION_CENTER
         AND current_freeze.SUBSCRIPTION_ID = sfp.SUBSCRIPTION_ID
         AND sfp.START_DATE = current_freeze.START_DATE
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
 AND p.id = s.OWNER_ID
 LEFT JOIN
     CENTERS cen
 ON
     cen.ID = s.OWNER_CENTER
 LEFT JOIN
     PRODUCTS pro
 ON
     pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER
 AND pro.ID = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     EMPLOYEES emp
 ON
     emp.CENTER= sfp.EMPLOYEE_CENTER
 AND emp.ID = sfp.EMPLOYEE_ID
 LEFT JOIN
     PERSONS pemp
 ON
     pemp.CENTER = emp.PERSONCENTER
 AND pemp.ID = emp.PERSONID
 LEFT JOIN
 (SELECT il.total_amount, i.ENTRY_TIME, il.PRODUCTCENTER, il.PRODUCTID, il.PERSON_CENTER, il.PERSON_ID, i.TRANS_TIME, i.PAYER_CENTER, i.PAYER_ID
     FROM
         INVOICE_LINES_MT il
      JOIN
         INVOICES i
       ON
         il.CENTER = i.CENTER
         AND i.ID = il.ID
 ) inv
 ON
         inv.PRODUCTCENTER = st.FREEZEPERIODPRODUCT_CENTER
         AND inv.PRODUCTID = st.FREEZEPERIODPRODUCT_ID
         AND inv.PERSON_CENTER = s.OWNER_CENTER
     AND inv.PERSON_ID = s.OWNER_ID
     AND datetolong(TO_CHAR(current_freeze.START_DATE,'YYYY-MM-DD HH24:MI')) <= inv.TRANS_TIME + 6*60*60*1000
     AND datetolong(TO_CHAR(current_freeze.START_DATE,'YYYY-MM-DD HH24:MI')) >= inv.TRANS_TIME - 6*60*60*1000
 /* Adding DD Date  */
 LEFT JOIN
     account_receivables ar
 ON
     ar.customercenter = p.center
     AND ar.customerid = p.id
     AND ar.ar_type = 4
 LEFT JOIN
     payment_accounts pac
 ON
     pac.center = ar.center
     AND pac.id = ar.id
 LEFT JOIN
     payment_agreements pa
 ON
     pa.center = pac.active_agr_center
     AND pa.id = pac.active_agr_id
     AND pa.subid = pac.active_agr_subid
 LEFT JOIN
     relatives r
 ON
     r.relativecenter = s.owner_center
     AND r.relativeid = s.owner_id
     AND r.rtype = 12
     AND r.status = 1
 LEFT JOIN
     account_receivables rar
 ON
     rar.customercenter = r.center
     AND rar.customerid = r.id
     AND rar.ar_type = 4
 LEFT JOIN
     payment_accounts rpac
 ON
     rpac.center = rar.center
     AND rpac.id = rar.id
 LEFT JOIN
     payment_agreements rpa
 ON
     rpa.center = rpac.active_agr_center
     AND rpa.id = rpac.active_agr_id
     AND rpa.subid = rpac.active_agr_subid
 WHERE
     sfp.STATE = 'ACTIVE'
 AND s.OWNER_CENTER IN (:center)
