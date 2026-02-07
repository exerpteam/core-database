SELECT
    count(p.id) as count,
    s.binding_price,
    atts.txtvalue
FROM
    persons p
JOIN person_ext_attrs atts
ON
    atts.personcenter = p.center
    AND atts.personid = p.id
JOIN subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
WHERE
    atts.name = 'campaign 2010-02-28'
    AND s.state = 2
group by 
    s.binding_price,
    atts.txtvalue
