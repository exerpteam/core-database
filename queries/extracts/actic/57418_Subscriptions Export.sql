-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
    )
    ,
    center_map AS materialized
    (
        SELECT
            c.id AS OldCenterID,
            c.id AS NewCenterID
        FROM
            centers c
        WHERE
            c.id IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
    )
    ,
    sub_freeze AS materialized
    (
        SELECT DISTINCT
            s.center,
            s.id,
            nth_value(sfp.start_date, 1) over (partition BY s.center,s.id ORDER BY sfp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeFrom1 ,
            nth_value(sfp.end_date, 1) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Freezeto1 ,
            nth_value(sfp.text, 1) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeReason1 ,
            CASE
                WHEN nth_value(sfp.type, 1) over (partition BY s.center,s.id ORDER BY
                    sfp.start_date ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) =
                    'UNRESTRICTED'
                THEN 0.00
                ELSE freeze_pr.price
            END AS FreezePrice1 ,
            nth_value(sfp.start_date, 2) over (partition BY s.center,s.id ORDER BY sfp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeFrom2 ,
            nth_value(sfp.end_date, 2) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Freezeto2 ,
            nth_value(sfp.text, 2) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeReason2 ,
            CASE
                WHEN nth_value(sfp.type, 2) over (partition BY s.center,s.id ORDER BY
                    sfp.start_date ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) =
                    'UNRESTRICTED'
                THEN 0.00
                ELSE freeze_pr.price
            END AS FreezePrice2 ,
            nth_value(sfp.start_date, 3) over (partition BY s.center,s.id ORDER BY sfp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeFrom3 ,
            nth_value(sfp.end_date, 3) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Freezeto3 ,
            nth_value(sfp.text, 3) over (partition BY s.center,s.id ORDER BY sfp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreezeReason3 ,
            CASE
                WHEN nth_value(sfp.type, 3) over (partition BY s.center,s.id ORDER BY
                    sfp.start_date ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) =
                    'UNRESTRICTED'
                THEN 0.00
                ELSE freeze_pr.price
            END AS FreezePrice3
        FROM
            subscriptions s
        JOIN
            subscription_freeze_period sfp
        ON
            s.center = sfp.subscription_center
        AND s.id = sfp.subscription_id
        JOIN
            center_map
        ON
            center_map.OldCenterID = s.center
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            s.SUBSCRIPTIONTYPE_CENTER=st.center
        AND s.SUBSCRIPTIONTYPE_ID=st.id
        LEFT JOIN
            products freeze_pr
        ON
            freeze_pr.center = st.freezeperiodproduct_center
        AND freeze_pr.id = st.freezeperiodproduct_id
        WHERE
            sfp.start_date >= s.billed_until_date
        AND sfp.cancel_time IS NULL
    )
    ,
    sub_free AS materialized
    (
        SELECT DISTINCT
            s.center,
            s.id ,
            nth_value(srp.start_date, 1) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom1 ,
            nth_value(srp.end_date, 1) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo1 ,
            nth_value(srp.start_date, 2) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom2 ,
            nth_value(srp.end_date, 2) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo2 ,
            nth_value(srp.start_date, 3) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom3 ,
            nth_value(srp.end_date, 3) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo3 ,
            nth_value(srp.start_date, 4) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom4 ,
            nth_value(srp.end_date, 4) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo4 ,
            nth_value(srp.start_date, 5) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom5 ,
            nth_value(srp.end_date, 5) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo5 ,
            nth_value(srp.start_date, 6) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom6 ,
            nth_value(srp.end_date, 6) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo6 ,
            nth_value(srp.start_date, 7) over (partition BY s.center,s.id ORDER BY srp.start_date
            ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodFrom7 ,
            nth_value(srp.end_date, 7) over (partition BY s.center,s.id ORDER BY srp.start_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FreePeriodTo7
        FROM
            subscriptions s
        JOIN
            subscription_reduced_period srp
        ON
            s.center = srp.subscription_center
        AND s.id = srp.subscription_id
        JOIN
            center_map
        ON
            center_map.OldCenterID = srp.subscription_center
        WHERE
            srp.start_date >= s.billed_until_date
        AND srp.cancel_time IS NULL
        AND srp.type != 'FREEZE'
    )
    ,
    sub_adds AS
    (
        SELECT
            s.center,
            s.id,
            nth_value(pr.name, 1) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE BETWEEN
            UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnName1,
            nth_value(COALESCE(sa.individual_price_per_unit,pr.price),1) over (partition BY
            s.center,s.id ORDER BY sa.id ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
            FOLLOWING) AS AddOnPrice1,
            nth_value(sa.start_date,1) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnStartDate1,
            nth_value(sa.end_date,1) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnEndDate1,
            nth_value(sa.binding_end_date,1) over (partition BY s.center,s.id ORDER BY sa.id ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnBindingEndDate1,
            nth_value(pr.name, 2) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE BETWEEN
            UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnName2,
            nth_value(COALESCE(sa.individual_price_per_unit,pr.price),2) over (partition BY
            s.center,s.id ORDER BY sa.id ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
            FOLLOWING) AS AddOnPrice2,
            nth_value(sa.start_date,2) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnStartDate2,
            nth_value(sa.end_date,2) over (partition BY s.center,s.id ORDER BY sa.id ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnEndDate2,
            nth_value(sa.binding_end_date,2) over (partition BY s.center,s.id ORDER BY sa.id ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS AddOnBindingEndDate2
        FROM
            subscriptions s
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            center_map
        ON
            center_map.OldCenterId = s.center
        JOIN
            masterproductregister mpr
        ON
            mpr.id = sa.addon_product_id
        JOIN
            products pr
        ON
            pr.globalid = mpr.globalid
        AND pr.center = COALESCE(sa.center_id,s.center)
        WHERE
            sa.cancelled = false
        AND (sa.end_date > CURRENT_DATE
            OR  sa.end_Date IS NULL)
    )
    ,
    sub_future_price AS
    (
        SELECT
            s.center,
            s.id,
            nth_value(sp.price,1) over (partition BY s.center,s.id ORDER BY sp.from_date ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PriceUpdateAmount1 ,
            nth_value(sp.from_date,1) over (partition BY s.center,s.id ORDER BY sp.from_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PriceUpdateDate1,
            nth_value(sp.price,2) over (partition BY s.center,s.id ORDER BY sp.from_date ASC RANGE
            BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PriceUpdateAmount2 ,
            nth_value(sp.from_date,2) over (partition BY s.center,s.id ORDER BY sp.from_date ASC
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PriceUpdateDate2
        FROM
            subscription_price sp
        JOIN
            subscriptions s
        ON
            s.center = sp.subscription_center
        AND s.id = sp.subscription_id
        AND sp.from_date >= s.billed_until_date
        JOIN
            center_map
        ON
            center_map.OldCenterID = s.center
        WHERE
            sp.cancelled = False
    )
SELECT
    (s.OWNER_CENTER || 'p' || s.OWNER_ID)              AS PersonId,
    s.CENTER || 'ss' || s.ID                           AS MembershipId,
    center_map.NewCenterID                             AS SubscriptionCenterId,
    TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS MembershipCreationDate,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                AS MembershipStartDate,
    (
        CASE
            WHEN s.END_DATE IS NULL
            THEN NULL
            ELSE TO_CHAR(s.END_DATE, 'YYYY-MM-DD')
        END)      AS MembershipEndDate,
    pd.GLOBALID   AS OldMembershipTypeId,
    pd.NAME       AS OldMembershipTypeName,
    s.SUB_COMMENT AS MembershipComment,
    REPLACE( '' || (
        CASE
            WHEN (s.BINDING_END_DATE IS NOT NULL
                AND s.BINDING_END_DATE >= CURRENT_DATE) -- replace by today
            THEN s.BINDING_PRICE
            ELSE s.SUBSCRIPTION_PRICE
        END), ',', '.' ) AS MembershipPrice,
    --MembershipTypePrice is not needed
    -- pd.price AS MembershipTypePrice,
    CASE st.ST_TYPE
        WHEN 0
        THEN 'CASH'
        WHEN 1
        THEN 'EFT'
        WHEN 2
        THEN 'CLIPCARD'
        WHEN 3
        THEN 'COURSE'
    END AS MembershipDeductionType,
    (
        CASE
            WHEN (s.BILLED_UNTIL_DATE IS NULL)
            THEN NULL
            WHEN (st.ST_TYPE=1
                AND s.END_DATE IS NOT NULL
                AND s.END_DATE<s.BILLED_UNTIL_DATE)
            THEN TO_CHAR(s.END_DATE, 'YYYY-MM-DD')
            ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
        END) AS MembershipBilledUntilDate,
    (
        CASE
            WHEN st.ST_TYPE=0
            THEN NULL
            ELSE TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')
        END) AS MembershipBindingEndDate,
    sf.freezefrom1,
    sf.freezeto1,
    sf.freezereason1,
    sf.freezeprice1,
    sf.freezefrom2,
    sf.freezeto2,
    sf.freezereason2,
    sf.freezeprice2,
    sf.freezefrom3,
    sf.freezeto3,
    sf.freezereason3,
    sf.freezeprice3,
    s.SAVED_FREE_DAYS   AS SavedFreeDays,
    s.saved_free_months AS SavedFreeMonths,
    sub_free.freeperiodfrom1,
    sub_free.freeperiodto1,
    sub_free.freeperiodfrom2,
    sub_free.freeperiodto2,
    sub_free.freeperiodfrom3,
    sub_free.freeperiodto3,
    sub_free.freeperiodfrom4,
    sub_free.freeperiodto4,
    sub_free.freeperiodfrom5,
    sub_free.freeperiodto5,
    sub_free.freeperiodfrom6,
    sub_free.freeperiodto6,
    sub_free.freeperiodfrom7,
    sub_free.freeperiodto7,
    sub_adds.addonname1,
    sub_adds.addonprice1,
    sub_adds.addonstartdate1,
    sub_adds.addonenddate1,
    sub_adds.addonbindingenddate1,
    sub_adds.addonname2,
    sub_adds.addonprice2,
    sub_adds.addonstartdate2,
    sub_adds.addonenddate2,
    sub_adds.addonbindingenddate2,
    fprice.priceupdateamount1,
    fprice.priceupdatedate1,
    fprice.priceupdateamount2,
    fprice.priceupdatedate2,
    pd.GLOBALID                                 AS NewMembershipType,
    s.creator_center||'p'||s.creator_center     AS SalesPersonId,
    (s.is_price_update_excluded::INTEGER)::text AS PriceForLife,
    (s.is_change_restricted::INTEGER)::text     AS IsChangeRestricted,
    CASE
        WHEN st.st_type = 2
        THEN st.rec_clipcard_product_clips
        ELSE NULL
    END AS RecurringClipcardClips
FROM
    SUBSCRIPTIONS s
JOIN
    plist p
ON
    s.OWNER_CENTER=p.center
AND s.OWNER_ID=p.id
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER=st.center
AND s.SUBSCRIPTIONTYPE_ID=st.id
JOIN
    PRODUCTS pd
ON
    st.center=pd.center
AND st.id=pd.id
JOIN
    center_map
ON
    center_map.OldCenterId = s.center
LEFT JOIN
    sub_freeze sf
ON
    sf.center = s.center
AND sf.id = s.id
LEFT JOIN
    sub_free
ON
    sub_free.center = s.center
AND sub_free.id = s.id
LEFT JOIN
    sub_adds
ON
    sub_adds.center = s.center
AND sub_adds.id = s.id
LEFT JOIN
    sub_future_price fprice
ON
    fprice.center = s.center
AND fprice.id = s.id
WHERE
    s.STATE IN (2,4,8)
    