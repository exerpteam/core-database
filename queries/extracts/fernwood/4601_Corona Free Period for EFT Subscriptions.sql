-- The extract is extracted from Exerp on 2026-02-08
--  
/*
Fernwood free period due to corona virus problem
1. Exlcude any clubs. Not at the moment.
2. Add Free period for EFT subscription. From 01-04-2020 to 14-04-2020 both days included.
3. Exclude EFT subscription which are meeting following condition
a. Already fully free/freeze period cover for the above period.
b. Subscription starting after free period end date
c. Subscription with any end date.
4. Only members with odd bi weekly cycle
*/
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            1          AS ClubIdFrom,
            1200       AS ClubIdTo,
            CAST($$FreeFromDate$$ as DATE) AS StartDate,
            CAST ($$FreeToDate$$ as DATE) AS EndDate,
            0          AS numberOfDays,
			/* individual_deduction_day 4 is even 11 is odd bi weekly cycle*/
			11 AS oddweek
    )
SELECT
    s.owner_center || 'p' || s.owner_id AS PersonId,
    b.center ||'ss'|| b.id              AS SubscriptionId,
    s.start_date                        AS "Subscription Start date",
    s.end_date                          AS "Subscription End date",
    s.billed_until_date,
    b.*
FROM
    (
        SELECT DISTINCT
            -- gr.thread AS threadgroup,
            a.center,
            a.id,
            a.freezestart AS startdate,
            a.freezeend   AS enddate,
            'COVID-19'    AS Text,
            a.TransferDate,
            COALESCE(
                       (
                       SELECT
                           SUM(least(srd2.end_date,a.freezeend) - greatest(srd2.start_date,a.freezestart) + 1)
                       FROM
                           subscription_reduced_period srd2
                       WHERE
                           srd2.subscription_center = a.center
                           AND srd2.subscription_id = a.id
                           AND srd2.state = 'ACTIVE'
                           AND srd2.start_date <= a.freezeend
                           AND srd2.end_date >= a.freezestart), 0) AS free_actual_length,
            (a.freezeend - a.freezestart +1)                       AS free_theoric_length
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
                    least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate) AS freezeend,
                    --    greatest(s.start_date, params.StartDate) as freezestart_without_transfer,
                    greatest(greatest(s.start_date, to_date(COALESCE(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'),'1900-01-01'), 'YYYY-MM-DD')), params.StartDate) AS freezestart,
                    to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'), 'YYYY-MM-DD')                                                                            AS TransferDate
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
                    subscription_reduced_period srd
                ON
                    srd.subscription_center = s.center
                    AND srd.subscription_id = s.id
                    AND srd.state = 'ACTIVE'
                    AND srd.start_date <= greatest(params.StartDate, s.start_date)
                    AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
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
                    --   s.center >= params.ClubIdFrom
                    --   AND s.center <= params.ClubIdTo
                    s.center IN ($$Scope$$)
                    AND s.state IN (2,4,8)
                    /* Exclude already fully period free/freeze/savedfree days member */
                    AND srd.id IS NULL
                    /* Exlcude subscription starting after free period end date */
                    AND s.start_date <= params.EndDate
                    /* Exclude subscription with any end date */
                    AND s.end_date IS NULL) a
            /*   For threading purpose
            JOIN
            exerp_sud.d20200317_freeperiod_groups gr
            ON
            gr.center = a.center*/
    ) b
JOIN
    subscriptions s
ON
    s.center = b.center
    AND s.id = b.id
CROSS JOIN 	
	params
JOIN
    account_receivables ar
ON
    ar.customercenter = s.owner_center
    AND ar.customerid = s.owner_id
    AND ar.ar_type = 4
JOIN
    PAYMENT_ACCOUNTS pa
ON
    pa.CENTER = ar.CENTER
    AND pa.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pa.ACTIVE_AGR_CENTER
    AND pagr.ID = pa.ACTIVE_AGR_ID
    AND pagr.SUBID = pa.ACTIVE_AGR_SUBID	
WHERE
    b.free_actual_length != b.free_theoric_length
	AND pagr.individual_deduction_day = params.oddweek