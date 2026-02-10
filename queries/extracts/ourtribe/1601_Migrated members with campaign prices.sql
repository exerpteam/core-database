-- The extract is extracted from Exerp on 2026-02-08
-- Migrated members on ARCA_001 or JOGA_001 whose subcription price is less than 499. Assumption: Migrated members have a subscription comment, so filtering out any subscriptions without a comment.
SELECT 
s.CENTER as "CENTERID",
s.OWNER_CENTER ||'p'|| s.OWNER_ID AS "PERSONKEY",
S.CENTER ||'ss'||S.ID AS "SUBSCRIPTIONKEY",
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
SP.price as "Price",
SP.FROM_DATE AS "PriceStart",
SP.TO_DATE AS "PriceEnd",
PR.GLOBALID

FROM 
PRODUCTS PR
JOIN
SUBSCRIPTIONS S
ON
S.SUBSCRIPTIONTYPE_ID = PR.ID
AND
S.SUBSCRIPTIONTYPE_CENTER = PR.CENTER
LEFT JOIN
Subscription_price sp
ON
sp.subscription_center = S.CENTER
AND 
sp.subscription_id = S.ID
WHERE
s.CENTER in (:Scope)
AND 
s.END_DATE IS NULL
AND
s.sub_comment IS NOT NULL
AND
s.STATE = '2'
and
s.subscription_price < 499
ORDER BY "PERSONKEY"
