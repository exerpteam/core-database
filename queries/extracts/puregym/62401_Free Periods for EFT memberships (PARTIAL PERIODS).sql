-- The extract is extracted from Exerp on 2026-02-08
--  
/*
PG free period due to corona virus problem
1. Exlcude any clubs. Needs to confirm in the meeting.
2. Add Free period for EFT subscription. From 16-03-2020 to 30-03-2020 both days included. Needs to
confirm in the meeting.
3. Exclude EFT subscription which are meeting following condition
a. Already fully free/freeze period cover for the above period.
b. Subscription starting after free period end date
c. Subscription ended before free period start date.
d. Subscription ended before above free period end date and already free period added until
subscription end date. This is avoid those appear again in the extract.
e. Subscription ended same day as billed until date and member has another EFT subscription
starting in X days from cureent subscription end date. The credit will be used new subscription.
*/
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            CAST($$FreeFromDate$$ AS DATE) AS StartDate,
            CAST($$FreeToDate$$ AS DATE) AS EndDate,
            0                                   AS numberOfDays
        
    )
SELECT
        a.PersonId,
        a.SubscriptionId,
        a.start_date AS "Subscription Start date",
        a.end_date AS "Subscription End date",
        a.billed_until_date,
        --floor((row_number() over(order by a.center,a.id))/6000)+1 as threadnumber,
        --DISTINCT   
        a.center,
        a.id,
        TO_CHAR(a.freezestart,'YYYY-MM-DD') AS startdate,
        TO_CHAR(a.freezeend ,'YYYY-MM-DD')  AS enddate,
        'COVID-19'    AS Text
    --, 'CONDITIONAL' as type
    --, a.*, a.freezeend - a.freezestart + 1 as FreezeLength
FROM
    (
        SELECT
            s.center,
            s.id,
            s.owner_center || 'p' || s.owner_id AS PersonId,
            s.center || 'ss' || s.id            AS SubscriptionId,
            s.start_date,
            s.end_date,
            s.billed_until_date,
            s.refmain_center,
            s.refmain_id,
            --    existsrd.start_date AS ExistingSavedFreezStart,
            --    existsrd.end_date   AS ExistingSavedFreezeEnd,
            --    existsrd.type       AS ExistingSavedFreezeType,
            CASE
                WHEN srd_partial_end.id IS NOT NULL
                THEN srd_partial_end.start_date - 1
                ELSE least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate
                    )
            END AS freezeend,
            CASE
                WHEN srd_partial_start.id IS NOT NULL
                THEN srd_partial_start.end_date + 1
                ELSE greatest(s.start_date, params.StartDate)
            END AS freezestart
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
            /* LEFT JOIN
            subscription_reduced_period existsrd
            ON
            existsrd.subscription_center = s.center
            AND existsrd.subscription_id = s.id
            AND existsrd.state = 'ACTIVE'
            AND existsrd.start_date <= params.EndDate
            AND existsrd.end_date >= params.startdate */
        LEFT JOIN
            subscription_reduced_period srd
        ON
            srd.subscription_center = s.center
        AND srd.subscription_id = s.id
        AND srd.state = 'ACTIVE'
        AND srd.start_date <= greatest(params.StartDate, s.start_date)
        AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),
            params.EndDate)
        LEFT JOIN
            subscription_reduced_period srd_partial_start
        ON
            srd_partial_start.subscription_center = s.center
        AND srd_partial_start.subscription_id = s.id
        AND srd_partial_start.state = 'ACTIVE'
        AND srd_partial_start.start_date <= greatest(params.StartDate, s.start_date)
        AND srd_partial_start.end_date < least(COALESCE(s.end_date, to_date('01-01-2100',
            'dd-MM-yyyy')),params.EndDate)
        AND srd_partial_start.end_date >= greatest(params.StartDate, s.start_date)
        LEFT JOIN
            subscription_reduced_period srd_partial_end
        ON
            srd_partial_end.subscription_center = s.center
        AND srd_partial_end.subscription_id = s.id
        AND srd_partial_end.state = 'ACTIVE'
        AND srd_partial_end.start_date > greatest(params.StartDate, s.start_date)
        AND srd_partial_end.start_date <= least(COALESCE(s.end_date, to_date('01-01-2100',
            'dd-MM-yyyy')),params.EndDate)
        AND srd_partial_end.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100',
            'dd-MM-yyyy')),params.EndDate)
        WHERE
        s.center IN (:Scope)
        AND s.state IN (2,4,8)
            /* Exclude already fully period free/freeze/savedfree days member */
        AND srd.id IS NULL
            /* only include those with one freeze/free period in the interval */
        AND (
                srd_partial_end.id IS NULL
            OR  srd_partial_start.id IS NULL)
            /* Exlcude subscription starting after free period end date */
        AND s.start_date <= params.EndDate
            /* Exclude subscription ended before free period start date */
        AND s.end_date IS NULL
        /* Exclude subscriptions from those product groups. Staff Subscription, GymFlex (reporting), Staff / PT Subscriptions MS, PGT */
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                WHERE
                    ppl.product_center = st.center
                    AND ppl.product_id = st.id
                    AND ppl.PRODUCT_GROUP_ID IN (401,801,6409, 11801))
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

    ) a
CROSS JOIN
    params
WHERE NOT EXISTS
    (
        SELECT
            1
        FROM
            subscription_reduced_period srd2
        WHERE
            srd2.subscription_center = a.center
        AND srd2.subscription_id = a.id
        AND srd2.state = 'ACTIVE'
        AND srd2.start_date <= a.freezestart
        AND srd2.end_date >= a.freezeend )
ORDER BY
    1,2,3