-- The extract is extracted from Exerp on 2026-02-08
-- End date is more than today. Includes Future Free Periods
 SELECT

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
	NULL AS "FreezeType",
   	NULL AS "FreezeStartDate",
	NULL AS "FreezeStartDate",
	NULL AS "FreezeEndDate",
	NULL AS "FreezeReason",
	NULL AS "IsFreezeUpdate",
	NULL AS "ContractFreezeId",
	srp.TEXT AS "Comment",
COALESCE(TO_CHAR(srp.START_DATE,'dd.MM.YYYY'),TO_CHAR(sp.FROM_DATE,'dd.MM.YYYY')) AS Start_date,
     COALESCE(TO_CHAR(srp.END_DATE,'dd.MM.YYYY'),TO_CHAR(sp.TO_DATE,'dd.MM.YYYY'))     AS END_DATE,
	NULL AS "Days",
     c.NAME                          AS center,
     s.OWNER_CENTER||'p'||s.OWNER_ID AS memberid,
	p.fullname AS FullName,
	s.SUBSCRIPTION_PRICE,
     
 TO_CHAR(longtodate(srp.entry_time),'dd.MM.YYYY')  AS "entry date",
     pr.NAME                                AS "Subscription",
     srp.TYPE AS "Type"
     
 FROM
     HP.SUBSCRIPTIONS s
 LEFT JOIN
     HP.SUBSCRIPTION_REDUCED_PERIOD srp
 ON
     s.center = srp.SUBSCRIPTION_CENTER
     AND s.id = srp.SUBSCRIPTION_ID
     AND srp.state NOT IN ('CANCELLED')
 JOIN
     HP.PERSONS p
 ON
     p.center = s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 JOIN
     HP.CENTERS c
 ON
     c.id = p.CENTER
 JOIN
     HP.PRODUCTS pr
 ON
     pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     HP.SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.id
     AND sp.PRICE = 0
     AND sp.CANCELLED = 0
 WHERE
     ((
             srp.TYPE IN ('SAVED_FREE_DAYS_USE',
                              'FREE_ASSIGNMENT'))
         OR s.SUBSCRIPTION_PRICE = 0
         OR sp.ID IS NOT NULL )
     AND s.CENTER IN ($$scope$$)
 AND P.STATUS IN ( $$PersonStatus$$ )
AND srp.END_DATE > CURRENT_DATE
                OR srp.END_DATE IS NULL
     AND s.STATE IN (2,4)
         AND srp.state NOT IN ('CANCELLED')
     AND p.PERSONTYPE !=2
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             PRODUCT_AND_PRODUCT_GROUP_LINK ppg
         WHERE
             ppg.product_center = s.SUBSCRIPTIONTYPE_CENTER
             AND ppg.product_id = s.SUBSCRIPTIONTYPE_ID
             AND ppg.PRODUCT_GROUP_ID = 1201 )