-- The extract is extracted from Exerp on 2026-02-08
--  
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
    , s.subscription_price, 
c_price.price, 
n_price.price, 
n_price.from_date,
case 
when default_pa.state = 1 then 'Created'
when default_pa.state = 2 then 'Sent'
when default_pa.state = 4 then 'OK'
else 'Other'
end as PaymentAgreementState


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

-- current subscription_price entry
join goodlife.subscription_price c_price on c_price.subscription_center = s.center and c_price.subscription_id = s.id and c_price.cancelled = 0 
and c_price.from_date <= greatest(longtodateC(FLOOR(extract(epoch FROM now())*1000),s.center) , s.start_date)
and (c_price.to_date is null or c_price.to_date > longtodateC(FLOOR(extract(epoch FROM now())*1000),s.center))
-- get next price
left join goodlife.subscription_price n_price on n_price.subscription_center = c_price.subscription_center and  n_price.subscription_id = c_price.subscription_id and n_price.cancelled = 0 and c_price.to_date is not null and n_price.from_date = c_price.to_date + 1

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
JOIN
    account_receivables ar
ON
    ss.owner_center = ar.customercenter
AND ss.owner_id = ar.customerid
AND ar.ar_type = 4
JOIN
    payment_accounts pac
ON
    ar.center = pac.center
AND ar.id = pac.id
JOIN
    payment_agreements default_pa
ON
    pac.active_agr_center = default_pa.center
AND pac.active_agr_id = default_pa.id
AND pac.active_agr_subid = default_pa.subid

JOIN goodlife.payment_cycle_config pcc on default_pa.payment_cycle_config_id = pcc.id


LEFT JOIN
    relatives r
ON
    r.relativecenter = pe.center
AND r.relativeid =pe.id
AND r.rtype = 12
AND r.status < 3 -- TODO check
    --find other product to filter by.
    -- TODO think about TRANSFER

LEFT JOIN (
SELECT i.payer_center as pe_center, i.payer_id as pe_id, max(i.entry_time) as LastPurchaseTime from
    invoices i

JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id

JOIN
    products pd
ON
    pd.CENTER = il.productCENTER
AND pd.ID = il.productid
--AND pd.globalid = 'GOODS_FB_AQUAFINA1L'
AND pd.globalid = 'MANITOBA_ENROLMENT_INSTALLMENT'

LEFT JOIN goodlife.credit_note_lines_mt cnl on cnl.invoiceline_center = il.center and cnl.invoiceline_id = il.id and cnl.invoiceline_subid = il.subid

WHERE i.entry_time > (FLOOR(extract(epoch FROM now())*1000) - 365*24*3600*1000.0) -- Looking at sales 180 days in the past, could leave this, or add parameter to look x far back
and cnl.center is null
GROUP BY i.payer_center, i.payer_id
) last_purchase

ON last_purchase.pe_center = pe.center and last_purchase.pe_id = pe.id
AND last_purchase.LastPurchaseTime >= datetolongC(TO_CHAR(s_sales.start_date,'YYYY-MM-DD HH24:MI'), s.center)


WHERE
    ss.price_new > 0
AND st.st_type IN (1)
AND s.state IN (2,4,8)
    --AND s.sub_state IN (1,2,3,4,5,6,9)
AND r.center IS NULL -- exclude members with other payer
AND last_purchase.pe_center is null
--AND i.center is null AND il.center is null AND pd.center IS NULL -- exclude those who have bought the MANITOBA_ENROLMENT_INSTALLMENT product
AND s_sales.start_date < (now() - interval '9 days') 
--AND s_sales.start_date < (now()) 
AND ss.sales_date > (now() - interval '180 days') -- Should be the same value as line 131 "i.entry time clause"
-- exclude case of subscription with price increase from 0 in the future
AND (s.subscription_price > 0 or (n_price.price is not null and n_price.price > 0 and (n_price.from_date - interval '1 day' * 
(
-- delay if price change is not aligned with payment cycle
case 
when (pcc.interval_type = 2 and extract( DAY from n_price.from_date) >= individual_deduction_day ) then ( (extract( DAY from n_price.from_date) - individual_deduction_day)) 
when (pcc.interval_type = 2 and extract( DAY from n_price.from_date) < individual_deduction_day ) then (30 + extract( DAY from n_price.from_date) - individual_deduction_day)
when (pcc.interval_type = 0 and (MOD(n_price.from_date - to_date('1970-08-10','YYYY-MM-DD'),14) + 1) >= individual_deduction_day ) then ( ((MOD(n_price.from_date - to_date('1970-08-10','YYYY-MM-DD'),14) + 1) - individual_deduction_day)) 
when (pcc.interval_type = 0 and (MOD(n_price.from_date - to_date('1970-08-10','YYYY-MM-DD'),14) + 1) < individual_deduction_day ) then (14 + (MOD(n_price.from_date - to_date('1970-08-10','YYYY-MM-DD'),14) + 1) - individual_deduction_day)
else 0 end
+ 6
)) < now()  ))  

--AND ss.subscription_center IN    (SELECT id FROM centers JOIN zipcodes z ON z.country = c.country AND z.city = c.city AND z.zipcode = c.zipcode WHERE z.province = 'MB')
AND s.center IN ($$scope$$)
    -- Keep only subscriptions which are using the default payment agreement
AND ((
            s.payment_agreement_center IS NOT NULL
        AND default_pa.center = s.payment_agreement_center
        AND default_pa.id = s.payment_agreement_id
        AND default_pa.subid = s.payment_agreement_subid)
    OR  (
            s.payment_agreement_center IS NULL) )


