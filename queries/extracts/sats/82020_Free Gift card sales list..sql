-- The extract is extracted from Exerp on 2026-02-08
-- Used to see how many free gift cards that have been added and by who. 
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             c.id                                                      center_id,
             datetolongC(TO_CHAR(cast($$sales_from_date$$ as date), 'YYYY-MM-DD HH24:MI'), c.ID)                 AS FromDate,
             datetolongC(TO_CHAR(cast($$sales_to_date$$ as date), 'YYYY-MM-DD HH24:MI'), c.ID) + 24*60*60*1000 AS ToDate
         FROM
             CENTERS c
     )
 SELECT
     prod.name "Giftcard Name",
     gc.amount                                                      AS "Gift Card Amount",
     e.ref_center || 'gc' || e.ref_id                               AS "Gift Card Id",
     gc.payer_center || 'p' || gc.payer_id                          AS "Member ID",
     payer.fullname                                                 AS "Member Name",
     e.ASSIGN_EMPLOYEE_CENTER||'emp'||e.ASSIGN_EMPLOYEE_ID          AS "Sales employee ID",
     empName.fullName                                               AS "Sales Employee Name",
     e.identity                                                     AS "Gift Card Voucher",
     TO_CHAR(longtodateC(e.start_time, e.ref_center), 'YYYY-MM-DD') AS "Date Of Sale",
     TO_CHAR(longtodateC(e.start_time, e.ref_center), 'HH24:MI')    AS "Time Of Sale",
     TO_CHAR(gc.expirationdate, 'YYYY-MM-DD')                       AS "Expiry Date",
     gc.amount - gc.amount_remaining                                AS "Credit Used",
     gc.amount_remaining                                            AS "Remaining Credit",
     CASE
         WHEN current_timestamp > gc.expirationdate
             AND gc.amount_remaining > 0
         THEN 'Expried'
         WHEN gc.amount_remaining = 0
         THEN 'Finished'
         WHEN current_timestamp < gc.expirationdate
             AND gc.amount_remaining = gc.amount
         THEN 'Unused'
         WHEN current_timestamp < gc.expirationdate
             AND gc.amount_remaining != gc.amount
         THEN 'Used'
         ELSE 'Unknown'
     END AS "Gift Card Status"
 FROM
     entityidentifiers e
 JOIN
     params
 ON
     params.center_id =e.ref_center
 JOIN
     gift_cards gc
 ON
     gc.center = e.ref_center
 AND gc.id = e.ref_id
 JOIN
     products prod
 ON
     prod.center= gc.product_center
 AND prod.id=gc.product_id
 AND prod.ptype= 9 -- free gift card
 JOIN
     persons payer
 ON
     payer.center = gc.payer_center
 AND payer.id = gc.payer_id
 JOIN
     employees emp
 ON
     e.ASSIGN_EMPLOYEE_CENTER = emp.center
 AND e.ASSIGN_EMPLOYEE_ID = emp.id
 JOIN
     persons empName
 ON
     emp.personcenter = empName.center
 AND emp.personid = empName.id
 WHERE
     e.ref_type = 5
 AND e.start_time >= params.FromDate
 AND e.start_time <= params.ToDate
 AND params.center_id IN ($$Scope$$)
