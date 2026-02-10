-- The extract is extracted from Exerp on 2026-02-08
-- Freezes ending after Migration date. Send to PGM for migration. Freeze reasons converted to the ones in PGM. Frozen PT VIP are missing, will have to freeze manually?. Added exerp contract id, tell Pawel to use it to freeze the main contracts.
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
	
	CASE sfp.TEXT 
	WHEN 'Private' THEN '3 Private'
	WHEN 'Egym Wellpass' THEN '8 Egym Wellpass'
	WHEN 'Financial'  THEN '1 Financial' 
	WHEN 'Job' THEN '1 Job' 
	WHEN 'Sickness' THEN '2 Sickness'
	WHEN 'Pregnancy' THEN '2 Pregnancy'
	WHEN 'Refurbishments' THEN '4 Refurbishments'
	WHEN 'Club' THEN '6 Club'
	WHEN 'Other' THEN '7 Other'
	WHEN 'Gympass' THEN '8 Gympass'
	WHEN 'Egym Wellpass' THEN '8 Egym Wellpass'
	WHEN 'Urban Sports' THEN '8 Urban Sports'
	WHEN 'Hansefit' THEN '8 Hansefit' 
	WHEN 'Krankheit' THEN '2 Sickness'
	WHEN 'Qualitrain' THEN '8 Egym Wellpass'
	WHEN 'Urlaub' THEN '3 Private'
	ELSE sfp.TEXT
	END AS "FreezeReason",

	'0' AS "IsFreezeUpdate",
	NULL AS "ContractFreezeId",
	s.center || 'ss' || s.id AS "ExtContractId",
    (s.owner_center||'p'||s.owner_id) AS memberid,
	p.fullname AS FullName,
	TO_CHAR(longtodate(sfp.entry_time),'dd.MM.YYYY')AS "entry date",
    pr.NAME AS SubscriptionName	

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

JOIN
	PERSONS p
	ON s.owner_center = p.center
	AND s.owner_id = p.id
WHERE
	sfp.end_date >=(:End_Date_After)
    AND sfp.state = 'ACTIVE'
    AND s.center IN (:scope)