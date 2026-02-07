SELECT DISTINCT
    p.center || 'p' || p.id AS PersonId,
    pe.txtvalue             AS "Secondary ClubId",
    secCenter.name          AS "Secondary Club Name",
    s.start_date            AS "Subscription start date",
    prod.name               AS "Product Name"
FROM
    persons p
JOIN
    person_ext_attrs pe
ON
    pe.personcenter = p.center
    AND pe.personid = p.id
    AND pe.name = 'SECONDARY_CENTER'
    AND pe.txtvalue IS NOT NULL
JOIN
    centers secCenter
ON
    secCenter.id = pe.txtvalue
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
ON
    prod.center = st.center
    AND prod.id = st.id
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prod.GLOBALID
    AND mpr.scope_id = prod.center
WHERE
    s.state IN (2,4,8)    
    AND s.start_date = TRUNC(SYSDATE-1)
    AND EXISTS
    (
        SELECT
            1
        FROM
            PRIVILEGE_GRANTS pg,
            PRIVILEGE_SETS ps,
            BOOKING_PRIVILEGES bp,
            BOOKING_PRIVILEGE_GROUPS bpg
        WHERE
            pg.GRANTER_ID = mpr.ID
            AND pg.GRANTER_SERVICE = 'GlobalSubscription'
            AND ps.ID = pg.PRIVILEGE_SET
            AND bp.PRIVILEGE_SET = ps.ID
            AND bpg.ID = bp.GROUP_ID
            AND bpg.name = 'Fitness'
			and ps.name = 'Membership: Access Local')