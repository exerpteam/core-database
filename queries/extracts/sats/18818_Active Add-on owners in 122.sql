SELECT
    ss.owner_center||'p'||ss.owner_id             AS customer,
	ss.owner_center as owner_center,
	sa.center_id 								  as add_on_scope,
    prod.name                                     AS add_on_name,
    per.firstname,
    per.lastname,
    per.Address1|| ' ' ||per.Address2 AS adress,
    per.zipcode,
    per.city,
    Emails.TxtValue AS Email
FROM
    SUBSCRIPTION_ADDON sa
JOIN masterproductregister m
ON
    sa.addon_product_id = m.id
LEFT JOIN products prod
ON
    m.globalid = prod.globalid
JOIN subscription_sales ss
ON
    sa.subscription_center = ss.subscription_center
AND sa.subscription_id= ss.subscription_id
JOIN subscriptions s
ON
    ss.owner_center = s.owner_center
AND ss.owner_id = s.owner_id
JOIN persons per
ON
    per.center = s.owner_center
AND per.id = s.owner_id
LEFT JOIN Person_Ext_Attrs Emails
ON
    per.center = Emails.PersonCenter
AND per.id = Emails.PersonId
AND Emails.Name = '_eClub_Email'
WHERE
    ss.owner_center > = 500
and ss.owner_center < = 599 -- all in Sweden
and sa.center_id in (542)
and (
    (sa.end_date is null) 
    or 
    (sa.end_date >  to_date('2016-10-17','yyyy-mm-dd') ) 
    )
and sa.cancelled = 0
GROUP BY
	per.center,
	per.id,
    ss.owner_center,
    ss.owner_id,
	sa.center_id,
    sa.cancelled,
    prod.name,
    per.firstname,
    per.lastname,
    per.Address1,
    per.Address2,
    per.zipcode,
    per.city,
    Emails.TxtValue
ORDER BY
    ss.owner_center,
    ss.owner_id