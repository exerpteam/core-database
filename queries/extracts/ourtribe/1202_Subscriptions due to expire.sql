-- The extract is extracted from Exerp on 2026-02-08
-- Members have an active subscription with a stop date and any subscriptions in state 'created'. 
SELECT 
s.CENTER as "CENTERID",
s.OWNER_CENTER ||'p'|| s.OWNER_ID AS "PERSONKEY",
pea.txtvalue AS "Email",
s.START_DATE,
s.END_DATE,
CASE s.STATE
	WHEN 2 THEN 'ACTIVE'
	WHEN 3 THEN 'ENDED'
	WHEN 4 THEN 'FROZEN'
	WHEN 7 THEN 'WINDOW' 
	WHEN 8 THEN 'CREATED'
	ELSE 'OTHER'
END AS "SUBSCRIPTION STATE",
s.SUB_COMMENT AS "Legacy name",
PR.NAME AS "Exerp name",
s.subscription_price as "Price",
PR.GLOBALID


FROM 
SUBSCRIPTIONS s
JOIN
PRODUCTS PR
ON
S.SUBSCRIPTIONTYPE_ID  = PR.ID
AND
S.SUBSCRIPTIONTYPE_CENTER= PR.CENTER
JOIN
person_ext_attrs pea
ON
pea.personcenter = S.owner_CENTER
AND
pea.personid = S.owner_id 
AND
pea.name = '_eClub_Email'
WHERE
(s.CENTER IN (:Scope)
AND 
s.END_DATE IS NOT NULL
AND
s.STATE = '2')
OR
(s.CENTER IN (:Scope)
AND
s.STATE = '8')
