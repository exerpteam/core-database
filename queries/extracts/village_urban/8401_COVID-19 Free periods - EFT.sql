WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date('21-03-2020', 'dd-MM-yyyy') AS StartDate,
            to_date('30-06-2020', 'dd-MM-yyyy') AS EndDate
        FROM DUAL
    )
SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS SubscriptionId,
    s.start_date,
    s.end_date,
    s.billed_until_date,
    existsrd.start_date AS ExistingSavedFreezStart,
    existsrd.end_date   AS ExistingSavedFreezeEnd
    --    COUNT(*)
FROM
    subscriptions s
CROSS JOIN
    params
JOIN
    subscriptiontypes st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_id
    AND st.st_type = 1
LEFT JOIN
    subscription_reduced_period existsrd
ON
    existsrd.subscription_center = s.center
    AND existsrd.subscription_id = s.id
    AND existsrd.state = 'ACTIVE'
    AND existsrd.start_date <= params.EndDate
    AND existsrd.end_date >= params.startdate 	
LEFT JOIN
    subscription_reduced_period srd
ON
    srd.subscription_center = s.center
    AND srd.subscription_id = s.id
    AND srd.state = 'ACTIVE'
    AND srd.start_date <= params.StartDate
    AND srd.end_date >= params.EndDate
WHERE
    s.owner_center IN ($$Scope$$)
    
    AND s.state IN (2,4,8)
    /* Exclude already fully period free/freeze/savedfree days member */
    AND srd.id IS NULL
    /* Exlcude subscription starting after free period end date */
    AND s.start_date <= params.EndDate
    /* Exclude subscription ended before free period start date */
    AND (
        s.end_date IS NULL
        OR s.end_date >= params.StartDate) 
   /* Exclude partial free period added until subscription end date. Free period end date is same as subscription end date */
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscription_reduced_period srd1
        WHERE
            srd1.subscription_center = s.center
            AND srd1.subscription_id = s.id
            AND srd1.state = 'ACTIVE'
            AND srd1.start_date <= params.StartDate
            AND srd1.end_date = COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')))	