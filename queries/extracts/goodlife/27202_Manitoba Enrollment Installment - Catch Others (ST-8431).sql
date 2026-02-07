SELECT distinct
    pe.center||'p'||pe.id AS memberid,
    pe.fullname,
    s.center,
    c.name AS CenterName,
    p.name AS subscriptionName,
    s.center ||'ss'||s.id as subscriptionID,
    CASE
        WHEN s.state =1
        THEN 'Awaiting activation (Deprecated)'
        WHEN s.state = 2
        THEN 'Active'
        WHEN s.state = 3
        THEN 'Ended'
        WHEN s.state = 4
        THEN 'Frozen'
        WHEN s.state = 5
        THEN 'Cancelled'
        WHEN s.state = 6
        THEN 'Not paid'
        WHEN s.state = 7
        THEN 'Window'
        WHEN s.state = 8
        THEN 'Created'
        WHEN s.state = 8
        THEN 'Ended transferred'
        WHEN s.state = 9
        THEN 'Created transferred'
        ELSE 'unknown'
    END                                   AS subscriptionStatus ,
    longtodateC(s_Sales.creation_time,s_sales.center) AS creationtime,
    TO_CHAR(s_sales.start_date,'MM-DD-YYYY')    AS salesSubscriptionStart,
    TO_CHAR(s.start_date,'MM-DD-YYYY')    AS currentSubscriptionStart,
    ss.price_new                          AS firstEnrollmentPrice 
    --,*
FROM
    subscription_sales ss
JOIN
    subscriptions s_sales
ON
    ss.subscription_center = s_sales.center
AND ss.subscription_id = s_sales.id

JOIN
    subscriptions s
ON
        (
    (
    -- subscription not changed (the subscription at the time of the sale is not ended)
    s_sales.state in (2,4,8) and s.center = s_sales.center AND s.id = s_sales.id)
    OR (
    -- the s_sales subscroiption has been changed to another one, we join to this one
    s_sales.changed_to_center is not null and s.center = s_sales.changed_to_center AND s.id = s_sales.changed_to_id)
    )



JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    products p
ON
    p.center = st.center
AND p.id = st.id
JOIN
    persons pe
ON
    pe.center = ss.owner_center
AND pe.id = ss.owner_id
JOIN
    centers c
ON
    s.center = c.id

LEFT JOIN (
SELECT i.payer_center as pe_center, i.payer_id as pe_id, max(i.entry_time) as LastPurchaseTime from
    invoices i

JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id
-- TODO: exclude credited invoice lines ?
JOIN
    products pd
ON
    pd.CENTER = il.productCENTER
AND pd.ID = il.productid
--AND pd.globalid = 'GOODS_FB_AQUAFINA1L'
AND pd.globalid = 'MANITOBA_ENROLMENT_INSTALLMENT'

AND i.entry_time > (FLOOR(extract(epoch FROM now())*1000) - 60*24*3600*1000.0)
GROUP BY i.payer_center, i.payer_id
) last_purchase

ON last_purchase.pe_center = pe.center and last_purchase.pe_id = pe.id
AND last_purchase.LastPurchaseTime >= datetolongC(TO_CHAR(s_sales.start_date,'YYYY-MM-DD HH24:MI'), s.center)


WHERE
    ss.price_new > 0
AND st.st_type IN (1)
AND s.state IN (2,3,4,8)
AND last_purchase.pe_center is null
--AND i.center is null AND il.center is null AND pd.center IS NULL -- exclude those who have bought the MANITOBA_ENROLMENT_INSTALLMENT product
AND ss.sales_date >= (now() - interval '65 days') 
AND ss.sales_date < (now() - interval '9 days') 
AND s.center IN ($$scope$$)
    -- ONLY INCLUDE THOSE RENEWED TODAY OR YESTERDAY
AND EXISTS
    (
        SELECT
            1
        FROM
            subscriptionperiodparts spp
        WHERE
            spp.center = s.center
        AND spp.id = s.id
        AND spp.from_date > s_sales.start_date + (case when st.periodunit = 0 then 13 else 27 end)
        -- and (s.billed_until_date - spp.from_date + 1) > (case when st.periodunit = 0 then 13 else 27 end)
        
        AND spp.spp_state = 1
        AND spp.spp_type IN (1,2,7,3)
        AND spp.entry_time > (FLOOR(extract(epoch FROM now())*1000) - 2*24*3600*1000.0) )
    -- EXCLUDE subscriptions with a subscirption period part linked to an invoiceline / ar_trans
    -- that has been collected with a due date after the sub start date
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptionperiodparts spp
        JOIN
            spp_invoicelines_link sil
        ON
            sil.period_center = spp.center
        AND sil.period_id = spp.id
        AND sil.period_subid = spp.subid
        JOIN
            ar_trans art
        ON
            art.ref_type = 'INVOICE'
        AND art.ref_center = sil.invoiceline_center
        AND art.ref_id = sil.invoiceline_id
        WHERE
            spp.center = s.center
        AND spp.id = s.id
        AND spp.from_date > s_sales.start_date
        AND spp.spp_state = 1
        AND art.collected = 1
        AND art.due_date IS NOT NULL
        AND art.due_date > s_sales.start_date)        
        ;
        