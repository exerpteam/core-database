-- adjustments can be subscription price changes or payment account adjustments
-- applied should only include subscription price
-- created should include both subscription price and account transactions


SELECT
    c.name       		AS "Club",
    c.id         		AS "Club Number",
    c.external_id 	 	AS "Club Code",
    p.external_id 	 	AS "Member Number",
    pr.Name			    AS "Subscription_Name",
    s.binding_end_date 	 	AS "MCP End Date",
    sp.from_date         	AS "Adj. From Date",
    sp.to_date   	 	AS "Adj. End Date",
    staff.fullname       	AS "Operator",
    pp.price_modification_name  AS "Adjustment Action",
    s.subscription_price 	AS "Membership Price",
    sp.price 			AS "Adjustment Amount",
    sp.type 			AS "Adjustment Type",
    sp.coment    		AS "Notes"
FROM
    evolutionwellness.subscription_price sp
JOIN
    evolutionwellness.centers c
ON
    c.id = sp.subscription_center
JOIN
    evolutionwellness.subscriptions s
ON
    s.center = sp.subscription_center
AND s.id = sp.subscription_id
AND s.State = 2
LEFT JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
LEFT JOIN
    PRODUCTS pr
ON
    pr.center = st.center
    AND pr.id = st.id
JOIN
    evolutionwellness.persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN
    evolutionwellness.employees emp
ON
    emp.center = sp.employee_center
AND emp.id = sp.employee_id
LEFT JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
LEFT JOIN
    evolutionwellness.privilege_usages pu
ON
    pu.target_service = 'SubscriptionPrice'
AND pu.target_id = sp.id
LEFT JOIN
    evolutionwellness.product_privileges pp
ON
    pp.id = pu.privilege_id
WHERE
    p.external_id IS NOT NULL
AND (
       sp.type IN ('INDIVIDUAL', 'CONVERSION')
    OR (sp.type = 'NORMAL' AND sp.Pending is TRUE)
    OR  (
            pp.id IS NOT NULL
        AND pp.price_modification_name != 'NONE'))
AND (sp.cancelled is FALSE OR sp.cancelled is NULL)                 
AND ((sp.to_date <= $$Adjustment_To_Date$$ AND sp.to_date >= date(now()))
	OR sp.to_date is NULL)
AND sp.subscription_center IN (:scope)
ORDER BY 4,6