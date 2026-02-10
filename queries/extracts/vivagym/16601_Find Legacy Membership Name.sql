-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.PersonId,
        t1.SubscriptionId,
        (CASE
                WHEN t1.group1 LIKE 'MembershipOldName:%' THEN t1.group1
                WHEN t1.group2 LIKE 'MembershipOldName:%' THEN t1.group2
                WHEN t1.group3 LIKE 'MembershipOldName:%' THEN t1.group3
                WHEN t1.group4 LIKE 'MembershipOldName:%' THEN t1.group4
                WHEN t1.group5 LIKE 'MembershipOldName:%' THEN t1.group5
                ELSE NULL
        END) AS Old_Subscription_Product,
        t1.name Current_Subscription_Name,
        t1.globalid AS Current_Subscription_GlobalId,
        (CASE t1.state
                WHEN 2 THEN 'ACTIVE'
                WHEN 4 THEN 'FROZEN'
                WHEN 8 THEN 'CREATED'
        END) AS subscription_state,
        t1.subscription_price,
		t1.subscription_startdate,
        t1.subscription_enddate,
        t1.priceupdate_fromdate,
        t1.priceupdate_todate,
        t1.priceupdate_price,
        t1.priceupdate_employee
FROM
(
        WITH params AS MATERIALIZED (
                SELECT
                        TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS cutdate,
                        c.id
                FROM vivagym.centers c
        )
        SELECT
                s.owner_center || 'p' || s.owner_id AS PersonId,
                s.center || 'ss' || s.id AS SubscriptionId,
                split_part(regexp_replace(s.sub_comment, '\r|\n', ';', 'g'), ';;', 1) AS group1,
                split_part(regexp_replace(s.sub_comment, '\r|\n', ';', 'g'), ';;', 2) AS group2,
                split_part(regexp_replace(s.sub_comment, '\r|\n', ';', 'g'), ';;', 3) AS group3,
                split_part(regexp_replace(s.sub_comment, '\r|\n', ';', 'g'), ';;', 4) AS group4,
                split_part(regexp_replace(s.sub_comment, '\r|\n', ';', 'g'), ';;', 5) AS group5,
                s.sub_comment,
                s.state,
				s.start_date AS subscription_startdate,
                s.end_date AS subscription_enddate,
                pr.name,
                pr.globalid,
                s.subscription_price,
                sp.from_Date AS priceupdate_fromdate,
                sp.to_date AS priceupdate_todate,
                sp.price AS priceupdate_price,
                sp.employee_center || 'emp' || sp.employee_id AS priceupdate_employee
        FROM vivagym.subscriptions s
        JOIN params par ON s.center = par.id
        JOIN vivagym.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
        JOIN vivagym.products pr ON st.center = pr.center AND st.id = pr.id
        LEFT JOIN vivagym.subscription_price sp
                ON sp.subscription_center = s.center AND sp.subscription_id = s.id AND sp.from_date > par.cutdate AND sp.cancelled = false AND sp.type NOT IN ('PERSON_TYPE')
        WHERE 
                s.sub_comment IS NOT NULL
                AND s.state IN (2,4,8)
				AND s.center IN (:Scope)

) t1