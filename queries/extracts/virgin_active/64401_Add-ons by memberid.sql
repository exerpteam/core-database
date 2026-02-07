SELECT
   per.center||'p'||per.id             AS customer,
		sa.center_id 								  as add_on_scope,
    prod.name                                    AS add_on_name,
    sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as main_subscription,
    sa.id,
    sa.ADDON_PRODUCT_ID,
    sa.START_DATE,
    sa.END_DATE,
    sa.INDIVIDUAL_PRICE_PER_UNIT,
    per.firstname,
    per.lastname,
    per.Address1|| ' ' ||per.Address2 AS adress,
    per.zipcode,
    per.city,
    Emails.TxtValue AS Email
FROM
    SUBSCRIPTION_ADDON sa
left JOIN masterproductregister m
ON
    sa.addon_product_id = m.id
LEFT JOIN products prod
ON
    m.globalid = prod.globalid

left JOIN subscriptions s
ON
    s.center = sa.subscription_center
AND s.id = sa.subscription_id
left JOIN persons per
ON
    per.center = s.owner_center
AND per.id = s.owner_id
LEFT JOIN Person_Ext_Attrs Emails
ON
    per.center = Emails.PersonCenter
AND per.id = Emails.PersonId
AND Emails.Name = '_eClub_Email'
WHERE
(s.owner_center,s.owner_id) in (:memberid) 
and sa.cancelled = 0


GROUP BY
	per.center,
	per.id,
   	sa.center_id,
    sa.cancelled,
    prod.name,
    per.firstname,
    per.lastname,
    per.Address1,
    per.Address2,
    per.zipcode,
    per.city,
    Emails.TxtValue,
    sa.ADDON_PRODUCT_ID,
    sa.END_DATE,
    sa.id,
    sa.SUBSCRIPTION_CENTER,
    sa.SUBSCRIPTION_id,
    sa.INDIVIDUAL_PRICE_PER_UNIT,
    sa.START_DATE
