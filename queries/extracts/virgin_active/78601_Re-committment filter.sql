-------Areas in sql to keep up to date
-------1. GlobalIDs of known monthlyDD to compare to
-------2. GlobalIDs of known recommittment subscriptions to compare
-------3. Secondary subscriptions like 'PT_BY_DD' to exclude
-------these areas are marked further on in sql
------returns multiple rows for members with multiple addons

WITH
    input_data AS materialized
    (
        SELECT
            p.center AS person_center,
            p.id     AS person_id,
            p.external_id,
            (:param_date)::DATE AS sub_start_date
        FROM
            virginactive.persons p
        WHERE
           p.external_id IN (:param_persons)
    )
SELECT
    p.person_center||'p'||p.person_id as personkey,
    p.external_id,
	s.center as subscription_center, 
	s.id as subscription_id,
    curp.globalid as current_globalID,
    curp.name as current_subscription,
s.end_date as current_end_date,
s.binding_end_date as current_binding_end,
    (
        CASE
            WHEN s.end_date <= (p.sub_start_date - interval '1' DAY)
            THEN 'X'
            ELSE NULL
        END) sub_ends_early,
    (
        CASE
            WHEN EXISTS
                (
                    SELECT
                        1
                    FROM
                        virginactive.subscriptions s1
                    JOIN
                        virginactive.products cp
                    ON
                        s1.subscriptiontype_center = cp.center
                    AND s1.subscriptiontype_id = cp.id
                    WHERE
                        s1.owner_center = p.person_center
                    AND s1.owner_id = p.person_id
                    AND s1.state IN (8) )
            THEN 'X'
            ELSE NULL
        END) AS already_sub_in_future,
    (
        CASE
            WHEN EXISTS
                (
                    SELECT
                        1
                    FROM
                        virginactive.subscription_freeze_period sfp
                    WHERE
                        s.center = sfp.subscription_center
                    AND s.id = sfp.subscription_id
                    AND sfp.state NOT IN ('CANCELLED')
                    AND sfp.end_date >= p.sub_start_date )
            THEN 'X'
            ELSE NULL
        END) AS has_freeze_period_in_future,
    (
        CASE
            WHEN EXISTS
                (
                    SELECT
                        1
                    FROM
                        virginactive.subscription_reduced_period srp
                    WHERE
                        s.center = srp.subscription_center
                    AND s.id = srp.subscription_id
                    AND srp.state NOT IN ('CANCELLED')
                    AND srp.type NOT IN ('FREEZE')
                    AND srp.end_date >= p.sub_start_date )
            THEN 'X'
            ELSE NULL
        END) AS has_free_period_in_future,
    (
        CASE
            WHEN st.st_type = 0
            THEN 'X'
            ELSE NULL
        END) is_cash_subscription,
    (
        CASE
                ------------------------------------------------------------------------
                ---checking current subscription globalID against known monthly DD subscription
                -- globalIDs
            WHEN curp.globalid IN ('UK392',
                                   'UK474')
                ---------------------------------------------------------------------
            THEN 'X'
            ELSE NULL
        END) already_in_monthly_dd,
    (
        CASE
                ------------------------------------------------------------------------
                ---checking current subscription globalID against known recommitment subscription
                -- globalIDs
            WHEN curp.globalid IN ('UK470',
                                   'UK469',
                                   'UK472',
                                   'UK471',
                                   'UK468')
                ---------------------------------------------------------------------
            THEN 'X'
            ELSE NULL
        END) already_in_recommitment_sub,
    (
        CASE
            WHEN EXISTS
                (
                    SELECT
                        1
                    FROM
                        virginactive.cashcollectioncases ccc
                    WHERE
                        p.person_center=ccc.personcenter
                    AND p.person_id=ccc.personid
                    AND ccc.closed=false
                    AND ccc.missingpayment=true)
            THEN 'X'
            ELSE NULL
        END )AS has_debt,
    (
        CASE
            WHEN EXISTS
                (
                    SELECT
                        1
                    FROM
                        virginactive.subscription_addon sa
                    WHERE
                        s.center=sa.subscription_center
                    AND s.id=sa.subscription_id
                    AND sa.cancelled=false
                    AND ( sa.end_date> p.sub_start_date
                        OR  sa.end_date IS NULL))
            THEN 'X'
            ELSE NULL
        END ) AS has_addon,
sa.end_date as addon_end_date,

            sa.individual_price_per_unit as addon_individual_price,
            sa.center_id as addon_center,
            sa.addon_product_id as addon_product_id
FROM
    input_data p
JOIN
    virginactive.subscriptions s
ON
    p.person_center = s.owner_center
AND p.person_id = s.owner_id
JOIN
    virginactive.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    virginactive.products curp
ON
    curp.center = s.subscriptiontype_center
AND curp.id = s.subscriptiontype_id

 LEFT JOIN
            virginactive.subscription_addon sa
        ON
            s.center=sa.subscription_center
        AND s.id=sa.subscription_id
        AND sa.cancelled=false
        AND ( sa.end_date> p.sub_start_date
            OR  sa.end_date IS NULL) 

WHERE
    s.state IN (2,4)
    ------------------------------------------------------------------------
    ----exluding 'PT_BY_DD' product globalIDs
AND curp.globalid NOT IN ('PT_BY_DD_-_EXPERT',
                          'PT_BY_DD_-_MASTER',
                          'PT_BY_DD_-_PERSONAL',
                          'PT_BY_DD_-_ICON',
                          'ANC_BY_DD',
                          'NUTRITION_BY_DD_-_EXPERT')
    ------------------------------------------------------------------------
    