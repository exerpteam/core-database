-- This is the version from 2026-02-05
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval
            ' 6 months', 'YYYY-MM-DD'), c.id) AS BIGINT) AS cutDate,
            c.id                                         AS centerID,
c.name AS centerName
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    visits AS MATERIALIZED
    (
        SELECT DISTINCT
            c.PERSON_CENTER,
            c.PERSON_ID,
            COUNT(*) AS total_visits
        FROM
            CHECKINS c
        JOIN
            params
        ON
            params.centerid = c.person_center
        WHERE
            c.checkout_time != c.checkin_time
        AND NOT c.checkout_time - c.checkin_time < 1000
        AND c.CHECKIN_TIME > params.cutDate
        AND c.person_id IS NOT NULL
        GROUP BY
            person_id,
            person_center
    )
SELECT
    p.center ||'p'|| p.id                       AS           "MemberID",
    p.external_id                               AS           "MemberExternalID",
    par.centerID                                        AS           "ClubID",
    par.centerName                                      AS           "Club",
    ROUND(((CURRENT_DATE - p.birthdate)/365),0) AS           "Age",
    ROUND(((CURRENT_DATE - p.FIRST_ACTIVE_START_DATE)/30),1) "Tenure",
    COALESCE(vi.total_visits,0) AS                           "TotalVisits",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        ELSE 'UNKNOWN'
    END                    AS "PersonType",
    comp.Fullname          AS "CompanyName",
	    CASE s.state
        WHEN 2
        THEN 'ACTIVE'
        WHEN 4
        THEN 'FROZEN'
        ELSE 'Not frozen or Active sub state'
    END 					AS "Sub_State",
	CASE s.sub_state
        WHEN 1
        THEN 'NONE'
        WHEN 3
        THEN 'UPGRADED'
		WHEN 4
        THEN 'DOWNGRADED'
		WHEN 5
        THEN 'EXTENDED'
		WHEN 6
        THEN 'TRANSFERRED'
		WHEN 7
        THEN 'REGRETTED'
		WHEN 8
        THEN 'CANCELLED'
		WHEN 9
        THEN 'BLOCKED'
		WHEN 10
        THEN 'CHANGED'
        ELSE 'N/A'
    END 					AS "Sub_State",
    s.center ||'ss'|| s.id AS "SubscriptionID",
    pr.name                AS "Subscription",
    s.subscription_price   AS "SubscriptionPrice",
    s.binding_end_date     AS "BindingEndDate"
FROM
    persons p
JOIN
    params par
ON
    par.centerID = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
LEFT JOIN
    visits vi
ON
    vi.person_center = p.center
AND vi.person_id = p.id
LEFT JOIN
    RELATIVES r
ON
    r.RTYPE = 3
AND r.CENTER = p.CENTER
AND r.ID = p.ID
AND r.STATUS < 2
LEFT JOIN
    persons comp
ON
    comp.CENTER = r.RELATIVECENTER
AND comp.ID = r.RELATIVEID
WHERE
    s.state IN (2,4)
-- AND 
	-- s.sub_state <> 9
AND s.binding_end_date BETWEEN :fromDate AND :toDate