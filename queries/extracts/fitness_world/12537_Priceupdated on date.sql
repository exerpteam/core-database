-- This is the version from 2026-02-05
--  
SELECT 
    count(s.center||'ss'||s.id) as count_subscriptions, 
    TO_CHAR(longToDate(sp.ENTRY_TIME),'yyyy-mm-dd') as entry_time,
    sp.price as price_updated,
    s.subscription_price,
    pro.globalid as product
FROM
     fw.persons p
join fw.subscriptions s
    on
        p.CENTER = s.owner_center
    AND p.ID = s.owner_id
join FW.SUBSCRIPTION_PRICE sp
    on
    s.center = sp.subscription_center
    and s.id = sp.subscription_id
join
    fw.subscriptiontypes st
    on
    s.subscriptiontype_center = st.center
    and s.subscriptiontype_id = st.id
join
    fw.products pro
    on
    st.center = pro.center
    and st.id = pro.id
WHERE
    sp.FROM_DATE in (:dato)
group by
    TO_CHAR(longToDate(sp.ENTRY_TIME),'yyyy-mm-dd'),
    sp.price,
    s.subscription_price,
    pro.globalid