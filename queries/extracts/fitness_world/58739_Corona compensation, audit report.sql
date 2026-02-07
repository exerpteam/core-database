-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-12117
SELECT
    p.CENTER || 'p' || p.ID AS "MemberID",
    p.EXTERNAL_ID           AS "ExternalID",
    s.CENTER || 'ss' || s.ID AS "SubscriptionID",
    ccs.TXTVALUE            AS "CORONACOMPSUB",
    cca.TXTVALUE            AS "CORONACOMPADDON",
    freePeriods.TransferDate,
    (
        CASE
            WHEN freePeriods.FREE_DAYS_GIVEN IS NULL
            THEN 0
            ELSE freePeriods.FREE_DAYS_GIVEN
        END) AS FREE_DAYS_GIVEN,
    (
        CASE
            WHEN freePeriods.FREE_THEORIC_LENGTH IS NULL
            THEN 50
            ELSE freePeriods.FREE_THEORIC_LENGTH
        END) AS FREE_THEORIC_LENGTH,
    (
        CASE
            WHEN art.CENTER IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END) AS "500kr",
    (
        CASE
            WHEN sp.ID IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END) AS "20percent"
FROM
    FW.PERSONS p
JOIN
    FW.SUBSCRIPTIONS s
ON
    p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
LEFT JOIN
    FW.PERSON_EXT_ATTRS ccs
ON
    p.CENTER = ccs.PERSONCENTER
AND p.ID = ccs.PERSONID
AND ccs.NAME = 'CORONACOMPSUB'
LEFT JOIN
    FW.PERSON_EXT_ATTRS cca
ON
    p.CENTER = cca.PERSONCENTER
AND p.ID = cca.PERSONID
AND cca.NAME = 'CORONACOMPADDON'
LEFT JOIN
    (
        WITH
            params AS
            (
                SELECT
                    /*+ materialize */
                    TO_DATE('2020-03-12','YYYY-MM-DD') AS STARTDATE,
                    TO_DATE('2020-06-10','YYYY-MM-DD') AS ENDDATE
                FROM
                    DUAL
            )
        SELECT
            s.CENTER,
            s.ID,
            s.owner_center || 'p' || s.owner_id AS PersonId,
            b.center ||'ss'|| b.id              AS SubscriptionId,
            s.start_date                        AS "Subscription Start date",
            s.end_date                          AS "Subscription End date",
            s.billed_until_date,
            b.TransferDate,
            b.FREE_ACTUAL_LENGTH  AS FREE_DAYS_GIVEN,
            b.FREE_THEORIC_LENGTH    AS
        FROM
            (
                SELECT DISTINCT
                    a.center,
                    a.id,
                    a.freezestart                  AS startdate,
                    a.freezeend                    AS enddate,
                    'COVID-19 measures (ST-11413)' AS Text,
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
                               AND srd2.TYPE = 'FREE_ASSIGNMENT'
                               AND srd2.EMPLOYEE_CENTER = 100
                               AND srd2.EMPLOYEE_ID = 6113
                               AND srd2.start_date <= a.freezeend
                               AND srd2.end_date >= a.freezestart), 0) AS free_actual_length,
                    (a.freezeend - a.freezestart +1)                   AS free_theoric_length
                FROM
                    (
                        -- 7611 persons
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
                            least(COALESCE(s.end_date, to_date('01-01-2100', 'dd-MM-yyyy')),
                            params.EndDate) AS freezeend,
                            --    greatest(s.start_date, params.StartDate) as
                            -- freezestart_without_transfer,
                            greatest(greatest(s.start_date, to_date(COALESCE(TO_CHAR(longtodateC
                            (scl.book_start_time, scl.center), 'YYYY-MM-DD'),'1900-01-01'),
                            'YYYY-MM-DD')), params.StartDate) AS freezestart,
                            to_date(TO_CHAR(longtodateC(scl.book_start_time, scl.center),
                            'YYYY-MM-DD'), 'YYYY-MM-DD') AS TransferDate
                            --,srd.*
                        FROM
                            SUBSCRIPTIONS s
                        CROSS JOIN
                            params
                        JOIN
                            SUBSCRIPTIONTYPES st
                        ON
                            st.center = s.SUBSCRIPTIONTYPE_CENTER
                        AND st.id = s.SUBSCRIPTIONTYPE_id
                        AND st.st_type = 1
                        LEFT JOIN
                            SUBSCRIPTION_REDUCED_PERIOD srd
                        ON
                            srd.subscription_center = s.center
                        AND srd.subscription_id = s.id
                        AND srd.state = 'ACTIVE'
                        AND srd.start_date <= greatest(params.StartDate, s.start_date)
                        AND srd.end_date >= least(COALESCE(s.end_date, to_date('01-01-2100',
                            'dd-MM-yyyy')),params.EndDate)
                        AND srd.TYPE = 'FREE_ASSIGNMENT'
                        AND srd.EMPLOYEE_CENTER = 100
                        AND srd.EMPLOYEE_ID = 6113
                            /* for getting transfer date and move the free period start date if
                            needed */
                        LEFT JOIN
                            STATE_CHANGE_LOG scl
                        ON
                            scl.center = s.center
                        AND scl.id = s.id
                        AND scl.stateid = 8
                        AND scl.sub_state = 6
                        AND scl.entry_type = 2
                        AND longtodateC(scl.book_start_time, scl.center) > s.start_date
                        WHERE
                            s.owner_center IN (:Scope)
                        AND s.state IN (2,4,8)
                            /* Exclude already fully period free/freeze/savedfree days member */
                            --AND
                            --AND srd.id IS NULL
                            /* Exlcude subscription starting after free period end date */
                        AND s.start_date <= params.ENDDATE
                            /* Exclude subscription ended before free period start date */
                        AND (
                                s.end_date IS NULL
                            OR  s.end_date >= params.STARTDATE) ) a ) b
        JOIN
            FW.SUBSCRIPTIONS s
        ON
            s.center = b.center
        AND s.id = b.id ) freePeriods
ON
    freePeriods.CENTER = s.CENTER
AND freePeriods.ID = s.ID
LEFT JOIN
    FW.ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID
AND ar.AR_TYPE = 1
AND ar.STATE = 0
LEFT JOIN
    FW.AR_TRANS art
ON
    ar.CENTER = art.CENTER
AND ar.ID = art.ID
AND art.AMOUNT = 500
AND art.EMPLOYEECENTER = 100
AND art.EMPLOYEEID IN (6313,24518)
LEFT JOIN
    FW.SUBSCRIPTION_PRICE sp
ON
    s.CENTER = sp.SUBSCRIPTION_CENTER
AND s.ID = sp.SUBSCRIPTION_ID
AND sp.CANCELLED = 0
AND sp.EMPLOYEE_CENTER = 100
AND sp.EMPLOYEE_ID = 6113
AND sp.FROM_DATE = TO_DATE('2020-06-10','YYYY-MM-DD')
AND sp.COMENT = 'ST-11292 COVID19 discount'
WHERE
    p.center IN (:Scope)
AND s.STATE IN (2,4)
AND s.START_DATE < TO_DATE('2020-06-11','YYYY-MM-DD')