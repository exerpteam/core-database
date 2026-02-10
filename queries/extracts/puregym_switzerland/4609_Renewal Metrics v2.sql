-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS materialized
    (
        SELECT
            getstartofday((:from_date)::DATE::VARCHAR, 100) AS date_long_from,
            getendofday((:to_date)::DATE::VARCHAR, 100)     AS date_long_to,
            (:from_date)::DATE                              AS date_from,
            (:to_date)::DATE                                AS date_to
    )
    ,
    kpi_base AS materialized
    (
        SELECT DISTINCT
            s.owner_center ||'p'||s.owner_id AS "Member ID",
            s.center||'ss'||s.id             AS "Subscription ID",
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
            s.center,
            s.id,
            s.owner_center,
            s.owner_id
        FROM
            PARAMS
        CROSS JOIN
            STATE_CHANGE_LOG SCL
        INNER JOIN
            SUBSCRIPTIONS S
        ON
            SCL.CENTER = S.CENTER
        AND SCL.ID = S.ID
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = s.subscriptiontype_center
        AND ppgl.product_id = s.subscriptiontype_id
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
        WHERE
            ppgl.product_group_id = 602 --12 Month - Reporting
        AND SCL.ENTRY_TYPE = 2
        AND SCL.CENTER IN ( :scope )
            -- Time safety. We need to exclude subscriptions started in the past so they do not
            -- get
            -- into the incoming balance because they will not be in the outgoing balance of
            -- the
            -- previous day
        AND (
                SCL.ENTRY_START_TIME < PARAMS.date_long_to
            AND SCL.BOOK_START_TIME < PARAMS.date_long_to)
        AND (
                SCL.BOOK_END_TIME IS NULL
            OR  SCL.BOOK_END_TIME >= PARAMS.date_long_from )
        AND SCL.ENTRY_TYPE = 2
        AND SCL.STATEID IN ( 2,
                            4,8 )
        AND st.st_type=1
    )
    --  SELECT * FROM kpi_base ;
    ,
    dataset AS materialized
    (
        SELECT
        DISTINCT
       ON
           (
              kb.center, kb.id) 
                p.external_id AS "External ID",
            p.center                            AS "Person Centre",
            "Member ID",
            "Subscription ID",
            "Subscription State",
            "Subscription Substate",
            "Binding Price",
            "Product name",
            "Global Subscription",
            "Create Date",
            "Start Date",
            "Billed until Date",
            "End Date",
            s_state,
            art.unsettled_amount AS art_unsettled_amount,
            spp.spp_state        AS spp_spp_state,
            ccc.center           AS ccc_center,
            ccc.closed           AS ccc_closed,
            ccc.currentstep      AS ccc_currentstep,
            ccc.currentstep_type AS ccc_currentstep_type, art.due_date, ccc.startdate, longtodateC(ccc.closed_datetime, ccc.center)::DATE, spp.to_date, sppLink.*
        FROM
            kpi_base kb
        JOIN
            persons p
        ON
            p.center=kb.owner_center
        AND p.id=kb.owner_id
       JOIN
            subscriptionperiodparts spp
        ON
            kb.center=spp.CENTER
        AND kb.id=spp.ID
        LEFT JOIN
            SPP_INVOICELINES_LINK sppLink
        ON
            sppLink.PERIOD_CENTER=spp.CENTER
        AND sppLink.PERIOD_ID=spp.ID
        AND sppLink.PERIOD_SUBID=spp.SUBID
        AND sppLink.invoiceline_subid=1 --otherwise we get duplicates
        LEFT JOIN
            ar_trans art
        ON
            sppLink.invoiceline_center=art.ref_center
        AND sppLink.invoiceline_id=art.ref_id
        AND UPPER(art.text) LIKE '%RENEWAL%'
        AND art.REF_TYPE= 'INVOICE'
        LEFT JOIN
            puregym_switzerland.cashcollectioncases ccc
        ON
            ccc.personcenter=p.center
        AND ccc.personid=p.id
        AND ccc.missingpayment=true
            --currently configured as debt case starts one
            -- day after due
       AND ccc.startdate <= art.due_date + interval '1' DAY
      AND (
              longtodateC(ccc.closed_datetime, ccc.center)::DATE > art.due_date
           OR  ccc.closed_datetime IS NULL)
        WHERE
            p.status NOT IN (4,5,7,8)
            -- and p.center in (:scope)
        --  AND p.center||'p'||p.id IN ('6004p3116')
            ---looking only at latest renewal entry into account
           -- and spp.spp_state=1
        ORDER BY
            kb.center,
            kb.id,
            art.entry_time  DESC NULLS last

    )
--SELECT * FROM dataset;
, renewed_no_debt AS
(
    SELECT
        *
    FROM
        dataset
    WHERE
        s_state IN (2,
                    4)
    AND "End Date" IS NULL
    AND art_unsettled_amount = 0 --settled renewal charges
        --  AND spp_spp_state=1 --subscription period not cancelled
    AND (
            ccc_center IS NULL
        OR  (
                ccc_closed=true --if open it is another bucket
            AND ccc_currentstep < 2 ) --if past step one it is another bucket
        ) )
 --select * from renewed_no_debt;
, renewed_with_debt AS
(
    SELECT
        *
    FROM
        dataset
    WHERE
        s_state IN (2,
                    4)
    AND "End Date" IS NULL
    AND art_unsettled_amount = 0 --settled renewal charges
        --AND spp_spp_state!=1 --subscription period not cancelled
    AND ccc_center IS NOT NULL
    AND ccc_closed=true
    AND ccc_currentstep > 1 ----this bucket is specifc for debt case with fee (step 2)
)
 -- select * from renewed_with_debt;
, not_renewed_no_debt AS
(
    SELECT
        *
    FROM
        dataset
    WHERE
          "End Date" IS NOT NULL
        --AND art_unsettled_amount = 0 --settled renewal charges
        -- AND spp_spp_state=2 --subscription period  cancelled
    AND (
            ccc_center IS NULL
        OR  (
                ccc_closed=true --if open it is another bucket
            AND ccc_currentstep < 2 ) --if past step one it is another bucket
        ) )
---select * from not_renewed_no_debt;
, not_renewed_with_debt AS
(
    SELECT
        *
    FROM
        dataset
    WHERE
        
              "End Date" IS NOT NULL
        --  AND art_unsettled_amount = 0 --settled renewal charges
        -- AND spp_spp_state=2 --subscription period  cancelled
    AND ccc_center IS NOT NULL
    AND ccc_closed=true
    AND ccc_currentstep > 1 ----this bucket is specifc for debt case with fee (step 2)
)
 ---select * from not_renewed_with_debt;
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
    AND "End Date" IS NULL
        --   AND art_unsettled_amount != 0 --settled renewal charges
        --   AND spp_spp_state=1 --subscription period not cancelled
    AND ccc_center IS NOT NULL
    AND ccc_closed=false
        --this bucket is specifc for ongoing debt case but not external debt coll
    AND ccc_currentstep_type != 4 )
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
    AND ccc_currentstep_type = 4 )
 ---select * from in_debt_inactive;
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
    not_renewed_no_debt
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
    not_renewed_with_debt
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