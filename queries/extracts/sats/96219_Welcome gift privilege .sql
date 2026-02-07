  (WITH params AS MATERIALIZED
                (SELECT
                                TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS fromDate,
                                dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '12 days','YYYY-MM-DD'), c.id) AS toDate,
                                c.id
                        FROM CENTERS c
)
select
case when p.external_id is not null
then 'True'
else 'Null'end as "priviledge available"

from persons p

join params
on p.center = params.id

join subscriptions s
on s.owner_center = p.center
and s.owner_id = p.id

JOIN
                                     SUBSCRIPTIONTYPES st
                                 ON
                                     s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                                     AND s.SUBSCRIPTIONTYPE_ID = st.ID
                                 JOIN
                                     PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                                 ON
                                     ppg.PRODUCT_CENTER = st.CENTER
                                     AND ppg.PRODUCT_ID = st.ID
                                 AND ppg.PRODUCT_GROUP_ID = 74203


where
( fromdate - s.start_date BETWEEN 0 AND 10) 

and p.external_id = (:externalid) 
and s.start_date > '2024-08-11'
and s.state in (2,4)and not exists (select
1

from invoice_lines_mt il

join invoices i
on
il.center = i.center
and
il.id = i.id

join persons p2
on
p2.center = il.person_center
and
p2.id = il.person_id

join products pr
on
il.productcenter = pr.center
and
il.productid = pr.id


where
pr.globalid in ('PREMIUM_WELCOME_GIFT','WELCOME_GIFT_PREMIUM')
and longtodate(entry_time) > s.start_date
and p.center = p2.center
and p.id = p2.id 
))