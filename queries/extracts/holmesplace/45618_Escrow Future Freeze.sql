
SELECT DISTINCT

	'1' AS "IsUpdate",
	p.external_id AS "UserId",
	NULL AS "UserNumber",
	NULL AS "ContractId",
	NULL AS "SignUpDate",
	NULL AS "StartDate",
	NULL AS "EndDate",
	NULL AS "EndOfCommitmentDate",
	NULL AS "CancelReason",
	NULL AS "AccessRule",
	NULL AS "PaymentPlan",
	NULL AS "StartingPackage",
	NULL AS "ContractDiscount",
	NULL AS "ContractDiscountAdditionalValue",
	NULL AS "ContractDiscountAdditionalValue2",
	NULL AS "ContractDiscountAdditionalDate",
		CASE sfp.TYPE
	WHEN 'UNRESTRICTED' THEN 'HP Freeze 0€ Monthly'
	WHEN 'CONTRACTUAL' THEN 'HP Freeze 29€ Monthly'
	ELSE 'HP Freeze 0€ Monthly'
	END AS "FreezeType",
	sfp.start_date  AS "FreezeStartDate",
	sfp.end_date AS "FreezeEndDate",
	sfp.TEXT AS "FreezeReason",
	'0' AS "IsFreezeUpdate",
	NULL AS "ContractFreezeId",
    (s.owner_center||'p'||s.owner_id) AS memberid,
	p.fullname AS FullName,
	pr.NAME							AS SubscriptionName
FROM
    hp.subscription_freeze_period sfp
JOIN
    hp.subscriptions s
ON
    sfp.subscription_center = s.center
    AND sfp.subscription_id = s.id
JOIN
	Persons p
	ON p.center= s.owner_center
	AND p.id = s.owner_id
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
    sfp.start_date > current_date
    AND sfp.state = 'ACTIVE'
    AND s.center IN (:scope)