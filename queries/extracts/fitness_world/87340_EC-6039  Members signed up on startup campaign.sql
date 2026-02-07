-- This is the version from 2026-02-05
--  
SELECT DISTINCT
p.center||'p'||p.id AS MemberId,
p.fullname AS MemberName,
pr.name AS SubscriptionName,
pu.CAMPAIGN_CODE_ID,
sc.NAME AS CampaignName,
sc.ENDTIME as CampaignEndDate,
s.START_DATE AS SubscriptionStart,
s.END_DATE AS SubscriptionEnd
FROM
persons p
JOIN
privilege_usages pu
ON
pu.PERSON_CENTER = p.center
AND pu.PERSON_ID = p.id
AND pu.PRIVILEGE_TYPE = 'PRODUCT'
AND pu.STATE != 'CANCELLED'
JOIN
privilege_grants pg
ON
pg.ID = pu.GRANT_ID
AND pg.GRANTER_SERVICE = 'StartupCampaign'
JOIN
startup_campaign sc
ON sc.ID = pg.GRANTER_ID
JOIN
PRODUCTS pr
ON
pr.CENTER = pu.SOURCE_CENTER
AND pr.ID = pu.SOURCE_ID
JOIN
subscription_price sp
ON
sp.ID = pu.TARGET_ID
AND pu.TARGET_SERVICE = 'SubscriptionPrice'
JOIN
subscriptions s
ON
s.CENTER = sp.SUBSCRIPTION_CENTER
AND s.ID = sp.SUBSCRIPTION_ID
WHERE
s.CREATION_TIME BETWEEN :FROM_DATE AND :TO_DATE
AND p.CENTER IN (:scope)
AND sc.NAME IN (:campaign)
ORDER BY
MemberId
