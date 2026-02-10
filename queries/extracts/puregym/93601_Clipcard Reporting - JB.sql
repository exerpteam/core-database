-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     per.center,
     per.id,
     clip.center clip_center,
         clip.ID as "Clip ID",
     clip.SUBID as "Clip SubID",
     par.center participation_center,
     an.name                             AS activity,
     longtodate(par.START_TIME)          AS ClassStart,
     par.state                           AS ParticipationState,
     staff.fullname                      AS Employee,
     su.person_center||'p'||su.person_id AS employee_id,
     ps.name as privilege_set,
     (CASE
          WHEN il.text IS NULL THEN
                 pr.NAME
          ELSE
                 il.text
     END) as product,
     il.total_amount / (clip.clips_initial * il.QUANTITY)    price
 FROM
     persons per
 JOIN participations par
 ON
     per.center = par.participant_center
 AND per.id = par.participant_id
 JOIN bookings bo
 ON
     par.booking_center = bo.center
 AND par.booking_id = bo.id
 JOIN activity an
 ON
     bo.activity = an.id
 LEFT JOIN STAFF_USAGE su
 ON
     su.BOOKING_CENTER = bo.CENTER
 AND su.BOOKING_ID = bo.ID
 LEFT JOIN PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
 AND staff.ID = su.PERSON_ID
 join privilege_usages pu
     on
         par.CENTER = pu.TARGET_CENTER
     AND par.ID = pu.TARGET_ID
     AND pu.TARGET_SERVICE = 'Participation'
 JOIN PRIVILEGE_GRANTS pg
     ON
         pg.ID = pu.GRANT_ID
     and pg.GRANTER_SERVICE like 'GlobalCard'
 left JOIN privilege_sets ps
     ON
     pg.PRIVILEGE_SET = ps.id
 left join clipcards clip
     on
     pu.source_center = clip.center
     and pu.source_id = clip.id
     and pu.source_subid = clip.subid
 left join (select 
    center,
    id,
    subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    text,
    product_cost,
    product_normal_price,
    total_amount,
    sales_type,
    remove_from_inventory,
    reason,
    sponsor_invoice_subid,
    person_center,
    person_id,
    installment_plan_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    sales_commission,
    sales_units,
    period_commission,
    net_amount, ( 
        select 
            l.account_trans_center
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_center, ( 
        select 
            l.account_trans_subid
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_subid, ( 
        select 
            l.account_trans_id
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_id, ( 
        select 
            l.rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as rate, ( 
        select 
            l.orig_rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as orig_rate
from 
    invoice_lines_mt line ) as il
     on
     clip.INVOICELINE_CENTER    = il.center
     and clip.INVOICELINE_ID    = il.id
     and clip.INVOICELINE_SUBID = il.subid
 left join PRODUCTS pr
     on
     clip.CENTER = pr.CENTER
     and clip.ID = pr.ID
 WHERE
     pr.globalid = 'PREMIUM_CLASSES' and
     par.state = 'PARTICIPATION'
     AND par.start_time >= (:date_from)
     AND par.start_time <= (:date_to) + 86400000
     and per.center in (:scope)
 ORDER BY
     per.center,
     per.id,
     par.START_TIME
