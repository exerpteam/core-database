SELECT DISTINCT 
    c.name                            AS "Center",
    per.external_id as "PersonID",
    per.firstname,
    per.lastname,
    per.sex as Gender,
    pea.txtvalue as Preferred_Pronoun,
    --ss.owner_center||'p'||ss.owner_id AS personid,
    p.name                            AS "Agreement Name",
    ss.sales_date as "Sale Date",
    ss.start_date AS "Subscription Start",
    CASE
        WHEN s.STATE = 2
        THEN 'ACTIVE'
        WHEN s.STATE = 3
        THEN 'ENDED'
        WHEN s.STATE = 4
        THEN 'FROZEN'
        WHEN s.STATE = 7
        THEN 'WINDOW'
        WHEN s.STATE = 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Subscription State",
    ss.company_center as "Company Center",
    ss.company_id as "Company ID",
    staff_assigned.external_id as "Staff_ID_Assigned",
staff_assigned.full_name as "Staff Assigned Name",
    staff_sell.external_id as "Staff_ID_Selling"  
FROM
    chelseapiers.subscription_sales ss
JOIN
    subscriptiontypes st 
ON
    st.center = ss.subscription_type_center
AND st.id = ss.subscription_type_id
JOIn subscriptions s on s.center = ss.subscription_center
and s.id = ss.subscription_id
JOIN
    products p
ON
    p.center = st.center
AND p.id = st.id
JOIN
    centers c
ON
    c.id = ss.subscription_center
JOIN 
   persons per
ON per.center = s.owner_center and per.id = s.owner_id 
left join chelseapiers.person_ext_attrs pea on per.center = pea.personcenter and per.id = pea.personid and pea.name = 'Pronoun'
left join persons staff_assigned on s.assigned_staff_center = staff_assigned.center and s.assigned_staff_id = staff_assigned.id
left join persons staff_sell on staff_sell.center = ss.employee_center and staff_sell.id = ss.employee_id
where ss.sales_date BETWEEN $$FROM_DATE$$ AND $$TO_DATE$$
and ss.subscription_center in ($$CENTER$$)