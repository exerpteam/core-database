SELECT
    MEM.external_id      AS "MEMBER ID",
    s.center||'ss'||s.id AS "SUBSCRIPTION ID",
    
    s.start_date         AS "SUBSCRIPTION START DATE",
    S.end_date           AS "SUBSCRIPTION END DATE",
    CASE
        WHEN S.STATE =1
        THEN 'AWAITING ACTIVATION (DEPRECATED)'
        WHEN S.STATE =2
        THEN 'ACTIVE'
        WHEN S.STATE =3
        THEN 'ENDED'
        WHEN S.STATE =4
        THEN 'FROZEN'
        WHEN S.STATE =5
        THEN 'CANCELLED (DEPRECATED)'
        WHEN S.STATE =6
        THEN 'NOT PAID (DEPRECATED)'
        WHEN S.STATE =7
        THEN 'WINDOW'
        WHEN S.STATE =8
        THEN 'CREATED'
        WHEN S.STATE =9
        THEN 'ENDED TRANSFERRED (DEPRECATED)'
        WHEN S.STATE =10
        THEN 'CREATED TRANSFERRED (DEPRECATED)'
        ELSE 'UNKWOWN'
    END AS "SUBSCRIPTION STATE",
    PR.NAME AS "PRODUCT NAME",
    CASE
        WHEN ST.ST_TYPE =0
        THEN 'PIF'
        WHEN ST.ST_TYPE = 1
        THEN 'PAP'
        WHEN st.st_type = 2
        THEN 'Clipcard (Recurring clipcard)'
        WHEN st.st_type = 3
        THEN 'Course'
    END                   AS "SUBSCRIPTION TYPE",
EMP.FULLNAME,
    EMP.center||'p'||EMP.id      AS "ASSIGNED STAFF PERSON ID",
    sales_emp.external_id AS "SOLD BY EMPLOYEE",
    CASE
        WHEN sales_emp.external_id = emp.external_id
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "SALE SAME AS ASSIGNED"
    --    ss.*
FROM
    subscriptions s
JOIN
    persons emp
ON
    s.assigned_staff_center=emp.center
AND s.assigned_staff_id=emp.id
JOIN
    SUBSCRIPTIONTYPES ST
ON
    ST.CENTER = S.SUBSCRIPTIONTYPE_CENTER
AND ST.ID = S.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS PR
ON
    PR.CENTER = ST.CENTER
AND PR.ID = ST.ID
JOIN
    lifetime.subscription_sales ss
ON
    s.center = ss.subscription_center
AND s.id = ss.subscription_id
JOIN
    lifetime.employees e
ON
    e.center = ss.employee_center
AND e.id = ss.employee_id
JOIN
    persons sales_emp
ON
    e.personcenter=sales_emp.center
AND e.personid=sales_emp.id
JOIN
    PERSONS MEM
ON
    S.owner_center=MEM.CENTER
AND S.owner_id=MEM.ID
WHERE
    EMP.center||'p'||EMP.id IN ($$personid$$)
    AND S.STATE IN (:state)
    ORDER BY 4
    --s.assigned_staff_center IN (262)AND s.assigned_staff_id IN (229) limit 1000
    --262p229
    --262emp31