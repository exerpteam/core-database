
SELECT DISTINCT
    (s.owner_center||'p'||s.owner_id) AS memberid,
	C.shortname 						AS "Club",
    sfp.start_date                    AS FreezeStartDate,
    sfp.end_date,
    sfp.TYPE,
	sfp.TEXT AS "Comment",
	pr.NAME							AS SubscriptionName
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
JOIN CENTERS C
ON pr.center =C.ID

WHERE
    sfp.start_date > current_date
    AND sfp.state = 'ACTIVE'
    AND s.center IN (:scope)