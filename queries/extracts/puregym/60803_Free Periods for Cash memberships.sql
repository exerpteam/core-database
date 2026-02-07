WITH
    params AS MATERIALIZED
    (
        SELECT
                datetolong(to_char(CURRENT_TIMESTAMP-5,'YYYY-MM-DD HH24:MI')) AS lastfiveday, 
                CAST($$FreeFromDate$$ AS DATE) AS StartDate,
                CAST($$FreeToDate$$ AS DATE)  AS EndDate
        
    )
SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS SubscriptionId,
    s.start_date,
    s.end_date,
    s.billed_until_date
FROM
    subscriptions s
CROSS JOIN
    params
JOIN
    subscriptiontypes st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_id
    AND st.st_type = 0
WHERE
    s.owner_center IN ($$Scope$$)
	
    -- Look at ACTIVE AS PER TODAY  
    AND s.state = 2  
	
	
	/* make sure an exerp user did not create a freeze period with a start date right after quarentine period. */
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscription_reduced_period exerpsrp
		JOIN 
            employees e
        ON
            exerpsrp.employee_center = e.center
            AND exerpsrp.employee_id = e.id
        JOIN
            persons p
        ON
            e.personcenter = p.center
            and e.personid = p.id 
        JOIN
            person_ext_attrs email
        ON
            email.personcenter = p.center
            AND email.personid = p.id
            AND email.name = '_eClub_Email'
        WHERE
            exerpsrp.subscription_center = s.center
            AND exerpsrp.subscription_id = s.id
            AND exerpsrp.state = 'ACTIVE'
            AND UPPER(email.TXTVALUE) like '%@EXERP.COM%'	
            AND exerpsrp.entry_time >= PARAMS.lastfiveday
    )
	--make sure that any subscription that has a freeze period within the quarentine period is excluded, since we should not give 14 days
	AND NOT EXISTS
	(
		SELECT
			1
		FROM
			subscription_freeze_period sf
		WHERE
			sf.subscription_center = s.center
			AND sf.subscription_id = s.id
			AND sf.state = 'ACTIVE'
			AND sf.start_date <= params.EndDate 
            AND sf.end_date >= params.StartDate
	)
	-- exclude subscriptions from those product groups
	AND NOT EXISTS
	(
		SELECT
			1
		FROM
			PRODUCT_AND_PRODUCT_GROUP_LINK ppl
		WHERE
			ppl.product_center = st.center
			AND ppl.product_id = st.id
			AND ppl.PRODUCT_GROUP_ID in (401,801,6409)
	)
	