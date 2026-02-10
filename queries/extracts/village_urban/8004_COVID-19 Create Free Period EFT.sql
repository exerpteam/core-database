-- The extract is extracted from Exerp on 2026-02-08
--  
/*
VU free period due to corona virus problem
*/
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            cast($$FreeFromDate$$ as DATE) AS StartDate,
            cast($$FreeToDate$$ as DATE) AS EndDate,
            0       AS numberOfDays
    )
SELECT
    b.CenterName,
    (
        CASE p.status
            WHEN 0
            THEN 'LEAD'
            WHEN 1
            THEN 'ACTIVE'
            WHEN 2
            THEN 'INACTIVE'
            WHEN 3
            THEN 'TEMPORARYINACTIVE'
            WHEN 4
            THEN 'TRANSFERRED'
            WHEN 5
            THEN 'DUPLICATE'
            WHEN 6
            THEN 'PROSPECT'
            WHEN 7
            THEN 'DELETED'
            WHEN 8
            THEN 'ANONYMIZED'
            WHEN 9
            THEN 'CONTACT'
            ELSE 'Undefined'
        END)                            AS "Person Status",
    s.owner_center || 'p' || s.owner_id AS PersonId,
    b.center ||'ss'|| b.id              AS SubscriptionId,
    s.start_date                        AS "Subscription Start date",
    s.end_date                          AS "Subscription End date",
    s.billed_until_date,
    CASE
        WHEN s.STATE = 2
        THEN 'ACTIVE'
        WHEN s.STATE = 3
        THEN 'ENDED'
        WHEN s.STATE = 4
        THEN 'FROZEN'
        WHEN s.STATE = 7
        THEN 'WINDOW'
        WHEN s.STATE = 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Subscription state",
    CASE
        WHEN s.SUB_STATE = 1
        THEN 'NONE'
        WHEN s.SUB_STATE = 2
        THEN 'AWAITING_ACTIVATION'
        WHEN s.SUB_STATE = 3
        THEN 'UPGRADED'
        WHEN s.SUB_STATE = 4
        THEN 'DOWNGRADED'
        WHEN s.SUB_STATE = 5
        THEN 'EXTENDED'
        WHEN s.SUB_STATE = 6
        THEN 'TRANSFERRED'
        WHEN s.SUB_STATE = 7
        THEN 'REGRETTED'
        WHEN s.SUB_STATE = 8
        THEN 'CANCELLED'
        WHEN s.SUB_STATE = 9
        THEN 'BLOCKED'
        WHEN s.SUB_STATE = 10
        THEN 'CHANGED'
        ELSE 'Undefined'
    END AS "Subscription sub state",
    (
        CASE
            WHEN s.BINDING_END_DATE > CURRENT_DATE
            THEN s.BINDING_PRICE
            ELSE s.SUBSCRIPTION_PRICE
        END)           AS "Subscription price",
    b.SubscriptionName AS "Subscription name",
    /*floor((row_number() over(order by b.center,b.id))/6000)+1 as threadnumber,
    b.CENTER,
    b.ID, */
    TO_CHAR(b.STARTDATE,'YYYY-MM-DD') AS Freeze_STARTDATE,
    TO_CHAR(b.ENDDATE,'YYYY-MM-DD')   AS Freeze_ENDDATE,
    b.TEXT,
    b.TRANSFERDATE,
    b.FREE_ACTUAL_LENGTH,
    b.FREE_THEORIC_LENGTH
FROM
    (
        SELECT DISTINCT
            a.CenterName,
            a.center,
            a.id,
            a.freezestart       AS startdate,
            a.freezeend         AS enddate,
            'COVID-19 measures' AS Text,
            a.SubscriptionName,
            a.TransferDate,
            COALESCE(
                       (
                       SELECT
                           SUM(least(srd2.end_date,a.freezeend) - greatest(srd2.start_date,
                           a.freezestart) + 1)
                       FROM
                           subscription_reduced_period srd2
                       WHERE
                           srd2.subscription_center = a.center
                       AND srd2.subscription_id = a.id
                       AND srd2.state = 'ACTIVE'
                       AND srd2.start_date <= a.freezeend
                       AND srd2.end_date >= a.freezestart), 0) AS free_actual_length,
            (a.freezeend - a.freezestart +1)                   AS free_theoric_length
        FROM
            (
                SELECT
                    c.NAME AS CenterName,
                    s.center,
                    s.id,
                    s.owner_center || 'p' || s.owner_id AS PersonId,
                    s.center || 'ss' || s.id            AS SubscriptionId,
                    pr.NAME                             AS SubscriptionName,
                    --s.start_date,
                    --s.end_date,
                    --s.refmain_center,
                    --s.refmain_id,
                    least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
                    AS freezeend,
                    --    greatest(s.start_date, params.StartDate) as freezestart_without_transfer,
                    greatest(greatest(s.start_date, to_date(COALESCE(TO_CHAR(longtodateC
                    (scl.book_start_time, scl.center), 'YYYY-MM-DD'),'1900-01-01'), 'YYYY-MM-DD')),
                    params.StartDate) AS freezestart,
                    to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'),
                    'YYYY-MM-DD') AS TransferDate
                    --    COUNT(*)
                FROM
                    subscriptions s
                    /* Only needed if we have to INCLUDE/EXCLUDE countries */
                JOIN
                    centers c
                ON
                    s.center = c.id
                AND c.COUNTRY = 'GB'
                CROSS JOIN
                    params
                JOIN
                    subscriptiontypes st
                ON
                    st.center = s.SUBSCRIPTIONTYPE_CENTER
                AND st.id = s.SUBSCRIPTIONTYPE_id
                AND st.st_type = 1
                    /* Only neeeded if we have to INCLUDE/EXCLUDE a list of Products */
                JOIN
                    PRODUCTS pr
                ON
                    pr.center = st.center
                AND pr.id = st.id
                LEFT JOIN
                    subscription_reduced_period srd
                ON
                    srd.subscription_center = s.center
                AND srd.subscription_id = s.id
                AND srd.state = 'ACTIVE'
                AND srd.start_date <= greatest(params.StartDate, s.start_date)
                AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy'))
                    ,params.EndDate)
                    /* for getting transfer date and move the free period start date if needed */
                LEFT JOIN
                    state_change_log scl
                ON
                    scl.center = s.center
                AND scl.id = s.id
                AND scl.stateid = 8
                AND scl.sub_state = 6
                AND scl.entry_type = 2
                AND longtodateC(scl.book_start_time, scl.center) > s.start_date
                WHERE
                    s.center IN (:Scope)
                AND s.state IN (2,4,8)
                    /* Exclude already fully period free/freeze/savedfree days member */
                AND srd.id IS NULL
                    /* Exclude free subscription UK316, UK317 */
                AND pr.GLOBALID NOT IN ('UK316',
                                        'UK317')
                    /* Exlcude subscription starting after free period end date */
                AND s.start_date <= params.EndDate
                    /* Exclude subscription ended before free period start date */
                AND (
                        s.end_date IS NULL
                    OR  s.end_date >= params.StartDate) ) a ) b
JOIN
    subscriptions s
ON
    s.center = b.center
AND s.id = b.id
JOIN
    persons p
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
WHERE
    b.free_actual_length != b.free_theoric_length
ORDER BY
    1