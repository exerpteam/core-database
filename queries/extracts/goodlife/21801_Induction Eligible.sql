WITH pmp_xml AS (

    SELECT 
	
	m.globalid,
	CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml 
	
	FROM goodlife.masterproductregister m 

	JOIN (

		SELECT DISTINCT
		p.globalid

		FROM

		products p

		JOIN product_and_product_group_link ppgl
		ON ppgl.product_center = p.center
		AND ppgl.product_id = p.id
		AND CASE
			WHEN :Company_Type = 18201 -- New product group - Eligible for Induction Tour
			THEN ppgl.product_group_id = 14604 -- Induction Tour
			WHEN :Company_Type = 18401 -- New Product Group - Eligible for KAP Induction Tour
			THEN ppgl.product_group_id = 18601 -- New Product Group - KAP Induction Tour
			ELSE FALSE
		END

	) a USING (globalid)

), induction_config AS (

	SELECT

	p.center,
	p.id,
	CASE
		WHEN CAST(CAST(a.purchaseFrequencyType AS TEXT) AS INTEGER) = 0 -- Sliding
		THEN date_trunc('DAYS',CURRENT_TIMESTAMP) - CAST(CAST(a.purchaseFrequencyPeriod AS TEXT)||' '||a.purchaseFrequencyPeriodUnit AS INTERVAL) 
		WHEN CAST(CAST(a.purchaseFrequencyType AS TEXT) AS INTEGER) = 1
		THEN CAST(date_trunc(CAST(a.purchaseFrequencyPeriodUnit AS TEXT),CURRENT_TIMESTAMP - CAST(CAST(CAST(CAST(a.purchaseFrequencyPeriod AS TEXT) AS INTEGER) - 1 AS TEXT)||' '||a.purchaseFrequencyPeriodUnit AS INTERVAL) ) AS DATE)
		ELSE CURRENT_DATE
	END AS cut_date,
	CAST(CAST(a.purchaseFrequencyMaxBuy AS TEXT) AS INTEGER) AS qty

	FROM

	(
	SELECT

	pmp_xml.globalid,
	UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/@qty', pmp_xml.pxml)) AS purchaseFrequencyMaxBuy,
    UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/@unit', pmp_xml.pxml)) AS purchaseFrequencyPeriodUnit,
    UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/period/text()', pmp_xml.pxml)) AS purchaseFrequencyPeriod,
	UNNEST(xpath('//subscriptionType/subscriptionNew/product/maxBuy/type/text()', pmp_xml.pxml)) AS purchaseFrequencyType

	FROM pmp_xml) a

	JOIN products p USING (globalid)

),subscriptions_corporate AS (

	-- Eligible sales within date range

	SELECT 

		s.center, 
		s.id, 
		s.start_date, 
		s.owner_center, 
		s.owner_id, 
		ppgl.product_group_id, 
		s.end_date,
		ss.sales_date

	FROM subscription_sales ss

	JOIN subscriptions s
	on ss.subscription_center = s.center
	AND ss.subscription_id = s.id
	AND ss.sales_date >= (:SelectedDateFrom)
	AND ss.sales_date <= (:SelectedDateTo)
	AND ss.type = 1 -- NEW
	AND (
		s.state IN (2,4,8)
		OR (
			-- KAP transferred from 800 series club
			s.state = 3
			AND s.sub_state = 6
		)
	)

	JOIN product_and_product_group_link ppgl
	ON ppgl.product_center = s.subscriptiontype_center
	AND ppgl.product_id = s.subscriptiontype_id
	AND ppgl.product_group_id = :Company_Type
	
)
, subscriptions_previous AS (
    
	-- Had membership subscription in last 60 days

	SELECT 
	
	sc.center, 
	sc.id

	FROM subscriptions_corporate sc

	JOIN subscriptions sp
	ON sp.owner_center = sc.owner_center
	AND sp.owner_id = sc.owner_id
	AND NOT (sc.center = sp.center
		AND sc.id = sp.id)
	AND (
		(sp.end_date > (sc.start_date - INTERVAL '60 DAYS'))
		OR (sp.end_date IS NULL)
	)
	AND sp.creation_time < CAST (extract(epoch FROM now() ) AS bigint)*1000 -1000

	JOIN product_and_product_group_link ppgl
	ON ppgl.product_center = sp.subscriptiontype_center
	AND ppgl.product_id = sp.subscriptiontype_id
	AND ppgl.product_group_id = 1004 -- Memberships
	
), subscriptions_tour AS (

	-- Induction Tour already sold

	SELECT 
	
	stour.owner_center, 
	stour.owner_id 

	FROM subscriptions_corporate sc

	JOIN subscriptions stour	
	ON stour.owner_center = sc.owner_center
	AND stour.owner_id = sc.owner_id
	AND stour.start_date >= sc.start_date -- Sold on or after date of this eligible membership sale
	AND NOT (
		sc.center = stour.center
		AND sc.id = stour.id
	)

	JOIN induction_config i
	ON stour.subscriptiontype_center = i.center
	AND stour.subscriptiontype_id = i.id
	AND stour.start_date >= i.cut_date

	GROUP BY 
	stour.owner_center, 
	stour.owner_id,
	i.qty 

	HAVING
	COUNT(*) >= i.qty
    
), subscriptions_wo_previous_tour AS (

	SELECT 
	
	sc.center, 
	sc.id, 
	sc.start_date, 
	sc.owner_center, 
	sc.owner_id, 
	sc.product_group_id, 
	sc.end_date,
	sc.sales_date

	FROM subscriptions_corporate sc

	WHERE

	NOT EXISTS (
		SELECT 1 
		FROM subscriptions_previous sp
		WHERE 
		sp.id = sc.id
		AND sp.center = sc.center
	)
	AND NOT EXISTS (
		SELECT 1 
		FROM subscriptions_tour stour
		WHERE 
		stour.owner_center = sc.owner_center
		AND stour.owner_id = sc.owner_id
	)
)

SELECT

p.current_person_center||'p'||p.current_person_id AS "Person ID", 
s.sales_date AS "Date Subscription Sold",
p.fullname AS "Person Full Name",
s.start_date AS "Subscription Start Date"

FROM subscriptions_wo_previous_tour s
	
JOIN persons p
ON p.center = s.owner_center
AND p.id = s.owner_id