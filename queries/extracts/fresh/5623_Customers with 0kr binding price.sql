SELECT
    p.center||'p'||p.id AS customerID,
    p.fullname          AS Personname,
    pro.name            AS productname,
    pro.globalid        AS globalid,
    s.binding_price
FROM
    persons p
JOIN subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
JOIN subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN products pro
ON
    st.center = pro.center
AND st.id = pro.id
WHERE
    s.binding_price = 0
AND s.state IN (2,4,7,8) -- active, frozen, window, created
AND p.country LIKE 'DK'
AND pro.globalid not in (:exclude_products)
AND p.persontype not in (2,3)  -- not staff, friend
and s.state in (2,4)
ORDER BY
    p.center,
    p.id