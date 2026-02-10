-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    ( SELECT
        c.id                                                                AS center
        , datetolongc(CAST(CURRENT_TIMESTAMP AS TEXT),c.id) - 1000*60*60*24 AS from_time
    FROM
        centers c
    )
    , p_det AS
    (SELECT
        p.*
        , COALESCE(legacyPersonId.txtvalue,p.external_id) AS contactguid
    FROM
        persons p
    LEFT JOIN
        PERSON_EXT_ATTRS legacyPersonId
    ON
        p.center=legacyPersonId.PERSONCENTER
    AND p.id=legacyPersonId.PERSONID
    AND legacyPersonId.name='_eClub_OldSystemPersonId'
    )
    , future_freeze AS
    (SELECT
        *
    FROM
        (SELECT
            fr.subscription_center
            , fr.subscription_id
            , TO_CHAR(fr.START_DATE, 'YYYY-MM-DD') AS FreezeFrom
            , TO_CHAR(fr.END_DATE, 'YYYY-MM-DD')   AS FreezeTo
            , fr.text                              AS FreezeReason
            ,fr.last_modified
            ,ROW_NUMBER() over (
                            PARTITION BY
                                fr.subscription_center
                                , fr.subscription_id
                            ORDER BY
                                fr.START_DATE ASC) AS rnk
        FROM
            SUBSCRIPTION_FREEZE_PERIOD fr
        WHERE
            fr.END_DATE > CURRENT_TIMESTAMP)
    WHERE
        rnk = 1
    )
    , package_type AS
    ( SELECT
        pr.center
        ,pr.id
        ,CASE
            WHEN bool_or(ppg.product_group_id IN (801)) -- Vantage
            THEN 'VANTAGE'
            WHEN bool_or(ppg.product_group_id IN (243,211)) --Platinum, Non Countable Platinum
            THEN 'PLATINUM'
            WHEN bool_or(ppg.product_group_id IN (201
                                                  , 207
                                                  , 241)) -- Diamond, Non Countable Diamond,
                -- Diamond Plus
            THEN 'PLATINUM_INFINITY'
            WHEN bool_or(ppg.product_group_id IN (3)) -- Team Members
            THEN 'TEAM'
            WHEN bool_or(ppg.product_group_id IN (601)) --Life
            THEN 'LIFE'
            WHEN bool_or(ppg.product_group_id IN (602)) -- Founder
            THEN 'FOUNDER'
            WHEN bool_or(ppg.product_group_id IN (403)) -- Standard
            THEN 'STANDARD'
            ELSE 'STANDARD'
        END AS package_type
    FROM
        products pr
    JOIN
        product_and_product_group_link ppg
    ON
        pr.center = ppg.product_center
    AND pr.id = ppg.product_id
    GROUP BY
        pr.center
        ,pr.id
    )
    , valid_subs AS
    (SELECT
        s.*
        , package_type.package_type
        , MIN(s.start_date) over (
                              PARTITION BY
                                  s.owner_center
                                  ,s.owner_id) AS min_start_date
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time DESC
                            , (ppgl.product_center IS NOT NULL)::INTEGER DESC) AS rnk
    FROM
        subscriptions s
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    LEFT JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id= 203
    LEFT JOIN
        package_type
    ON
        package_type.center =s.SUBSCRIPTIONTYPE_CENTER
    AND package_type.id = s.SUBSCRIPTIONTYPE_ID
    )
    , last_rel_state AS
    (SELECT
        DISTINCT scl.center
        ,scl.id
    FROM
        params
    JOIN
        state_change_log scl
    ON
        params.center = scl.center
    WHERE
        scl.entry_type = 4
    AND scl.entry_start_time > params.from_time
    GROUP BY
        scl.center
        ,scl.id
        ,scl.subid
    )
    , guest_pass_products AS
    ( SELECT
        DISTINCT mpr.globalid
    FROM
        params
        , masterproductregister mpr
    JOIN
        privilege_grants pg
    ON
        mpr.id = pg.granter_id
    AND pg.privilege_set = 801 --Guest Pass Eligible
    WHERE
        pg.granter_service = 'GlobalSubscription'
    AND
        (
            pg.valid_to > params.from_time
        OR  pg.valid_to IS NULL)
    )
SELECT
    COALESCE(legacyPersonId.txtvalue,p.external_id) AS ContactGUID
    , p.external_id                                 AS MemRefNo
    , COALESCE(s.package_type, 'STANDARD')          AS PackageType
     , COALESCE(latest_join_attr.txtvalue::date,s.start_date)    LatestJoinDate
    , CASE
        WHEN s.state IN (2,4)
        THEN 'ACTIVE'
        ELSE 'CANCELLED'
    END          AS Active
    , p.center   AS HomeSiteID
    , s.end_Date AS CancellationDate
    , mpr.globalid IS NOT NULL
AND DATE_PART('YEAR', AGE(CURRENT_DATE,p.birthdate)) >= 18 
AND s.state IN (2,4)                                      AS EligibleGuestPasses
    , CAST(fh.FreezeFrom AS DATE)                              AS FutureFrozenStartDate
    , cs.package_type                                          AS FuturePackageType
    , cs.start_date                                            AS FuturePackageStartDate
    , TO_CHAR(p.birthdate, 'YYYY-MM-DD')                       AS BirthDate
    , COALESCE(opp.contactguid, mfp.contactguid,p.contactguid) AS PrimaryContactGUID
FROM
    params
JOIN
    p_det p
ON
    p.center = params.center
LEFT JOIN
    valid_subs s
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
AND s.rnk = 1
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    p_det opp
ON
    op.center = opp.center
AND op.id = opp.id
LEFT JOIN
    last_rel_state last_rel_state_op
ON
    last_rel_state_op.center = op.center
AND last_rel_state_op.id = op.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id= p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    p_det mfp
ON
    mf.relativecenter =mfp.center
AND mf.relativeid =mfp.id
LEFT JOIN
    last_rel_state last_rel_state_mf
ON
    last_rel_state_mf.center = mf.center
AND last_rel_state_mf.id = mf.id
LEFT JOIN
    valid_subs cs
ON
    p.center = cs.owner_center
AND p.id = cs.owner_id
AND cs.start_Date > CURRENT_DATE
AND cs.sub_state != 8
LEFT JOIN
    products cspr
ON
    cspr.center = cs.SUBSCRIPTIONTYPE_CENTER
AND cspr.id = cs.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    future_freeze AS fh
ON
    fh.subscription_center = s.center
AND fh.subscription_id = s.id
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    guest_pass_products mpr
ON
    mpr.globalid = pr.globalid
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
WHERE
    (
    GREATEST(p.last_modified,s.last_modified,fh.last_modified,cs.last_modified,latest_join_attr.last_edit_time) >
    params.from_time
    OR  last_rel_state_mf.id IS NOT NULL
    OR  last_rel_state_op.id IS NOT NULL) 
AND
    (
        p.status IN(1,2,3)
    OR
        (
            p.status IN(0,6)
        AND p.persontype =8) )