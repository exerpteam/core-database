SELECT
    s.owner_center,
    s.owner_id,
    CASE
        WHEN srd.ID IS NOT NULL
        THEN srd.start_date
        WHEN sp.ID IS NOT NULL
        THEN sp.FROM_DATE
        WHEN s.SUBSCRIPTION_PRICE = 0
        THEN s.START_DATE
    END AS start_date,
    CASE
        WHEN srd.ID IS NOT NULL
        THEN srd.end_date
        WHEN sp.ID IS NOT NULL
        THEN sp.TO_DATE
        WHEN s.SUBSCRIPTION_PRICE = 0
        THEN s.END_DATE
    END AS END_DATE,
    CASE
        WHEN srd.ID IS NOT NULL
        THEN (srd.end_date - srd.start_date)+1
        WHEN sp.ID IS NOT NULL
        THEN (sp.TO_DATE - sp.FROM_DATE)+1
        WHEN s.SUBSCRIPTION_PRICE = 0
        THEN 0
    END AS "Duration",
    /*CASE
    WHEN srd.ID IS NOT NULL
    THEN srd.employee_center||'emp'||srd.employee_id
    WHEN sp.ID IS NOT NULL
    THEN sp.employee_center||'emp'||sp.employee_id
    WHEN s.SUBSCRIPTION_PRICE = 0
    THEN s.CREATOR_CENTER||'emp'||s.CREATOR_ID
    END            AS employee,*/
    e.center||'emp'||e.id AS employee,
    staff.fullname        AS employee_name ,
    CASE
        WHEN srd.ID IS NOT NULL
            AND srd.TYPE = 'FREEZE'
        THEN 'freeze'
        WHEN srd.ID IS NOT NULL
            AND srd.TYPE IN ('FREE_ASSIGNMENT',
                             'SAVED_FREE_DAYS_USE')
        THEN 'Free period'
        WHEN sp.ID IS NOT NULL
        THEN 'price period'
        WHEN s.SUBSCRIPTION_PRICE = 0
        THEN 'subscription price'
    END AS "type"
FROM
    sats.subscriptions s
LEFT JOIN
    sats.SUBSCRIPTION_REDUCED_PERIOD srd
ON
    srd.subscription_center = s.center
    AND srd.subscription_id = s.id
    AND srd.START_DATE >= $$from_date$$
    AND srd.start_Date <= $$to_date$$
    AND srd.state = 'ACTIVE'
LEFT JOIN
    SATS.SUBSCRIPTION_PRICE SP
ON
    SP.SUBSCRIPTION_CENTER = s.CENTER
    AND SP.SUBSCRIPTION_ID = s.ID
    AND sp.CANCELLED = 0
    AND sp.PRICE = 0
    AND SP.FROM_DATE >= $$from_date$$
    AND sp.FROM_DATE <= $$to_date$$
LEFT JOIN
    sats.employees e
ON
    DECODE(srd.ID,NULL,DECODE(sp.ID,NULL,s.CREATOR_CENTER,sp.EMPLOYEE_CENTER),srd.employee_center) = e.center
    AND DECODE(srd.ID,NULL,DECODE(sp.ID,NULL,s.CREATOR_ID,sp.EMPLOYEE_ID),srd.employee_ID) = e.id
LEFT JOIN
    sats.persons staff
ON
    e.personcenter = staff.center
    AND e.personid = staff.id
WHERE
    s.owner_center IN ($$scope$$)
    -- and s.OWNER_ID = 381
    AND (
        srd.ID IS NOT NULL
        OR sp.ID IS NOT NULL
        OR s.SUBSCRIPTION_PRICE = 0)
    AND s.STATE IN (2,4)
/*    AND sp.ID IS NOT NULL */