-- The extract is extracted from Exerp on 2026-02-08
-- Used for lock down in Nordjylland to find all members without freeze/free period in the period 7/11-3/12.  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            TO_DATE('2021-04-07','YYYY-MM-DD')  AS STARTDATE,
            TO_DATE('2021-04-08','YYYY-MM-DD') AS ENDDATE
        FROM
            DUAL
    )
SELECT
        s.owner_center || 'p' || s.owner_id AS PersonId,
        b.center ||'ss'|| b.id              AS SubscriptionId
        /*s.start_date                        AS "Subscription Start date",
        s.end_date                          AS "Subscription End date",
        s.billed_until_date,
        s.state,
    1 as threadnumber,
        b.CENTER,
        b.ID,
        TO_CHAR(b.STARTDATE,'YYYY-MM-DD') AS STARTDATE,
        TO_CHAR(b.ENDDATE,'YYYY-MM-DD') AS ENDDATE,
        b.TEXT,
        b.TRANSFERDATE,
        b.FREE_ACTUAL_LENGTH,
        b.FREE_THEORIC_LENGTH*/
FROM
(
        SELECT DISTINCT
                a.center,
                a.id,
                a.freezestart AS startdate,
                a.freezeend   AS enddate,
                'COVID-19 measures (ST-XXXXX)'    AS Text,
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
                        to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center), 'YYYY-MM-DD'), 'YYYY-MM-DD') AS TransferDate                  
                FROM
                (
                        SELECT
                                DISTINCT
                                s.center,
                                s.id
                        FROM 
                                FW.PERSONS p
                        CROSS JOIN params 
                        JOIN
                                FW.SUBSCRIPTIONS s 
                                        ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID
                        JOIN
                                FW.SUBSCRIPTIONTYPES st
                                        ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
                        WHERE
                                s.START_DATE <= params.ENDDATE
                                AND 
                                (
                                        s.END_DATE IS NULL
                                        OR
                                        s.END_DATE >= params.STARTDATE
                                )
                                -- Exclude STAFF 
                                AND p.PERSONTYPE != 2 
                                -- Include only EFT
                                AND st.ST_TYPE = 1
                                AND s.center IN (169,203,204,206,210,271)
                ) sub
                JOIN SUBSCRIPTIONS s ON sub.CENTER = s.CENTER AND sub.ID = s.ID
                CROSS JOIN params
                JOIN SUBSCRIPTIONTYPES st
                        ON
                                st.center = s.SUBSCRIPTIONTYPE_CENTER
                                AND st.id = s.SUBSCRIPTIONTYPE_id
                                AND st.st_type = 1
                LEFT JOIN SUBSCRIPTION_REDUCED_PERIOD srd
                        ON
                                srd.subscription_center = s.center
                                AND srd.subscription_id = s.id
                                AND srd.state = 'ACTIVE'
                                AND srd.start_date <= greatest(params.StartDate, s.start_date)
                                AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),params.EndDate)
                /* for getting transfer date and move the free period start date if needed */
                LEFT JOIN STATE_CHANGE_LOG scl
                        ON
                            scl.center = s.center
                            AND scl.id = s.id
                            AND scl.stateid = 8
                            AND scl.sub_state = 6
                            AND scl.entry_type = 2
                            AND longtodateC(scl.book_start_time, scl.center) > s.start_date
                WHERE
                    s.state IN (2,4,8)
                    /* Exclude already fully period free/freeze/savedfree days member */
                    AND
                    srd.id IS NULL
                    /* Exlcude subscription starting after free period end date */
                    --AND s.start_date <= params.ENDDATE
                    /* Exclude subscription ended before free period start date */
                    --AND (s.end_date IS NULL OR s.end_date >= params.STARTDATE)  
        ) a
) b
JOIN
    FW.SUBSCRIPTIONS s
ON
    s.center = b.center
    AND s.id = b.id
WHERE
    b.free_actual_length != b.free_theoric_length