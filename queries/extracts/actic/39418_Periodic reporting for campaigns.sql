-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT

    p.center ||'p'|| p.id                                   AS MemberID,
            p.firstname || ' ' || p.middlename || ' ' || p.lastname AS CustomerName ,
            pr.name                                           AS SubscriptionName,
            s.START_DATE  AS "Start date of subscription",
            s.BINDING_END_DATE               AS "Binding end date",
            ss.PRICE_PERIOD as "normal price",        
    round((ss.CONTRACT_INCLUDING_SPONSOR/trunc(s.START_DATE - s.BINDING_END_DATE)*-30.4),2) as "calculated price per month",
    ss.CONTRACT_INCLUDING_SPONSOR as "price whole binding period"
    
FROM
    Subscriptions s
JOIN
    persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    SubscriptionTypes st
ON
    s.SubscriptionType_Center = st.Center
AND s.SubscriptionType_ID = st.ID
JOIN
    Products pr
ON
    st.Center = pr.Center
AND st.Id = pr.Id

join SUBSCRIPTION_SALES ss
on
 ss.SUBSCRIPTION_CENTER = s.center
 and
ss.SUBSCRIPTION_ID = s.id

join SUBSCRIPTIONPERIODPARTS spp
on
ss.SUBSCRIPTION_CENTER = spp.CENTER
and 
ss.SUBSCRIPTION_id = spp.id


WHERE
    /* Only active subscriptions */
    s.state IN (2,4,8)
AND s.center in (:scope)
and st.BINDINGPERIODCOUNT > 0
   
AND s.START_DATE BETWEEN :from_date AND :to_date
and (ss.PRICE_PERIOD*st.BINDINGPERIODCOUNT) > ss.CONTRACT_INCLUDING_SPONSOR   
and ss.CONTRACT_INCLUDING_SPONSOR > 0
and trunc(s.START_DATE - s.BINDING_END_DATE)*-1 > 364
and ss.PRICE_PERIOD > 100
and (spp.subid = 1 and spp.SUBSCRIPTION_PRICE = 0)