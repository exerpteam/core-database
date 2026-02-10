-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10945
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
    , spa_products AS
    ( SELECT
        mpr.globalid
        ,CASE
            WHEN bool_or(ps.name = 'Away Spa Access')
            THEN 'away'
            WHEN bool_or(ps.name = 'Home Spa Access')
            THEN 'home'
        END AS spa_access_level
    FROM
        params
        , masterproductregister mpr
    JOIN
        privilege_grants pg
    ON
        pg.granter_service = 'GlobalSubscription'
    AND mpr.id = pg.granter_id
    JOIN
        privilege_sets ps
    ON
        pg.privilege_set = ps.id
    JOIN
        booking_privileges bp
    ON
        pg.privilege_set = bp.privilege_set
    WHERE
        bp.group_id = 201 -- spa access
    AND pg.granter_service = 'GlobalSubscription'
    AND
        (
            pg.valid_to > params.from_time
        OR  pg.valid_to IS NULL)
    GROUP BY
        mpr.globalid
    )
    , included_subs AS
    (SELECT
        DISTINCT s.*
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time DESC) AS rnk
    FROM
        subscriptions s
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
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
    , package_group AS
    ( SELECT
        pr.center
        ,pr.id
        ,CASE
            WHEN bool_or(ppg.product_group_id IN (12 )) -- Child
            THEN 'Child'
            WHEN bool_or(ppg.product_group_id IN (201
                                                  , 207
                                                  , 241)) -- Diamond, Non Countable Diamond,
                -- Diamond Plus
            THEN 'Diamond'
            WHEN bool_or(ppg.product_group_id IN (3)) -- Team Members
            THEN 'Team'
            WHEN bool_or(ppg.product_group_id IN (339)) --Franchise Cleaner
            THEN 'Franchise'
            WHEN bool_or(ppg.product_group_id IN (340)) -- Founder
            THEN 'Franchise (Cleaners)'
            WHEN bool_or(ppg.product_group_id IN (243,211)) --Platinum, Non Countable Platinum
            THEN 'Platinum'
            WHEN bool_or(ppg.product_group_id IN (368 )) -- OTHER
            THEN 'Other'
            ELSE 'Other'
        END AS package_group
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
    ),
base_list as 
(
SELECT
     p.center                                                  AS "SiteID"
    ,c.external_id                                             AS "sitecode"
    ,p.external_id                                             AS "Memberreferencenumber"
    ,p.birthdate                                               AS "Birthdate"
    ,COALESCE(legacyPersonId.txtvalue,p.external_id)           AS "Contactguid"
    , COALESCE(opp.contactguid, mfp.contactguid,p.contactguid) AS "Primarycontactguid"
    , p.firstname                                              AS "FirstName"
    ,p.lastname                                                AS "LastName"
    ,p.zipcode                                                 AS "PostCode"
    , COALESCE(latest_join_attr.txtvalue::DATE,s.start_date)   AS "Joindate"
    , pr.globalid                                              AS "Membershippackagecode"
    , pr.name                                                  AS "Membershippackagename"
    , CASE
        WHEN spa_acc.name IN( 'AWAYSPA')
        OR  spa_products.spa_access_level ='away'
        THEN 'away'
        WHEN spa_acc.name IN( 'HOMESPA')
        OR  spa_products.spa_access_level ='home'
        THEN 'home'
        ELSE 'none'
    END AS "SpaAccess"
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8)
        THEN 'OK'
        WHEN p.status = 2
        THEN 'CANCEL'
        WHEN p.status = 3
        THEN 'FROZEN'
    END AS memberstatuscode
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8)
        THEN 'Package OK'
        WHEN p.status = 2
        THEN 'Package Cancelled'
        WHEN p.status = 3
        THEN 'Package Frozen'
    END      AS statusDescription
    ,package_group.package_group AS packagegroup
    , p.id, p.center
FROM
    p_det p
LEFT JOIN
    included_subs s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.rnk = 1
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    spa_products
ON
    spa_products.globalid = pr.globalid
JOIN
    params
ON
    params.center =p.center
LEFT JOIN
    person_ext_attrs spa_acc
ON
    spa_acc.personcenter = p.center
AND spa_acc.personid = p.id
AND spa_acc.name IN( 'HOMESPA'
                    ,'AWAYSPA')
AND spa_acc.txtvalue = 'YES'
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center =legacyPersonId.PERSONCENTER
AND p.id =legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    last_rel_state last_rel_state_op
ON
    last_rel_state_op.center = op.center
AND last_rel_state_op.id = op.id
LEFT JOIN
    p_det opp
ON
    op.center = opp.center
AND op.id = opp.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id = p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    last_rel_state last_rel_state_mf
ON
    last_rel_state_mf.center = mf.center
AND last_rel_state_mf.id = mf.id
LEFT JOIN
    p_det mfp
ON
    mf.relativecenter =mfp.center
AND mf.relativeid =mfp.id
JOIN
    centers c
ON
    c.id = p.center
LEFT JOIN
    package_group
ON
    package_group.center = pr.center 
AND package_group.id = pr.id
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
WHERE
   (p.status IN(1,2,3))  
AND
    (
        GREATEST(p.last_modified,s.last_modified ,spa_acc.last_edit_time) > params.from_time
    OR  last_rel_state_mf.id IS NOT NULL
    OR  last_rel_state_op.id IS NOT NULL)
)
    select 
       'Card' as "Type",
       card.identity AS "Number",
       p.* 
    FROM base_list p    
    JOIN
       entityidentifiers card
    ON
        p.center = card.REF_CENTER
        AND p.ID = card.REF_ID
        AND card.ref_type = 1
        AND card.stop_time IS NULL
        AND card.ENTITYSTATUS = 1
UNION ALL 
     select 
        'Wristband' as "Type",
        ei_rfid.identity AS "Number",
        p.*
     FROM 
     base_list p    
JOIN
    ENTITYIDENTIFIERS ei_rfid
ON
    ei_rfid.REF_CENTER = p.CENTER
AND ei_rfid.REF_ID = p.id
AND ei_rfid.entitystatus = 1
AND ei_rfid.idmethod = 4
AND ei_rfid.ref_type = 1