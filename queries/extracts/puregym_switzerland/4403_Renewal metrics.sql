-- The extract is extracted from Exerp on 2026-02-08
-- EC-7538
WITH
    date_range AS materialized
    (
       SELECT
getstartofday((:from_date)::date::varchar, 100)  AS date_long_from,
          getendofday((:to_date)::date::varchar, 100) AS date_long_to
            
    )
   
,
    dataset AS materialized
    (
        SELECT DISTINCT
        ON
            (
                s.center, s.id) p.external_id AS "External ID",
            p.center                          AS "Person Centre",
            p.center||'p'||p.id               AS "Member ID",
            s.center||'ss'||s.id              AS "Subscription ID",
            CASE s.STATE
                WHEN 2
                THEN 'ACTIVE'
                WHEN 3
                THEN 'ENDED'
                WHEN 4
                THEN 'FROZEN'
                WHEN 7
                THEN 'WINDOW'
                WHEN 8
                THEN 'CREATED'
                ELSE 'Undefined'
            END AS "Subscription State",
            CASE s.SUB_STATE
                WHEN 1
                THEN 'NONE'
                WHEN 2
                THEN 'AWAITING_ACTIVATION'
                WHEN 3
                THEN 'UPGRADED'
                WHEN 4
                THEN 'DOWNGRADED'
                WHEN 5
                THEN 'EXTENDED'
                WHEN 6
                THEN 'TRANSFERRED'
                WHEN 7
                THEN 'REGRETTED'
                WHEN 8
                THEN 'CANCELLED'
                WHEN 9
                THEN 'BLOCKED'
                WHEN 10
                THEN 'CHANGED'
                ELSE 'Undefined'
            END                                          AS "Subscription Substate",
            s.binding_price                              AS "Binding Price",
            pr.name                                      AS "Product name",
            pr.globalid                                  AS "Global Subscription",
            longtodateC(s.creation_time, s.center)::DATE AS "Create Date",
            s.start_date                                 AS "Start Date",
            s.billed_until_date                          AS "Billed until Date",
            s.end_date                                   AS "End Date",
            s.state                                      AS s_state,
            art.unsettled_amount                         AS art_unsettled_amount,
            spp.spp_state                                AS spp_spp_state,
            ccc.center                                   AS ccc_center,
            ccc.closed                                   AS ccc_closed,
            ccc.currentstep                              AS ccc_currentstep,
            ccc.currentstep_type                         AS ccc_currentstep_type
        FROM
            subscriptions s
        JOIN
            persons p
        ON
            p.center=s.owner_center
        AND p.id=s.owner_id
        CROSS JOIN
            date_range dr
        JOIN
            subscriptiontypes st
        ON
            s.subscriptiontype_center=st.center
        AND s.subscriptiontype_id=st.id
        JOIN
            products pr
        ON
            s.subscriptiontype_center=pr.center
        AND s.subscriptiontype_id=pr.id
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = s.subscriptiontype_center
        AND ppgl.product_id = s.subscriptiontype_id
        JOIN
            subscriptionperiodparts spp
        ON
            s.center=spp.CENTER
        AND s.id=spp.ID
        JOIN
            SPP_INVOICELINES_LINK sppLink
        ON
            sppLink.PERIOD_CENTER=spp.CENTER
        AND sppLink.PERIOD_ID=spp.ID
        AND sppLink.PERIOD_SUBID=spp.SUBID
        JOIN
            ar_trans art
        ON
            sppLink.invoiceline_center=art.ref_center
        AND sppLink.invoiceline_id=art.ref_id
        LEFT JOIN
            puregym_switzerland.cashcollectioncases ccc
        ON
            ccc.personcenter=p.center
        AND ccc.personid=p.id
        AND ccc.missingpayment=true
        AND ccc.startdate = art.due_date + interval '1' DAY --currently configured as debt case
            -- starts one
            -- day after due
        WHERE
            UPPER(art.text) LIKE '%RENEWAL%'
        AND art.REF_TYPE= 'INVOICE'
        AND st.st_type=1
        AND art.entry_time BETWEEN dr.date_long_from AND dr.date_long_to
        AND ppgl.product_group_id = 602 --12 Month - Reporting
        AND sppLink.invoiceline_subid=1 --otherwise we get duplicates
        AND p.status NOT IN ( 4,5,7,8)
   and p.center in (:scope)
            -- AND p.center||'p'||p.id IN ('6004p1557')
        ORDER BY
           s.center, s.id, art.entry_time DESC
    )
    ,
    renewed_no_debt AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            s_state IN (2,
                        4)
        AND art_unsettled_amount = 0 --settled renewal charges
            --  AND spp_spp_state=1 --subscription period not cancelled
        AND (
                ccc_center IS NULL
            OR  (
                    ccc_closed=true --if open it is another bucket
                AND ccc_currentstep < 2 ) --if past step one it is another bucket
            )
    )
    -- select * from renewed_no_debt;
    ,
    renewed_with_debt AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            s_state IN (2,
                        4)
        AND art_unsettled_amount = 0 --settled renewal charges
            --AND spp_spp_state!=1 --subscription period not cancelled
        AND ccc_center IS NOT NULL
        AND ccc_closed=true
        AND ccc_currentstep > 1 ----this bucket is specifc for debt case with fee (step 2)
    )
    --  select * from renewed_with_debt;
    ,
    inactive_no_debt AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            s_state NOT IN (2,
                            4)
            --AND art_unsettled_amount = 0 --settled renewal charges
            -- AND spp_spp_state=2 --subscription period  cancelled
        AND (
                ccc_center IS NULL
            OR  (
                    ccc_closed=true --if open it is another bucket
                AND ccc_currentstep < 2 ) --if past step one it is another bucket
            )
    )
    ---select * from inactive_no_debt;
    ,
    inactive_with_debt AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            s_state NOT IN (2,
                            4)
            --  AND art_unsettled_amount = 0 --settled renewal charges
            -- AND spp_spp_state=2 --subscription period  cancelled
        AND ccc_center IS NOT NULL
        AND ccc_closed=true
        AND ccc_currentstep > 1 ----this bucket is specifc for debt case with fee (step 2)
    )
    --  select * from inactive_with_debt;
    ,
    ---still in member kpi
    in_debt_active AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            s_state IN (2,
                        4)
            --   AND art_unsettled_amount != 0 --settled renewal charges
            --   AND spp_spp_state=1 --subscription period not cancelled
        AND ccc_center IS NOT NULL
        AND ccc_closed=false
            --this bucket is specifc for ongoing debt case but not external debt coll
        AND ccc_currentstep_type != 4
    )
    --SELECT * FROM in_debt_active;
    ,
    ---wouldn't be part of member kpi
    in_debt_inactive AS
    (
        SELECT
            *
        FROM
            dataset
        WHERE
            --     s_state NOT IN (2,4)
            -- AND art_unsettled_amount = 0 --settled renewal charges
            -- AND spp_spp_state=2 --subscription period  cancelled
            -- AND
            ccc_center IS NOT NULL
        AND ccc_closed=false
            --this bucket is specifc for ongoing debt case but not external debt coll
        AND ccc_currentstep_type = 4
    )
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'Renewed - no debt' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    renewed_no_debt
UNION ALL
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'Renewed - debt payment' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    renewed_with_debt
UNION ALL
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'Non-renewal - no Debt' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    inactive_no_debt
UNION ALL
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'Non-renewal - Debt' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    inactive_with_debt
UNION ALL
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'In Debt - Active' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    in_debt_active
UNION ALL
SELECT
    "External ID",
    "Person Centre",
    "Member ID",
    "Subscription ID",
    "Subscription State",
    "Subscription Substate",
    "Binding Price",
    "Product name",
    "Global Subscription",
    'In Debt - Inactive' AS "Renewal Categorisation" ,
    "Create Date",
    "Start Date",
    "Billed until Date" ,
    "End Date"
FROM
    in_debt_inactive ;