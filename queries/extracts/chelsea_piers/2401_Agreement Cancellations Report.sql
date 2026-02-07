WITH
    params AS
    (
        SELECT
            c.name                           AS center,
            c.id                             AS CENTER_ID,
            TO_DATE($$CancelDateFrom$$,'YYYY-MM-DD') AS FROMDATE,
            TO_DATE($$CancelDateTo$$,'YYYY-MM-DD') AS TODATE
        FROM
            centers c
        WHERE
            c.id IN ($$Scope$$)
    )
SELECT
    params.center AS "Center",
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
    END                                                                  AS "Person Type",
    s.subscription_price                                                 AS "Monthly Price",
    prd.name                                                             AS "Subscription Name",
    CAST(NOW() AS DATE)- s.start_date ||' Days'                          AS "Subscription Days",
    TO_CHAR(longtodatec(je.creation_time,je.p_center),'mm/dd/yyyy')      AS "Cancellation Request Date",
    s.center||'ss'||s.id                                                 AS "Subscription ID",
    TO_CHAR(s.end_date,'mm/dd/yyyy')                                     AS "Subscription End Date",
    s.owner_center||'p'||s.owner_id                                      AS "Person ID",
    per.firstname                                                        AS "First Name",
    per.lastname                                                         AS "Last Name",
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END                             AS "Subscription State",
    per.address1                    AS "Street Address 1",
    per.address2                    AS "Street Address 2",
    per.city                        AS "City",
    per.zipcode                     AS "Zip",
    email.txtvalue                  AS "Email",
    phone.txtvalue                  AS "Phone",
    company.center||'p'||company.id AS "Company Key",
    company.fullname                AS "Company",
    ca.name                         AS "Company Agreement",
    company.address1                AS "Company Address 1",
    company.address2                AS "Company Address 2",
    company.zipcode                 AS "Company Zip",
    company.city                    AS "Company City"
FROM
    params
JOIN
    persons per
ON
    per.center = params.CENTER_ID
JOIN
    subscriptions s
ON
    s.owner_center = per.center
AND s.owner_id = per.id
JOIN
    products prd
ON
    prd.center = s.subscriptiontype_center
AND prd.id = s.subscriptiontype_id
LEFT JOIN
    person_ext_attrs email
ON
    per.center = email.personcenter
AND per.id = email.personid
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs phone
ON
    per.center = phone.personcenter
AND per.id = phone.personid
AND phone.name = '_eClub_PhoneSMS'
LEFT JOIN
    relatives r
ON
    r.center = per.center
AND r.id = per.id
AND r.rtype = 3  -- Company agreement
AND r.status < 2
LEFT JOIN 
    companyagreements ca 
ON     
    ca.center = r.relativecenter 
    and ca.id = r.relativeid
    and ca.subid = r.relativesubid	
LEFT JOIN
    persons company
ON
    company.center = ca.center
AND company.id = ca.id
JOIN       
(
        SELECT
                rank() over (partition BY j.person_center, j.person_id, j.ref_center, j.ref_id ORDER BY j.creation_time DESC) AS rnk,
                j.person_center AS p_center,
                j.person_id AS p_id,
                j.ref_center AS sub_center,
                j.ref_id AS sub_id,
                j.creation_time
        FROM
                journalentries j
        WHERE
                j.jetype = 18 -- 'EFT subscription termination'
                AND j.state = 'ACTIVE'
) je
ON
        je.rnk = 1
        AND per.center = je.p_center
        AND per.id = je.p_id
        AND s.center = je.sub_center
        AND s.id = je.sub_id	
WHERE
    s.end_date >= params.fromdate 
    AND s.end_date <= params.todate 
    AND s.sub_state not in (3,4,5,6)