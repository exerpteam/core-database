-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT 
ON (per.external_id) 
    c.name as "Business Unit",
    per.center||'p'||per.id as "Person ID",
    cpf.txtvalue as "CPf Person ID",
    per.firstname               AS "First Name",
    per.lastname                AS "Last Name",
    to_char(per.first_active_start_date,'mm/dd/yyyy') AS "Member Since Date",
    to_char(per.birthdate,'mm/dd/yyyy') as "Birth Date",
    CAST(EXTRACT( YEAR FROM (AGE(now(),per.birthdate)))AS INTEGER) AS "Age",
    CASE
        WHEN per.PERSONTYPE = 0
        THEN 'PRIVATE'
        WHEN per.PERSONTYPE = 1
        THEN 'STUDENT'
        WHEN per.PERSONTYPE = 2
        THEN 'STAFF'
        WHEN per.PERSONTYPE = 3
        THEN 'FRIEND'
        WHEN per.PERSONTYPE = 4
        THEN 'CORPORATE'
        WHEN per.PERSONTYPE = 5
        THEN 'ONEMANCORPORATE'
        WHEN per.PERSONTYPE = 6
        THEN 'FAMILY'
        WHEN per.PERSONTYPE = 7
        THEN 'SENIOR'
        WHEN per.PERSONTYPE = 8
        THEN 'GUEST'
        WHEN per.PERSONTYPE = 9
        THEN 'CHILD'
        WHEN per.PERSONTYPE = 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END AS "Person Type",
    CASE
        WHEN per.STATUS = 0
        THEN 'LEAD'
        WHEN per.STATUS = 1
        THEN 'ACTIVE'
        WHEN per.STATUS = 2
        THEN 'INACTIVE'
        WHEN per.STATUS = 3
        THEN 'FREEZE'
        WHEN per.STATUS = 4
        THEN 'TRANSFERRED'
        WHEN per.STATUS = 5
        THEN 'DUPLICATE'
        WHEN per.STATUS = 6
        THEN 'PROSPECT'
        WHEN per.STATUS = 7
        THEN 'DELETED'
        WHEN per.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN per.STATUS = 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS "Person Status",    
    s.center||'ss'||s.id AS "Agreement ID",
    prd.name             AS "Agreement Name",
    to_char(s.start_date,'mm/dd/yyyy')         AS "Start Date",
    to_char(s.end_date,'mm/dd/yyyy')           AS "Cancel Date",
    s.subscription_price as "Key Item Price",
    to_char(ssa.sales_date,'mm/dd/yyyy')       AS "Sale Date",
    to_char(srp.start_date,'mm/dd/yyyy') as "Freeze Start",
    to_char(srp.end_date,'mm/dd/yyyy') as "Freeze End",  
     CASE
    WHEN s.state = 1
    then 'Awaiting activation'
    when s.state = 2
    then 'Active'
    when s.state = 3
    then 'Ended'
    when s.state = 4
    then 'Frozen'
    when s.state = 5
    then 'Cancelled'
    when s.state = 6
    then 'Not paid'
    when s.state = 7
    then 'Window'
    when s.state = 8
    then 'Created'
    when s.state = 9
    then 'Ended transferred'
    when s.state = 10
    then 'Created transferred'
    end as "Agreement State",  
    company.fullname     as "Company",
    email.txtvalue       AS "Email Address",
    phone.txtvalue       AS "Phone",
    per.address1 as "Street Address",
    per.address2 as "Street Address 2",
    per.zipcode as "Postal Code",
    per.city as "City",
    case when 
    memberapp.txtvalue='true' then true
    else false end
     as "Member App Logged In"
    
FROM
    chelseapiers.persons per
left JOIN
    chelseapiers.person_ext_attrs email
ON
    per.center = email.personcenter
AND per.id = email.personid
AND email.name = '_eClub_Email'
left JOIN
    chelseapiers.person_ext_attrs phone
ON
    per.center = phone.personcenter
AND per.id = phone.personid
AND phone.name = '_eClub_PhoneSMS'
left join chelseapiers.person_ext_attrs cpf on cpf.personcenter = per.center and cpf.personid = per.id and cpf.name = '_eClub_OldSystemPersonId'  
left join chelseapiers.person_ext_attrs memberapp on memberapp.personcenter = per.center and memberapp.personid = per.id and memberapp.name = '_eClub_HasLoggedInMemberMobileApp'
JOIN
    subscriptions s
ON
    s.owner_center = per.center
AND s.owner_id = per.id
JOIN
    centers c
ON
    c.id = per.center
JOIN
    chelseapiers.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products prd
ON
    prd.center = st.center
AND prd.id = st.id
JOIN
    chelseapiers.product_and_product_group_link ppgl
ON
    prd.center = ppgl.product_center
AND prd.id = ppgl.product_id
JOIN
    chelseapiers.product_group pg
ON
    pg.id = ppgl.product_group_id
aND pg.name IN ('Membership','Complimentary Membership','Legacy Membership','TFC Membership')
JOIN
    subscriptionperiodparts spp
ON
    spp.center = s.center
AND spp.id = s.id
LEFT JOIN
    subscription_sales ssa
ON
    ssa.subscription_center = s.center
AND ssa.subscription_id = s.id
left join chelseapiers.relatives r on r.center = per.center and r.id = per.id and r.rtype = 3
left join chelseapiers.persons company on company.center = r.relativecenter and company.id = r.relativeid
left join chelseapiers.subscription_reduced_period srp on srp.type = 'FREEZE' and srp.state = 'ACTIVE' and srp.subscription_center = s.center and srp.subscription_id = s.id
and NOW() >= srp.start_date and srp.end_date >= NOW()
where  per.STATUS not in (4,5,7,8)
and per.center in (:Scope)
