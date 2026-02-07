-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-2198
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$From_Date$$                                        AS FromDateLong,
            ($$To_Date$$ + 86400 * 1000) - 1                   AS ToDateLong,
            longtodateC($$From_Date$$, 100)                      AS FromDate,
            longtodateC(($$To_Date$$ + 86400 * 1000) - 1, 100) AS ToDate
        FROM
            dual
    )
SELECT DISTINCT
    PERSONID,
    price AS "Membership price",
    CASE
        WHEN ABOVE_229 =1
            AND center_count <= 1
        THEN 1
        ELSE 0
    END AS "229orMore_VisitOneClubOrLess",
    CASE
        WHEN ABOVE_229 =1
            AND center_count > 1
        THEN 1
        ELSE 0
    END AS "229orMore_VisitMultipleClubs",
    CASE
        WHEN ABOVE_229 =0
            AND center_count <= 1
        THEN 1
        ELSE 0
    END AS "199orLess_VisitOneClubOrLess",
    CASE
        WHEN ABOVE_229 =0
            AND center_count > 1
        THEN 1
        ELSE 0
    END AS "199orLess_VisitMultipleClubs"
FROM
    (
        SELECT
            rca.center || 'p' || rca.id AS PERSONID,
            sp.price,
            CASE
                WHEN sp.price>=229
                THEN 1
                ELSE 0
            END                               AS ABOVE_229,
            COUNT(DISTINCT ch.checkin_center)    center_count
        FROM
            RELATIVES rca
        CROSS JOIN
            params
        JOIN
            STATE_CHANGE_LOG cascl
        ON
            cascl.center = rca.center
            AND cascl.id = rca.id
            AND cascl.entry_type = 4
            AND cascl.entry_start_time <= params.ToDateLong
            AND NVL(cascl.entry_end_time, params.FromDateLong) >= params.FromDateLong
            AND cascl.stateid = 1
        JOIN
            subscriptions s
        ON
            s.owner_center = rca.center
            AND s.owner_id = rca.id
            AND s.creation_time <= params.ToDateLong
            AND ((
                    s.start_date <= s.end_date
                    AND s.end_date >= params.FromDate )
                OR (
                    s.end_date IS NULL))
        JOIN
            subscription_price sp
        ON
            sp.subscription_center = s.center
            AND sp.subscription_id = s.id
            AND sp.from_date <= params.ToDate
            AND NVL(sp.to_date, params.FromDate) >= params.FromDate
            AND sp.price NOT BETWEEN 200 AND 228
        LEFT JOIN
            CHECKINS ch
        ON
            ch.PERSON_CENTER = rca.CENTER
            AND ch.PERSON_ID = rca.ID
            AND datetolongC(TO_CHAR( sp.from_date, 'YYYY-MM-dd HH24:MI' ),100) <= ch.CHECKIN_TIME
            AND datetolongC(TO_CHAR(NVL(sp.to_date,exerpsysdate()+999), 'YYYY-MM-dd HH24:MI' ),100) >= ch.CHECKIN_TIME
        WHERE
            rca.RELATIVECENTER = 116
            AND rca.RELATIVEID = 14412
            AND rca.RTYPE = 3
        GROUP BY
            rca.center,
            rca.id,
            sp.price )