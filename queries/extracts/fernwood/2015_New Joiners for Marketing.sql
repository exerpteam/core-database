SELECT DISTINCT
            c.SHORTNAME AS "Club Name"
          , p.CENTER || 'p' || p.ID AS "Member ID"
		  , p.external_id
          , p.firstname AS "First Name"
          , p.lastname AS "Last Name"
          , bi_decode_field('PERSONS', 'PERSONTYPE', p.persontype)      AS "Person Type"          
          , p.FIRST_ACTIVE_START_DATE AS "Join Date"
          , s.START_DATE AS "Start Date"
          , s.end_date AS "Cancellation Date"
          , prod.NAME                                                   AS "Subscription Name"
          , CASE
                WHEN ps.CENTER IS NOT NULL THEN 'Yes'
                ELSE 'No'
            END                                                         AS "Re-joiner"
          , pe.FULLNAME                                                 AS "Sales Person"
          , pes.firstname || ' ' || pes.lastname                        AS "Sold on behalf of"          
          , ss.SALES_DATE                                               AS "Change Date"
          ,CASE
                WHEN p.status = 0 THEN 'Lead'
                WHEN p.status = 1 THEN 'Active'
                WHEN p.status = 2 THEN 'Inactive'
                WHEN p.status = 3 THEN 'Temporary Inactive'
                WHEN p.status = 4 THEN 'Transfered'
                WHEN p.status = 5 THEN 'Duplicate'
                WHEN p.status = 6 THEN 'Prospect'
                WHEN p.status = 7 THEN 'Deleted'
                WHEN p.status = 8 THEN 'Anonymized'
                WHEN p.status = 9 THEN 'Contact'
                ELSE 'Unknown'
           END AS "Person Status"
          ,CASE
                WHEN s.state = 2 THEN 'Active'
                WHEN s.state = 3 THEN 'Ended'
                WHEN s.state = 4 THEN 'Frozen'
                WHEN s.state = 7 THEN 'Window'
                WHEN s.state = 8 THEN 'Created'
                ELSE 'Unknown'
           END AS "Subscription Status"
           ,email.txtvalue AS "Email"
FROM
        SUBSCRIPTION_SALES ss
JOIN
        CENTERS c
ON
        c.id = ss.SUBSCRIPTION_CENTER
JOIN
        SUBSCRIPTIONS s
ON
        s.CENTER = ss.SUBSCRIPTION_CENTER
        AND s.ID = ss.SUBSCRIPTION_ID
JOIN
        SUBSCRIPTIONTYPES st
ON
        st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
        PRODUCTS prod
ON
        prod.CENTER = st.CENTER
        AND prod.ID = st.ID
        AND prod.primary_product_group_id NOT IN (214,217,237)
        AND prod.name NOT IN ('12 Month Complimentary','3 Month Complimentary','6 Month Complimentary','Staff Payroll Subscription')
JOIN
        PERSONS p
ON
        p.CENTER = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
LEFT JOIN
        SUBSCRIPTIONS ps
ON
        ps.OWNER_CENTER = s.OWNER_CENTER
        AND ps.OWNER_ID = s.OWNER_ID
        AND ps.id < s.ID
        AND ps.START_DATE < s.START_DATE
JOIN
        EMPLOYEES emp
ON
        emp.CENTER = s.CREATOR_CENTER
        AND emp.ID = s.CREATOR_ID
JOIN
        PERSONS pe
ON
        pe.CENTER = emp.PERSONCENTER
        AND pe.ID = emp.PERSONID
LEFT JOIN     
        EMPLOYEES emps
ON
        emps.CENTER = ss.employee_center
        AND emps.ID = ss.employee_id
LEFT JOIN
        PERSONS pes
ON
        pes.CENTER = emps.PERSONCENTER
        AND pes.ID = emps.PERSONID 
LEFT JOIN 
        person_ext_attrs email
ON
        email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'        

WHERE 
        s.CREATION_TIME between 
        GETSTARTOFDAY(CAST (CAST (:StartDate AS DATE) AS TEXT),s.CENTER)
        AND GETENDOFDAY(CAST (CAST (:EndDate AS DATE) AS TEXT), s.CENTER)
        and s.center in (:scope)
