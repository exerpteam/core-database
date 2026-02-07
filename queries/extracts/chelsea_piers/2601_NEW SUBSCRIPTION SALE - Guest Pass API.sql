SELECT
    p.center as threadgroup,
    p.center as person_center,
    p.id as person_id,
    'GuestPass' as att_name,
    '6' as att_value
FROM
    subscriptions s
JOIN
    chelseapiers.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    chelseapiers.products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    chelseapiers.product_and_product_group_link ppgl
ON
    ppgl.product_center = pr.center
AND ppgl.product_id = pr.id
join chelseapiers.subscription_sales ss on ss.owner_center = s.owner_center and ss.owner_id = s.owner_id
JOIN
    product_group pg
ON
    ppgl.product_group_id = pg.id
AND pg.name IN ('Guest Pass Extended Attribute') -- Active subscription must be in Membership product group

JOIN
    persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
left join chelseapiers.person_ext_attrs pea on pea.personcenter = s.owner_center
and pea.personid = s.owner_id and pea.name = 'GuestPass'
WHERE
p.status not in (2) and
    s.state IN (2,3) 
    and ss.sales_date >= '2021-11-13'
    and pea.txtvalue is null