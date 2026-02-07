WITH
    params AS
    (
        SELECT
            /*+ materialize */
			datetolong(to_char(sysdate-5,'YYYY-MM-DD HH24:MI')) AS lastfiveday,  	
			$$FreeFromDate$$ AS StartDate,
			$$FreeToDate$$ AS EndDate
		FROM DUAL
    )
SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS SubscriptionId,
    s.start_date,
    s.end_date,
    s.billed_until_date,
	DECODE(s.STATE,2,'ACTIVE',3,'ENDED',4,'FROZEN',7,'WINDOW',8,'CREATED','Undefined') as SubscriptionSTATE,
    case when params.enddate > s.end_date AND s.state = 2 then  params.endDate - s.end_date +1 
	     when (s.START_DATE >=  params.startdate) AND (s.START_DATE <=  params.enddate) AND s.state = 8 then params.enddate - s.start_date + 1
	     else null
    end AS freedays
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
		
	AND s.owner_center != 584 -- Exclude  SATS Åre
	
    AND 
	(
	-- if subcription is active now but will end before the quarentine
	(s.state = 2 AND s.END_DATE < PARAMS.EndDate) 
	OR
	-- if subcription is in CREATED now but will be active before the quarentine end
	(s.state = 8 AND s.START_DATE >=  params.startdate AND s.START_DATE <=  params.enddate)
	)
	
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
			subscription_freeze_period srd
		WHERE
			srd.subscription_center = s.center
			AND srd.subscription_id = s.id
			AND srd.state = 'ACTIVE'
			AND srd.start_date <= params.StartDate
			AND srd.end_date >= params.EndDate
	)
