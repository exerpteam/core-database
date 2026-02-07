SELECT distinct
    c.name        AS "Club Name",
    p.center||'p'||p.id AS "Person ID",
    p.firstname as "First Name",
    p.lastname  as "Last Name",
    p.first_active_start_date as "Member Since Date",
    TO_CHAR(p.birthdate,'mm/dd/yyyy')                            AS "Birth Date",
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS "Age", 
    CASE
        WHEN p.PERSONTYPE = 0
        THEN 'PRIVATE'
        WHEN p.PERSONTYPE = 1
        THEN 'STUDENT'
        WHEN p.PERSONTYPE = 2
        THEN 'STAFF'
        WHEN p.PERSONTYPE = 3
        THEN 'FRIEND'
        WHEN p.PERSONTYPE = 4
        THEN 'CORPORATE'
        WHEN p.PERSONTYPE = 5
        THEN 'ONEMANCORPORATE'
        WHEN p.PERSONTYPE = 6
        THEN 'FAMILY'
        WHEN p.PERSONTYPE = 7
        THEN 'SENIOR'
        WHEN p.PERSONTYPE = 8
        THEN 'GUEST'
        WHEN p.PERSONTYPE = 9
        THEN 'CHILD'
        WHEN p.PERSONTYPE = 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END AS "Person Type",
    CASE
        WHEN p.STATUS = 0
        THEN 'LEAD'
        WHEN p.STATUS = 1
        THEN 'ACTIVE'
        WHEN p.STATUS = 2
        THEN 'INACTIVE'
        WHEN p.STATUS = 3
        THEN 'FREEZE'
        WHEN p.STATUS = 4
        THEN 'TRANSFERRED'
        WHEN p.STATUS = 5
        THEN 'DUPLICATE'
        WHEN p.STATUS = 6
        THEN 'PROSPECT'
        WHEN p.STATUS = 7
        THEN 'DELETED'
        WHEN p.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN p.STATUS = 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END                                  AS "Person Status",  
    subs.center||'ss'||subs.id as "Agreement ID", 
    s1.name       AS "Agreement Name",
    TO_CHAR(s1.start_date,'mm/dd/yyyy')   AS "Start Date",
    TO_CHAR(s1.end_date,'mm/dd/yyyy')     AS "Cancel Date",
    s1.subscription_price                 AS "Key Item Price",
    CASE
    WHEN s1.state = 1
    then 'Awaiting activation'
    when s1.state = 2
    then 'Active'
    when s1.state = 3
    then 'Ended'
    when s1.state = 4
    then 'Frozen'
    when s1.state = 5
    then 'Cancelled'
    when s1.state = 6
    then 'Not paid'
    when s1.state = 7
    then 'Window'
    when s1.state = 8
    then 'Created'
    when s1.state = 9
    then 'Ended transferred'
    when s1.state = 10
    then 'Created transferred'
    end as "Agreement State",
    --to_char(sp.price,'FM999990.00') as "Price (Next deduction)",
    sp.price                    AS "Price (Next deduction)",
    to_char(s1.nextDeductionDate,'mm/dd/yyyy')        AS "Next Deduction Date",
    to_char(s1.end_date,'mm/dd/yyyy')                 AS "Termination Date",
    p_sales.fullname            AS "Assigned employee (Name)",
    p_sales.center||'p'||p_sales.id         AS "Assigned employee (Id)",    
    company.fullname                     AS "Company",
    email.txtvalue                       AS "Email Address",
    phone.txtvalue                       AS "Phone",
    p.address1                         AS "Street Address",
    p.address2                         AS "Street Address 2",
    p.zipcode                          AS "Postal Code",
    p.city                             AS "City"
    
FROM
    (
        SELECT
            CASE
                  
                WHEN sub.billed_until_date IS NULL
                THEN sub.start_date
                 
                WHEN sub.billed_until_date <= (add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract
                    (epoch FROM now())*1000),sub.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1) - 1)
                THEN sub.billed_until_date + 1                  
                ELSE add_months(sub.billed_until_date, -1) + 1
            END AS nextDeductionDate,
            pd.name,
            sub.*,
            pag.individual_deduction_day ,
            add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*1000),sub.center
            ), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1) AS l
        FROM
            subscriptions sub
        JOIN
            payment_agreements pag
        ON
            pag.center = sub.payment_agreement_center
        AND pag.id = sub.payment_agreement_id
        AND pag.subid = sub.payment_agreement_subid
        JOIN
            products pd
        ON
            pd.center = sub.subscriptiontype_center
        AND pd.id = sub.subscriptiontype_id
        JOIN
            subscriptiontypes st
        ON
            st.center = pd.center
        AND st.id = pd.id
        WHERE
            sub.state IN (2,4,8)
          AND sub.center IN (:Scope)
        AND st.st_type > 0 ) s1
JOIN
    persons p
ON
    p.center = s1.owner_center
AND p.id = s1.owner_id
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
LEFT JOIN
    chelseapiers.person_ext_attrs email
ON
    p.center = email.personcenter
AND p.id = email.personid
AND email.name = '_eClub_Email'
LEFT JOIN
    chelseapiers.person_ext_attrs phone
ON
    p.center = phone.personcenter
AND p.id = phone.personid
AND phone.name = '_eClub_PhoneSMS'
JOIN
    centers c
ON
    s1.center = c.id
JOIN
    subscription_price sp
ON
    sp.subscription_center = s1.center
AND sp.subscription_id = s1.id
AND sp.from_date <= s1.nextDeductionDate
AND (
        sp.to_date IS NULL
    OR  sp.to_date >= s1.nextDeductionDate)
AND sp.cancelled = false   
JOIN
    persons p_sales
ON
    p_sales.center = s1.assigned_staff_center
AND p_sales.id = s1.assigned_staff_id
JOIN subscriptions subs on subs.center = sp.subscription_center and subs.id = sp.subscription_id
LEFT JOIN
    chelseapiers.relatives r
ON
    r.center = p.center
AND r.id = p.id
AND r.rtype = 3
LEFT JOIN
    chelseapiers.persons company
ON
    company.center = r.relativecenter
AND company.id = r.relativeid
WHERE
    (
        s1.end_date IS NULL
    OR  s1.end_date >= s1.nextDeductionDate)
AND s1.nextDeductionDate <= add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*
    1000),s1.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1)
and p.STATUS not in (4,5,7,8)
ORDER BY
    1,
    3