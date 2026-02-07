 WITH
     params AS
     (
         SELECT
             /*+ materialize */
                         c.id AS center,
                           datetolongC(TO_CHAR(cast($$expirationfromdate$$ as date), 'YYYY-MM-DD HH24:MI'), c.ID)                 AS FromDate,
             datetolongC(TO_CHAR(cast($$expirationtodate$$ as date), 'YYYY-MM-DD HH24:MI'), c.ID) AS ToDate
                 FROM
                         CENTERS c
     )
 SELECT
         gc.PAYER_CENTER||'p'||gc.PAYER_ID as person,
         CASE gc.STATE  WHEN 0 THEN  'ISSUED'  WHEN 1 THEN  'CANCELLED'  WHEN 2 THEN  'EXPIRED'  WHEN 3 THEN  'USED'  WHEN 4 THEN  'PARTIAL USED' END AS "State",
         prod.name "Product",
         gc.EXPIRATIONDATE "Expiration date",
         gc.center||'gc'||gc.id AS Gift_Card_Id,
         gc.Amount,
         gc.AMOUNT_REMAINING,
     to_char(longtodateC(gc.use_time, gc.center),'YYYY-MM-DD') AS Last_Used_Date
 FROM
         GIFT_CARDS gc
 JOIN
     PARAMS
 ON
         PARAMS.center = gc.center
         JOIN
     products prod
 ON
     prod.center= gc.product_center
 AND prod.id=gc.product_id
 AND prod.ptype in (8, 9)-- Gift card,free gift card
 join persons per on gc.PAYER_CENTER||'p'||gc.PAYER_ID = per.center||'p'||per.id
 WHERE
         --gc.EXPIRATIONDATE >= PARAMS.StartDate
         --AND gc.state = 2
         --AND gc.center != 584
  params.center IN ($$Scope$$)
 and per.status not in (2,4,5,7,8)
 and datetolongC(TO_CHAR(gc.EXPIRATIONDATE, 'YYYY-MM-DD HH24:MI'), params.center) BETWEEN PARAMS.FromDate AND
     PARAMS.ToDate
