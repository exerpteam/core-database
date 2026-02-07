WITH
    params AS
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$,
                    'yyyy-MM-dd HH24:MI' ) )
            END                                                                         AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE
    )
SELECT
    "SUBSCRIPTION_ADDON_ID",
    "PERSON_ID",
    "SUBSCRIPTION_CENTER",
    "SUBSCRIPTION_ID",
    "ADDON_PRODUCT_ID",
    "CENTER_ID",
    "START_DATE",
    "END_DATE",
    "CREATION_DATE",
    "EMPLOYEE_ID",
    "CANCELLED",
    "QUANTITY",
    "INDIVIDUAL_PRICE_PER_UNIT",
    "BINDING_END_DATE",
    "SALES_CENTER_ID",
    "SALES_INTERFACE"
FROM
    params,
    (
        SELECT
            (sa.id)::CHARACTER VARYING(255)                  AS "SUBSCRIPTION_ADDON_ID",
            cp.external_id                                          AS "PERSON_ID",
            (sa.subscription_center)::CHARACTER VARYING(255)               AS "SUBSCRIPTION_CENTER",
            ((sa.subscription_center || 'ss'::text) || sa.subscription_id)     AS "SUBSCRIPTION_ID",
            ((prod.center || 'prod'::text) || prod.id)                        AS "ADDON_PRODUCT_ID",
            sa.center_id                                                           AS "CENTER_ID",
            TO_CHAR((sa.start_date)::TIMESTAMP WITH TIME zone, 'yyyy-MM-dd'::text) AS "START_DATE",
            TO_CHAR((sa.end_date)::TIMESTAMP WITH TIME zone, 'yyyy-MM-dd'::text)   AS "END_DATE",
            TO_CHAR(longtodatec((sa.creation_time)::DOUBLE PRECISION, (sa.center_id)::DOUBLE
            PRECISION), 'yyyy-MM-dd'::text) AS "CREATION_DATE",
            cstaff.external_id              AS "EMPLOYEE_ID",
            CASE
                WHEN (sa.cancelled = 0)
                THEN 'false'::text
                WHEN (sa.cancelled = 1)
                THEN 'true'::text
                ELSE NULL::text
            END                                             AS "CANCELLED",
            sa.quantity                                              AS "QUANTITY",
            sa.individual_price_per_unit                             AS "INDIVIDUAL_PRICE_PER_UNIT",
            TO_CHAR((sa.binding_end_date)::TIMESTAMP WITH TIME zone, 'yyyy-MM-dd'::text) AS
                                                            "BINDING_END_DATE",
            (sa.sales_center_id)::CHARACTER VARYING(255) AS "SALES_CENTER_ID",
            bi_decode_field('SUBSCRIPTION_ADDON'::CHARACTER VARYING, 'SALES_INTERFACE'::CHARACTER
            VARYING, sa.sales_interface) AS "SALES_INTERFACE",
            sa.last_modified             AS "ETS"
        FROM
            ((((((((subscription_addon sa
        JOIN
            subscriptions s
        ON
            (((
                        s.center = sa.subscription_center)
                AND (
                        s.id = sa.subscription_id))))
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
        LEFT JOIN
            employees emp
        ON
            (((
                        emp.center = sa.employee_creator_center)
                AND (
                        emp.id = sa.employee_creator_id))))
        LEFT JOIN
            persons staff
        ON
            (((
                        staff.center = emp.personcenter)
                AND (
                        staff.id = emp.personid))))
        LEFT JOIN
            persons cstaff
        ON
            (((
                        cstaff.center = staff.transfers_current_prs_center)
                AND (
                        cstaff.id = staff.transfers_current_prs_id))))
        JOIN
            masterproductregister mpr
        ON
            ((
                    mpr.id = sa.addon_product_id)))
        JOIN
            products prod
        ON
            (((
                        prod.center = sa.center_id)
                AND ((
                            prod.globalid)::text = (mpr.globalid)::text)))) ) biview
WHERE
    biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND biview."CENTER_ID" IN ($$scope$$)