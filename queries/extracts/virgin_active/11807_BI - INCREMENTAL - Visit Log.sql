WITH
    params AS Materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$  AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint
            ) AS TODATE
    )
SELECT
    (c.id)::CHARACTER VARYING(255)     AS "VISIT_ID",
    c.checkin_center                   AS "CENTER_ID",
    cp.external_id                     AS "PERSON_ID",
    (p.center)::CHARACTER VARYING(255) AS "HOME_CENTER_ID",
    TO_CHAR(longtodatec((c.checkin_time)::DOUBLE PRECISION, (c.checkin_center)::DOUBLE PRECISION),
    'yyyy-MM-dd'::text) AS "CHECK_IN_DATE",
    TO_CHAR(longtodatec((c.checkin_time)::DOUBLE PRECISION, (c.checkin_center)::DOUBLE PRECISION),
    'HH24:MI:SS'::text) AS "CHECK_IN_TIME",
    TO_CHAR(longtodatec((c.checkout_time)::DOUBLE PRECISION, (c.checkin_center)::DOUBLE PRECISION),
    'yyyy-MM-dd'::text) AS "CHECK_OUT_DATE",
    TO_CHAR(longtodatec((c.checkout_time)::DOUBLE PRECISION, (c.checkin_center)::DOUBLE PRECISION),
    'HH24:MI:SS'::text) AS "CHECK_OUT_TIME",
    bi_decode_field('CHECKINS'::CHARACTER VARYING, 'CHECKIN_RESULT'::CHARACTER VARYING,
    c.checkin_result) AS "CHECK_IN_RESULT",
    CASE
        WHEN (c.card_checked_in = 1)
        THEN 'TRUE'::text
        ELSE 'FALSE'::text
    END            AS "CARD_CHECKED_IN",
    c.checkin_time AS "ETS"
FROM
    params,
    checkins c
LEFT JOIN
    persons p
ON
    p.center = c.person_center
    AND p.id = c.person_id
JOIN
    persons cp
ON
    cp.center = p.transfers_current_prs_center
    AND cp.id = p.transfers_current_prs_id
WHERE
    c.checkin_time >= PARAMS.FROMDATE
    AND c.checkin_time < PARAMS.TODATE
    AND c.checkin_CENTER IN ($$scope$$)