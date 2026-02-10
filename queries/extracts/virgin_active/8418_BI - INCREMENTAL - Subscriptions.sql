-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS Materialized
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
            cp.external_id                     AS "PERSON_ID",
            ((s.center || 'ss'::text) || s.id) AS "SUBSCRIPTION_ID",
            (s.center)::CHARACTER VARYING(255) AS "SUBSCRIPTION_CENTER",
            bi_decode_field('SUBSCRIPTIONS'::CHARACTER VARYING, 'STATE'::CHARACTER VARYING, s.state
            ) AS "STATE",
            bi_decode_field('SUBSCRIPTIONS'::CHARACTER VARYING, 'SUB_STATE'::CHARACTER VARYING,
            s.sub_state) AS "SUB_STATE",
            bi_decode_field('SUBSCRIPTIONTYPES'::CHARACTER VARYING, 'ST_TYPE'::CHARACTER VARYING,
            st.st_type)                                                           AS "RENEWAL_TYPE",
            ((s.subscriptiontype_center || 'prod'::text) || s.subscriptiontype_id) AS "PRODUCT_ID",
            TO_CHAR((s.start_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text)  AS "START_DATE",
            TO_CHAR(longtodatec((scstop.stop_change_time)::DOUBLE PRECISION, (s.center)::DOUBLE
            PRECISION), 'YYYY-MM-DD'::text)                                     AS "STOP_DATE",
            TO_CHAR((s.end_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text)       AS "END_DATE",
            TO_CHAR((s.billed_until_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text) AS
            "BILLED_UNTIL_DATE",
            TO_CHAR((s.binding_end_date)::TIMESTAMP WITH TIME zone, 'YYYY-MM-DD'::text) AS
            "BINDING_END_DATE",
            TO_CHAR(longtodatec((s.creation_time)::DOUBLE PRECISION, (s.center)::DOUBLE PRECISION),
            'YYYY-MM-DD'::text) AS "CREATION_DATE",
            CASE
                WHEN (s.invoiceline_center IS NOT NULL)
                THEN ((s.invoiceline_center || 'inv'::text) || s.invoiceline_id)
                ELSE NULL::text
            END AS "SALE_ID",
            CASE
                WHEN (s.invoiceline_center IS NOT NULL)
                THEN ((((s.invoiceline_center || 'inv'::text) || s.invoiceline_id) || 'ln'::text)
                    || s.invoiceline_subid)
                ELSE NULL::text
            END                  AS "JF_SALE_LOG_ID",
            s.subscription_price AS "SUBSCRIPTION_PRICE",
            s.binding_price      AS "BINDING_PRICE",
            CASE
                WHEN (st.is_addon_subscription = 0)
                THEN 'FALSE'::text
                WHEN (st.is_addon_subscription = 1)
                THEN 'TRUE'::text
                ELSE NULL::text
            END AS "REQUIRES_MAIN",
            CASE
                WHEN (s.is_price_update_excluded = 0)
                THEN 'FALSE'::text
                WHEN (s.is_price_update_excluded = 1)
                THEN 'TRUE'::text
                ELSE NULL::text
            END AS "SUB_PRICE_UPDATE_EXCLUDED",
            CASE
                WHEN (st.is_addon_subscription = 0)
                THEN 'FALSE'::text
                WHEN (st.is_addon_subscription = 1)
                THEN 'TRUE'::text
                ELSE NULL::text
            END AS "TYPE_PRICE_UPDATE_EXCLUDED",
            CASE
                WHEN (st.freezeperiodproduct_center IS NOT NULL)
                THEN ((st.freezeperiodproduct_center || 'prod'::text) || st.freezeperiodproduct_id)
                ELSE NULL::text
            END AS "FREEZE_PERIOD_PRODUCT_ID",
            CASE
                WHEN (s.transferred_center IS NOT NULL)
                THEN ((s.transferred_center || 'ss'::text) || s.transferred_id)
                ELSE NULL::text
            END AS "TRANSFERRED_TO",
            CASE
                WHEN (s.extended_to_center IS NOT NULL)
                THEN ((s.extended_to_center || 'ss'::text) || s.extended_to_id)
                ELSE NULL::text
            END AS "EXTENDED_TO",
            CASE
                WHEN (st.periodunit = 0)
                THEN 'WEEK'::text
                WHEN (st.periodunit = 1)
                THEN 'DAY'::text
                WHEN (st.periodunit = 2)
                THEN 'MONTH'::text
                WHEN (st.periodunit = 3)
                THEN 'YEAR'::text
                WHEN (st.periodunit = 4)
                THEN 'HOUR'::text
                WHEN (st.periodunit = 5)
                THEN 'MINUTE'::text
                WHEN (st.periodunit = 6)
                THEN 'SECOND'::text
                ELSE 'UNKNOWN'::text
            END            AS "PERIOD_UNIT",
            st.periodcount AS "PERIOD_COUNT",
            CASE
                WHEN (s.reassigned_center IS NOT NULL)
                THEN ((s.reassigned_center || 'ss'::text) || s.reassigned_id)
                ELSE NULL::text
            END                   AS "REASIGNED_TO",
            scstop.stop_person_id AS "STOP_PERSON_ID",
            TO_CHAR(longtodatec((scstop.stop_cancel_time)::DOUBLE PRECISION, (s.center)::DOUBLE
            PRECISION), 'YYYY-MM-DD'::text) AS "STOP_CANCEL_DATE",
            CASE
                WHEN (s.payment_agreement_center IS NOT NULL)
                THEN ((((s.payment_agreement_center || 'ar'::text) || s.payment_agreement_id) ||
                    'agr'::text) || s.payment_agreement_subid)
                ELSE ''::text
            END             AS "PAYMENT_AGREEMENT_ID",
            s.center        AS "CENTER_ID",
            s.last_modified AS "ETS"
        FROM
            ((((subscriptions s
        JOIN
            persons p
        ON
            (((
                        p.center = s.owner_center)
                AND (
                        p.id = s.owner_id))))
        JOIN
            persons cp
        ON
            (((
                        cp.center = p.transfers_current_prs_center)
                AND (
                        cp.id = p.transfers_current_prs_id))))
        JOIN
            subscriptiontypes st
        ON
            (((
                        st.center = s.subscriptiontype_center)
                AND (
                        st.id = s.subscriptiontype_id))))
        LEFT JOIN
            (
                SELECT
                    x.old_subscription_center,
                    x.old_subscription_id,
                    x.stop_change_time,
                    x.stop_cancel_time,
                    x.stop_person_id
                FROM
                    (
                        SELECT
                            scstop_1.old_subscription_center,
                            scstop_1.old_subscription_id,
                            scstop_1.change_time AS stop_change_time,
                            cp_1.external_id     AS stop_person_id,
                            scstop_1.cancel_time AS stop_cancel_time,
                            rank() OVER (PARTITION BY scstop_1.old_subscription_center,
                            scstop_1.old_subscription_id ORDER BY scstop_1.change_time DESC) AS rnk
                        FROM
                            (((subscription_change scstop_1
                        JOIN
                            employees emp
                        ON
                            (((
                                        emp.center = scstop_1.employee_center)
                                AND (
                                        emp.id = scstop_1.employee_id))))
                        JOIN
                            persons p_1
                        ON
                            (((
                                        emp.personcenter = p_1.center)
                                AND (
                                        emp.personid = p_1.id))))
                        JOIN
                            persons cp_1
                        ON
                            (((
                                        cp_1.center = p_1.transfers_current_prs_center)
                                AND (
                                        cp_1.id = p_1.transfers_current_prs_id))))
                        WHERE
                            ((
                                    scstop_1.type)::text = 'END_DATE'::text)) x
                WHERE
                    (
                        x.rnk = 1)) scstop
        ON
            (((
                        scstop.old_subscription_center = s.center)
                AND (
                        scstop.old_subscription_id = s.id)))) ) biview
JOIN
    PARAMS
ON
    params.id = CAST(biview."SUBSCRIPTION_CENTER" AS INT)
WHERE
    biview."ETS" >= PARAMS.FROMDATE
AND biview."ETS" < PARAMS.TODATE