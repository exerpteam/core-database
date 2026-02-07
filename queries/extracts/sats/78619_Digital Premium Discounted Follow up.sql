With params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            datetolongC(TO_CHAR(:FromDate, 'YYYY-MM-dd HH24:MI'), c.id)                     AS FromDate,
            datetolongC(TO_CHAR(:ToDate, 'YYYY-MM-dd HH24:MI'), c.id) + (24*60*60*1000)-1 AS ToDate
        FROM
            centers c
    

)
Select
t2.pid as "member number",
t2.from_date as "From Date",
t2.to_date as "To date",
t2.amount_per_month as "Price per month",
sum(t2.freezedays) as "Freeze days",
t2.freeorfreeze as "Free or Freeze"

from
(
select 
t1.pid,
t1.period_for_price_from as from_date,
t1.period_for_price_to as to_date,
t1.days,
t1.subscription_price as amount_per_month,
t1.freezedays,
t1.freeorfreeze 

from
(
SELECT distinct
    longToDate(inv.TRANS_TIME) trans_time,
    p.CENTER || 'p' || p.ID pid,
    sp.PRICE as subscription_price,
    sp.from_date as period_for_price_from,
    sp.to_date as period_for_price_to,
    s.start_date as startdate_sub,
    s.end_date as enddate_sub,
    case
    when sp.to_date is NULL and s.end_date is NULL
    then trunc(sp.from_date-sysdate-2)*-1
    when sp.to_date is NULL and s.end_date is not NULL
    then trunc(sp.from_date-s.end_date-2)*-1
    else trunc(sp.from_date-sp.to_date)*-1 end as days,
    s.center,
    s.id,
    trunc(srp.start_date-srp.end_date-2)*-1 as freezedays,
    srp.TYPE as freeorfreeze
    
FROM
    SATS.PRIVILEGE_USAGES pu
JOIN SATS.PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
JOIN INVOICE_LINES_MT invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
   -- AND invl.SUBID = pu.TARGET_SUBID
cross join params     
JOIN SATS.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
join invoices inv
on
inv.center = invl.center
and
inv.id = invl.id
join subscriptions s
on

s.INVOICELINE_CENTER = invl.center
and s.INVOICELINE_ID = invl.id
and s.INVOICELINE_SUBID = invl.subid
and s.sub_state not in (8)

join SUBSCRIPTION_PRICE sp
on 
s.center = sp.SUBSCRIPTION_CENTER
and
s.id = sp.SUBSCRIPTION_ID
and sp.type != 'TRANSFER'

JOIN PERSONS p
ON
    p.CENTER = invl.PERSON_CENTER
    AND p.ID = invl.PERSON_ID
left join SUBSCRIPTION_REDUCED_PERIOD srp
on   
srp.SUBSCRIPTION_CENTER = s.center
and
srp.SUBSCRIPTION_ID = s.id  

LEFT JOIN INVOICE_LINES_MT invl2
ON
    invl.PRODUCTCENTER = invl2.PRODUCTCENTER
    AND invl.PRODUCTID = invl2.PRODUCTID
    and invl.PERSON_CENTER = invl2.PERSON_CENTER
    and invl.PERSON_ID = invl2.PERSON_ID
  -- and invl.id != invl2.id
 --  and invl.center != invl2.center 
left join invoices inv2
on
inv2.center = invl2.center
and
inv2.id = invl2.id 

    
WHERE
    pg.GRANTER_SERVICE = 'StartupCampaign'
    AND pg.GRANTER_ID =
    (
        SELECT
            stc.ID
        FROM
            STARTUP_CAMPAIGN stc
        WHERE
            stc.name = :campaignName
    )
    AND pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.STATE <> 'CANCELLED'
    and pu.target_start_time >= params.FromDate and pu.target_start_time <= params.ToDate
    and s.start_date between :FromDate and :ToDate
    and p.center in (:scope)
)t1   
)t2
group by
t2.pid,
t2.from_date,
t2.to_date,
t2.days,
t2.amount_per_month,
t2.freezedays,
t2.freeorfreeze 