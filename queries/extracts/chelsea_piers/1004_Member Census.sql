WITH
    params AS
    (
        SELECT
            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS today,
            CAST(datetolongTZ(TO_CHAR(to_date($$start_date$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone) AS BIGINT) AS from_date,
            CAST(datetolongTZ(TO_CHAR(to_date($$to_date$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS' ),c.time_zone)+ (24*3600*1000) -1 AS BIGINT) AS to_date,
            c.id AS centerid
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )

SELECT DISTINCT
ON (per.external_id) 
    c.name as "Business Unit",
    per.external_id             AS "Member External ID",
    per.firstname               AS "First Name",
    per.lastname                AS "Last Name",
    per.first_active_start_date AS "Member Since Date",
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
    END AS "PERSON TYPE",
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
    CASE
        WHEN per.blacklisted = 0
        THEN false
        ELSE true
    END                  AS "Black Listed",
    s.center||'ss'||s.id AS "Agreement ID",
    prd.name             AS "Agreement Name",
    s.start_date         AS "Start Date",
    s.end_date           AS "Cancel Date",
    ssa.sales_date       AS "Sale Date",
    srp.start_date as "Freeze Start",
    srp.end_date as "Freeze End",    
    company.fullname     as "Company",
    email.txtvalue       AS "Email Address",
    phone.txtvalue       AS "Phone",
    per.address1 as "Street Address",
    per.address2 as "Street Address 2",
    per.zipcode as "Postal Code",
    per.city as "City"
    
FROM
    chelseapiers.persons per
join params on per.center = params.centerid
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
left join chelseapiers.subscription_reduced_period srp on srp.type = 'FREEZE' and srp.state = 'ACTIVE'
and s.start_date BETWEEN params.from_date and params.to_date