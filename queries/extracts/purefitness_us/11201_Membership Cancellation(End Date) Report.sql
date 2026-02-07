SELECT
    scStopstaff.external_id                                                                             AS "External Id",
    scStopstaff.center || 'p' || scStopstaff.id                                                         AS "Person Id",
    s.CENTER || 'ss' || s.ID                                                                            AS "Subscription Id",
    prod.name                                                                                           AS "Product Name",
    s.subscription_price                                                                                AS "Subscription Price",
    TO_CHAR(s.end_date, 'YYYY-MM-DD')                                                                   AS "Subscription End Date",
    TO_CHAR(longtodatec(scStop.change_time, scStop.old_subscription_center), 'YYYY-MM-DD')              AS "Created Date",
    scStopstaff.center                                                                                  AS "Center Id",
    scStopstaff.FULLNAME                                                                                AS "Person Name",
CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
    'Direct Debit subscription termination'                                                             AS "Subject",
    p.fullname                                                                                          AS "Created By"
FROM
        subscriptions s 
JOIN
        SUBSCRIPTION_CHANGE scStop
ON
        s.center= scStop.old_subscription_center AND s.id= scStop.old_subscription_id
JOIN
        products prod
ON
        prod.center = s.subscriptiontype_center AND prod.id = s.subscriptiontype_id
JOIN
        persons scStopstaff
ON
        s.OWNER_CENTER = scStopstaff.CENTER AND s.OWNER_ID = scStopstaff.ID
LEFT JOIN
        employees escStopEmp
ON
        escStopEmp.center = scStop.EMPLOYEE_CENTER AND escStopEmp.id = scStop.EMPLOYEE_ID
LEFT JOIN
        persons p
ON
        escStopEmp.PERSONCENTER = p.center AND escStopEmp.PERSONID =p.id
WHERE
        scStop.TYPE = 'END_DATE' and  
        scStop.CANCEL_TIME  is null and 
        scStopstaff.center IN (:scope) and   
        s.end_date >= to_date(:fromDate, 'YYYY-MM-DD HH24:MI:SS') and 
        s.end_date <= to_date(:toDate, 'YYYY-MM-DD HH24:MI:SS');