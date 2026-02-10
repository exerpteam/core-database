-- The extract is extracted from Exerp on 2026-02-08
-- Identifies post-paid subscriptions for Accounting in order to accrue revenue that was collected in the next month the prior month.
https://clublead.atlassian.net/browse/ST-3031
https://clublead.atlassian.net/browse/ES-6116
https://clublead.atlassian.net/browse/ST-8520
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            CAST($$Cut_Date$$ AS DATE)                                                                                                                        AS cutDate,
            CAST((date_trunc('month', CAST($$Cut_Date$$ AS TIMESTAMP)) +'1month') AS DATE) - CAST(date_trunc('month', CAST($$Cut_Date$$ AS TIMESTAMP)) AS DATE) AS noOfDays,
            c.id                                                                                                                                            AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST($$Cut_Date$$ AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT)                          AS cutDateLong
        FROM
            centers c
    )
SELECT
    t.*,
    ROUND(t.DailyPrice*t.NumberOfDays, 2) AS "Realized Revenue"
FROM
    (
        SELECT
            params.cutDate           AS "Cut Date",
            c.id                     AS "Center Number",
            c.name                   AS "Center Name",
            p.center || 'p' ||p.id   AS "Person Id",
            p.fullname               AS "Person Name",
            s.center || 'ss' || s.id AS "Subscription Id",
            prod.name                AS "Subscription Name",
            s.start_date             AS "Subscription Start Date",
            s.end_date               AS "Subscription End Date",
            s.billed_until_date      AS "Current Billed Until Date",
            CASE
                WHEN st.periodunit = 0
                THEN 'BI-Week'
                ELSE 'Monthly'
            END                                                    AS "Subscription Period Type",
            s.subscription_price                                   AS "Current Subscription Price",
            COALESCE(spp.subscription_price, s.subscription_price) AS "Subscription Price During Cutdate",
            CASE
                WHEN st.periodunit = 0
                THEN ROUND(COALESCE(spp.subscription_price, s.subscription_price)/14, 2)
                ELSE ROUND(COALESCE(spp.subscription_price, s.subscription_price)/ params.noOfDays, 2)
            END                                                                    AS DailyPrice,
            TO_CHAR(longtodatec(spp.entry_time, spp.center), 'yyyy-MM-dd HH24:MI') AS "Subscription PeriodPart EntryTime",
            spp.from_date                                                          AS "Subscription PeriodPart FromDate",
            spp.to_date                                                            AS "Subscription PeriodPart ToDate",
            spp.old_billed_until_date                                              AS "Subscription PeriodPart Old BUD",
            COALESCE(spp.to_date, s.billed_until_date)                             AS "Billed Until Date During Cutdate",
            -- sub end date in between sub period part to date/BUD and cut date then number of days is end date - sub period part to date/BUD
            -- else cut date - sub period part to date/BUD
            CASE
                WHEN s.end_date IS NOT NULL
                    AND s.end_date > COALESCE(spp.to_date, s.billed_until_date)
                    AND s.end_date <= params.cutDate
                THEN s.end_date - COALESCE(spp.to_date, s.billed_until_date)
                WHEN spp.to_date >= params.cutDate -- change > to >= to cover month end renewals
                THEN params.cutDate - spp.from_date + 1
                ELSE params.cutDate - COALESCE(spp.to_date, s.billed_until_date)
            END     AS NumberOfDays,
            pg.name AS "Primary Product Group Name"
        
        FROM
            goodlife.subscriptions s
        JOIN
            params
        ON
            params.CENTER_ID = s.center
            AND s.owner_center IN ($$Scope$$)
            AND s.renewal_policy_override IN (6,10)
            AND s.start_date <= params.cutDate
            AND (s.end_date IS NULL OR s.end_date >= params.cutDate)
        JOIN
            goodlife.persons p
        ON
            p.center = s.owner_center
            AND p.id = s.owner_id
        JOIN
            goodlife.centers c
        ON
            c.id = p.center
        JOIN
            goodlife.subscriptiontypes st
        ON
            s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
            AND s.SUBSCRIPTIONTYPE_ID = st.ID
            AND st.st_type = 1
        JOIN
            goodlife.products prod
        ON
            prod.CENTER = st.center
            AND prod.ID = st.id
            -- Latest non cancelled sub period part with entry time before cut date
        JOIN
            product_group pg
        ON
            pg.id = prod.primary_product_group_id
        LEFT JOIN
            (
                SELECT
                    spp1.center,
                    spp1.id,
                    MAX(spp1.entry_time) AS max_entry
                
                -- If the subscription renews at the end of the month, we are targetting the wrong period
                    -- 
                
                FROM
                    goodlife.subscriptionperiodparts spp1
                JOIN
                    params
                ON
                    params.CENTER_ID = spp1.center
                WHERE
                    spp1.entry_time < params.cutDateLong
                    AND spp1.spp_state IN (1,2,7)
                    -- AND spp1.center = s.center
                    -- AND spp1.id = s.id
                GROUP BY
                    spp1.center,
                    spp1.id) latest_spp
        ON
            latest_spp.CENTER = s.center
            AND latest_spp.ID = s.id
        LEFT JOIN
            goodlife.subscriptionperiodparts spp
        ON
            spp.CENTER = latest_spp.center
            AND spp.ID = latest_spp.id
            AND spp.entry_time = latest_spp.max_entry
            
        WHERE
             
           COALESCE(spp.subscription_price, s.subscription_price) > 0
           
			-- only consider sub period part price or sub price greater than 0 for revenue. Zero price doesn't consider revenue
			
            -- sub period part to date or billed_until_date less than cut date otherwise revenue is already counted before cut date
            -- AND COALESCE(spp.to_date, s.billed_until_date) <= params.cutDate
            -- sub period part to date or billed_until_date less than sub end date or cut date otherwise revenue is already counted before cut date
            -- AND COALESCE(spp.to_date, s.billed_until_date) <= COALESCE(s.end_date, params.cutDate) 
    ) t