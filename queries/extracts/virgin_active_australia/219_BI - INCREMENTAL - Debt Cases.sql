-- This is the version from 2026-02-05
--  
WITH
    params AS  materialized
    (
        SELECT
            c.id,
            datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '5 days',
            'YYYY-MM-DD HH24:MI'), c.time_zone) AS FROMDATE,
            datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 days',
            'YYYY-MM-DD HH24:MI'), c.time_zone) AS TODATE
        FROM
            centers c
        WHERE
            id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    (
        SELECT
            ((cc.center || 'ccol'::text) || cc.id) AS "DEBT_CASE_ID",
            cc.center                              AS "CENTER_ID",
            CASE
                WHEN ((cp.sex)::text <> 'C'::text)
                THEN cp.external_id
                ELSE NULL::CHARACTER VARYING
            END AS "PERSON_ID",
            CASE
                WHEN ((cp.sex)::text = 'C'::text)
                THEN cp.external_id
                ELSE NULL::CHARACTER VARYING
            END AS "COMPANY_ID",
            TO_CHAR(longtodatec((cc.start_datetime)::DOUBLE PRECISION, (cc.center)::DOUBLE
            PRECISION), 'yyyy-MM-dd'::text) AS "START_DATE",
            cc.amount                       AS "AMOUNT",
            CASE
                WHEN (cc.closed = 0)
                THEN 'FALSE'::text
                WHEN (cc.closed = 1)
                THEN 'TRUE'::text
                ELSE NULL::text
            END AS "CLOSED",
            TO_CHAR(longtodatec((cc.closed_datetime)::DOUBLE PRECISION, (cc.center)::DOUBLE
            PRECISION), 'yyyy-MM-dd'::text) AS "CLOSED_DATE",
            cc.currentstep                  AS "CURRENT_STEP",
            cc.last_modified                AS "ETS"
        FROM
            ((cashcollectioncases cc
        JOIN
            persons p
        ON
            (((
                        p.center = cc.personcenter)
                AND (
                        p.id = cc.personid))))
        JOIN
            persons cp
        ON
            (((
                        cp.center = p.transfers_current_prs_center)
                AND (
                        cp.id = p.transfers_current_prs_id))))
        WHERE
            (
                cc.missingpayment = 1) ) biview
JOIN
    PARAMS
ON
    params.id = biview."CENTER_ID"
WHERE
    biview."ETS" >= PARAMS.FROMDATE
AND biview."ETS" < PARAMS.TODATE