SELECT

s.owner_center||'p'||s.owner_id AS person_id
,ei.identity AS barcode


FROM

-- Had expiring PIF
subscriptions s

JOIN product_and_product_group_link ppgl
ON s.subscriptiontype_center = ppgl.product_center
AND s.subscriptiontype_id = ppgl.product_id
AND ppgl.product_group_id IN (12601,12603) -- CERT 1.0 AND 2.0 Products
AND s.state = 3 -- ENDED
AND s.end_date > CURRENT_DATE - :days

JOIN subscriptiontypes st
ON s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND st.st_type = 0 -- PIF

--Purchased New CERT 2.0 Subscription

JOIN subscriptions s2
ON s.owner_center = s2.owner_center
AND s.owner_id = s2.owner_id
AND NOT (s.center = s2.center AND s.id = s2.id)
AND s2.state IN (2,4,8)

JOIN product_and_product_group_link ppgl2
ON s2.subscriptiontype_center = ppgl2.product_center
AND s2.subscriptiontype_id = ppgl2.product_id
AND ppgl2.product_group_id = 12601 -- CERT 2.0

--Pull in barcode if exists

LEFT JOIN entityidentifiers ei
ON ei.ref_center = s.owner_center
AND ei.ref_id = s.owner_id
AND ei.ref_type = 1 -- Person
AND ei.idmethod = 1 -- Barcode
AND ei.entitystatus = 1 -- OK