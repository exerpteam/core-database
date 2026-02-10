-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9691
SELECT
    p.center||'p'||p.id "Person ID",
    p.fullname AS "Member Name",
    pr.name    AS "Group Name",
    CASE st.ST_TYPE
        WHEN 0     THEN 'Paid In Full'
        WHEN 1     THEN 'Recurring'
        WHEN 2     THEN 'Clipcard'
        WHEN 3     THEN 'Course'
    END AS "Billing Type",
    TO_CHAR(s.start_date,'MM/DD/YYYY') AS "Start Date",
    TO_CHAR(s.end_date,'MM/DD/YYYY')   AS "Expiration Date",
    sp.fullname  AS "Sales Employee",
    email.txtvalue      AS "E-mail",
    phone.txtvalue      AS "Phone",
    'Active'     AS "Status From",
    'Expired'    AS "Status To"
FROM
    subscriptions s
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND st.st_type = 0 -- only cash
JOIN
    products pr
ON
    st.center = pr.center
AND st.id = pr.id
JOIN
    persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
LEFT JOIN
    SUBSCRIPTION_SALES ss
ON
    s.center = ss.subscription_center
    AND s.id = ss.subscription_id
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
AND emp.ID = ss.EMPLOYEE_ID
LEFT JOIN
    PERSONS sp
ON
    sp.CENTER = emp.PERSONCENTER
AND sp.ID = emp.PERSONID
LEFT JOIN
    person_ext_attrs email
ON
    p.center = email.personcenter
    AND p.id = email.personid
    AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs phone
ON
    p.center = phone.personcenter
    AND p.id = phone.personid
    AND phone.name = '_eClub_PhoneSMS'            
WHERE
    s.center IN ($$scope$$)
AND s.end_date IS NOT NULL
AND s.end_date BETWEEN $$from_date$$ AND $$to_date$$
AND s.sub_state NOT IN (3,4,10,5,6)
    --Not ('UPGRADED','DOWNGRADED','CHANGED','EXTENDED','TRANSFERRED')
