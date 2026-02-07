-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-1824
between 2020-12-16 and 2021-04-30
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            TO_DATE('2020-12-16','YYYY-MM-DD')  AS STARTDATE,
            TO_DATE('2021-04-30','YYYY-MM-DD') AS ENDDATE
        FROM
            DUAL
    )
SELECT
        s.owner_center || 'p' || s.owner_id AS OldPersonId,
        cp.center||'p'||cp.id as NewPersonID,
        b.center ||'ss'|| b.id              AS SubscriptionId,
        DECODE(cp.persontype,0,'Private',1,'Student',2,'Staff',3,'Friend',4,'Corporate',5,'Onemancorporate',6,'Family',7,'Senior',8,'Guest',9,'Child',10,'External_Staff','Undefined') AS PersonType,
        decode(cp.status,0,'Lead',1,'Active',2,'Inactive',3,'TemporaryInactive',4,'Transferred',5,'Duplicate',6,'Prospect',7,'Deleted',8,'Anonymized',9,'Contact','Undefined') AS PersonStatus,
        to_char(s.start_date,'YYYY-MM-DD')  AS "Subscription Start date",
        to_char(s.end_date,'YYYY-MM-DD')  AS "Subscription End date",
        to_char(s.billed_until_date,'YYYY-MM-DD')  AS "Billed Until", 
        DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS SubscriptionState,
        DECODE(SUB_STATE,1,'NONE',2,'AWAITING_ACTIVATION',3,'UPGRADED',4,'DOWNGRADED',5,'EXTENDED',6,'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED',10,'CHANGED','Undefined') AS SUB_STATE,
        to_char(TransferDate,'YYYY-MM-DD'),
        b.free_actual_length,
        b.free_theoric_length

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
                                --AND p.PERSONTYPE != 2 
                                -- Include only EFT
                                AND st.ST_TYPE = 1
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
                    s.state IN (2,3,7,4,8)
                    /* Exclude already fully period free/freeze/savedfree days member */
                    AND
                    srd.id IS NULL
                    /* Exlcude subscription starting after free period end date */
                    AND s.start_date <= params.ENDDATE
                    /* Exclude subscription ended before free period start date */
                    AND (s.end_date IS NULL OR s.end_date >= params.STARTDATE)  
        ) a
) b
JOIN
    FW.SUBSCRIPTIONS s
ON
    s.center = b.center
    AND s.id = b.id
JOIN 
    PERSONS p
ON
    s.owner_center = p.center
    AND s.owner_id = p.id  
JOIN
    persons cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID          
WHERE
    b.free_actual_length != b.free_theoric_length
    AND b.free_theoric_length > 0
  