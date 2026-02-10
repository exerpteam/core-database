-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    (s.owner_center||'p'||s.owner_id) AS memberid,
    sfp.start_date                    AS FreezeStartDate,
    sfp.end_date,
	TO_CHAR(longtodate(sfp.entry_time),'dd.MM.YYYY')
	AS "entry date",
    sfp.TYPE,
	pr.NAME AS SubscriptionName,
	sfp.TEXT AS "Comment"

FROM
    hp.subscription_freeze_period sfp
JOIN
    hp.subscriptions s
ON
    sfp.subscription_center = s.center
    AND sfp.subscription_id = s.id
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
    sfp.start_date >= (:Start_Date_From)
    AND sfp.state = 'ACTIVE'
    AND s.center IN (:scope)