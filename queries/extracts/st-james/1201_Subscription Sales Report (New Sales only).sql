-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9903
WITH
    params AS materialized
    (
        SELECT
            id                                                                     AS centerid,
            CAST(:From_Date AS DATE) AS from_date,
            CAST(:To_Date AS DATE) to_date            
        FROM
            centers
        WHERE 
            id in (:Scope)    
    )
SELECT
    ss.sales_date                                        AS "Effective Date",
	CASE
		WHEN s.center = 101 then 'SPR'
		WHEN s.center = 102 then 'BET'
		ELSE NULL
	END AS "Center",
    ss.SUBSCRIPTION_CENTER || 'ss' || ss.SUBSCRIPTION_ID AS "Subscription ID",
	p2.center||'p'||p2.id        					     AS "Member ID",
    P2.fullname                                          AS "Member Name",
    pr.name                                              AS "Group Name",
	email.txtvalue 										 AS "Email",
	CASE
        WHEN ss.TYPE = 1
        THEN 'NEW'
        WHEN ss.TYPE = 2
        THEN 'EXTENSION'
        WHEN ss.TYPE = 3
        THEN 'CHANGE'
        WHEN ss.TYPE = 4
        THEN 'REACTIVATE'
        ELSE 'UNKNOWN'
    END AS "Sale Type",
    CASE
        WHEN st.st_type = 0
        THEN 'Paid In Full'
        WHEN st.st_type = 1
        THEN 'Recurring'
        WHEN st.st_type = 2
        THEN 'Recurring Clipcard'
    END                                    AS "Billing Type",
    ss.SALES_DATE                          AS "Sale Date",
    ss.START_DATE                          AS "Start Date",
    ss.END_DATE                            AS "End Date",
    p.fullname                             AS "Sales Associate",
    asg.fullname                           AS "Assigned To",
    CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State"
FROM
    params
JOIN
    SUBSCRIPTIONS s
ON 
    params.centerid = s.center
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    products pr
ON
    st.center = pr.center
AND st.id = pr.id
JOIN
    SUBSCRIPTION_SALES ss
ON
    s.CENTER = ss.SUBSCRIPTION_CENTER
AND s.ID = ss.SUBSCRIPTION_ID
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
AND emp.ID = ss.EMPLOYEE_ID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
AND p.ID = emp.PERSONID
LEFT JOIN
    PERSONS P2
ON
    s.owner_center = P2.CENTER
AND s.owner_id = P2.ID
LEFT JOIN
    persons asg
ON    
    s.assigned_staff_center = asg.center
    AND s.assigned_staff_id = asg.id
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.name ='_eClub_Email'
	AND email.PERSONCENTER = p2.center
	AND email.PERSONID = p2.id
WHERE
    ss.subscription_center IN (:Scope)
AND ss.SALES_DATE >= params.from_date
AND ss.SALES_DATE <= params.to_date
AND ss.TYPE = 1 -- only new ones
AND st.st_type < 2 -- only EFT & Cash

