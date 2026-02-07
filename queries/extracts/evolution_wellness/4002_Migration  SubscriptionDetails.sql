WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(getCenterTime(c.id),c.id) AS cutdate,
                c.id,
                c.name as clubname
        FROM centers c
),
sponsorship AS
(select
        pg.sponsorship_name 
        ,pg.sponsorship_amount
        ,pp.ref_globalid
        ,pg.granter_center
        ,pg.granter_id
        ,pg.granter_subid
FROM        
        privilege_grants pg 
JOIN evolutionwellness.privilege_sets ps ON ps.id = pg.privilege_set
JOIN params on params.id = pg.granter_center
JOIN evolutionwellness.product_privileges pp ON pp.privilege_set = ps.id AND (pp.valid_to IS NULL OR pp.valid_to > params.cutdate) 
WHERE
        pg.granter_service = 'CompanyAgreement' AND (pg.valid_to IS NULL OR pg.valid_to > params.cutdate)
)
SELECT DISTINCT
        pea.txtvalue AS PersonId,
        s.center AS SubscriptionCenterId,
        longtodatec(s.creation_time, s.center) AS MembershipCreationDate,
        s.start_date AS MembershipStartDate,
        s.end_date AS MembershipEndDate,
        s.sub_comment AS MembershipComment,
        s.subscription_price AS MembershipPrice,
        (CASE st.st_type
                WHEN 0 THEN 'CASH'
                WHEN 1 THEN 'EFT'
        END) AS MembershipDeductionType,
        s.billed_until_date AS MembershipBilledUntilDate,
        s.binding_end_date AS MembershipBindingEndDate,
        sfp.start_date AS FreezeFrom,
        sfp.end_date AS FreezeTo,
        sfp.text AS FreezeReason,
        sfp.type AS FreezePrice,
        pr.globalid AS NewMembershipType,
        (CASE s.state 
                WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' 
        END) AS exerp_subscription_state,
        (CASE s.sub_state 
                WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' 
                WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' 
                WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' 
                WHEN 10 THEN 'CHANGED' ELSE 'Undefined' 
        END) AS exerp_subscription_substate
        ,ca.name AS "Agreement name"
        ,com.fullname AS "Corporate"
        ,par.clubname AS "Club Name"
        ,pg.sponsorship_name 
        ,CASE
                WHEN pg.sponsorship_name = 'PERCENTAGE' THEN s.subscription_price * pg.sponsorship_amount
                WHEN pg.sponsorship_name = 'FIXED' THEN pg.sponsorship_amount
                WHEN pg.sponsorship_name = 'FULL' THEN s.subscription_price
        END AS "Sponsorship Price"
        ,pr.name
        ,s.subscription_price
        ,ar.balance
FROM evolutionwellness.persons p
JOIN params par ON p.center = par.id 
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId' AND pea.txtvalue IS NOT NULL
JOIN evolutionwellness.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN evolutionwellness.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
JOIN evolutionwellness.products pr On st.center = pr.center AND st.id = pr.id
LEFT JOIN evolutionwellness.subscription_freeze_period sfp ON sfp.subscription_center = s.center AND sfp.subscription_id = s.id AND sfp.employee_center = 100 AND sfp.employee_id = 1
LEFT JOIN evolutionwellness.relatives rel ON rel.center = p.center AND rel.id = p.id AND rel.rtype = 3
LEFT JOIN evolutionwellness.companyagreements ca ON ca.center = rel.relativecenter AND ca.id = rel.relativeid AND ca.subid = rel.relativesubid
LEFT JOIN evolutionwellness.persons com ON com.center = ca.center AND com.id = ca.id
LEFT JOIN sponsorship pg ON pg.granter_center = ca.center AND pg.granter_id = ca.id AND pg.granter_subid = ca.subid AND pg.ref_globalid = pr.globalid
LEFT JOIN evolutionwellness.account_receivables ar ON ar.customercenter = p.center AND ar.customerid = p.id and ar.ar_type = 4
WHERE
        s.sub_comment IS NOT NULL
		AND s.owner_center IN (:Scope)
