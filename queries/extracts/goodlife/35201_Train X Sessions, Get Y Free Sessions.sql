WITH params AS (        

	SELECT

		datetolongTZ(TO_CHAR(CAST(:CampaignStart AS DATE),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateFrom,
		datetolongTZ(TO_CHAR(CAST(:CampaignEnd AS DATE),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDatePromoEnd, -- Will evaluate as Dec 1, 12AM
		datetolongTZ(TO_CHAR(CAST(:CutExisting AS DATE),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateExisting,
		c.id AS centerid    
	
	FROM
	
	goodlife.centers c 
	
	WHERE
	
	c.time_zone IS NOT NULL
	
), eligible_Members AS (

	-- New Sales
	
	SELECT DISTINCT
	
	p.center
	,p.id
	
	FROM
    
  	clipcards c

	JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
    ON ppgl.product_center = c.center
    AND ppgl.product_id = c.id
	AND ppgl.product_group_id IN (:ProductGroupClips) -- Determine Product Group
	AND c.cancelled = FALSE
    AND c.blocked = FALSE

	JOIN invoice_lines_mt inv
    ON c.invoiceline_center = inv.center
    AND c.invoiceline_id = inv.id
    AND c.invoiceline_subid = inv.subid

	JOIN params pm
	ON inv.center = pm.centerid
	
	JOIN invoices i
	ON i.center = inv.center
	AND i.id = inv.id
	AND i.entry_time BETWEEN pm.cutDateExisting AND pm.cutDatePromoEnd
	
	JOIN persons p
	ON c.owner_center = p.center
	AND c.owner_id = p.id
	AND p.persontype != 2 -- Staff

	UNION
	
	SELECT DISTINCT
	
	s.owner_center AS center
	,s.owner_id AS id
		
	FROM
	
	subscription_sales ss
    
    JOIN subscriptions s_sales
    ON ss.subscription_center = s_sales.center
    AND ss.subscription_id = s_sales.id
    AND ss.type = 1
	AND s_sales.start_date BETWEEN :CutExisting AND :CampaignEnd

    JOIN subscriptions s
    ON
        (
            (
                -- subscription not changed (the subscription at the time of the sale is not ended)
                s_sales.state IN (2,4) 
                AND s.center = s_sales.center
                AND s.id = s_sales.id
            )
            OR (
                -- the s_sales subscroiption has been changed to    another one, we JOIN to this one
                s_sales.changed_to_center IS NOT NULL 
                AND s.center = s_sales.changed_to_center 
                AND s.id = s_sales.changed_to_id
            )
        )
    AND s.state IN (2,4)
	
    JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
    ON ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id IN (:ProductGroupSubscription)  -- Determine Product Group
	
)

	SELECT

	p.center||'p'||p.id AS person_id
	,p.external_id
	
	FROM

	eligible_Members em
	
	JOIN persons p2
	ON p2.center = em.center
	AND p2.id = em.id

	JOIN persons p3
	ON p3.current_person_center = p2.current_person_center
	AND p3.current_person_id = p2.current_person_id

	JOIN persons p
	ON p.center = p2.current_person_center
	AND p.id = p2.current_person_id

	JOIN participations par
	ON p3.center = par.participant_center
	AND p3.id = par.participant_id
	AND par.state = 'PARTICIPATION'

	JOIN bookings b
	ON par.booking_center = b.center
	AND par.booking_id = b.id
	AND b.state = 'ACTIVE'

	JOIN params pm
	ON pm.centerid = b.center
	AND b.starttime BETWEEN pm.cutDateFrom AND pm.cutDatePromoEnd
	
	JOIN activity a
	ON a.id = b.activity 
	AND a.activity_group_id IN (:ActivityGroup) -- Personal Training, Remote Personal Training
	


	GROUP BY 

	p.center
	,p.id
	,p.external_id
	
	HAVING COUNT(*) >= :NumberofSessions

