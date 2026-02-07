WITH
    params AS MATERIALIZED
    (   SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
            c.id) AS BIGINT) AS currentLongDate,
            c.id             AS centerid,
            c.name           AS centername
        FROM
            centers c
    )
    ,
    companies AS
    (   SELECT
            DISTINCT com.fullname AS company_name,
            r.center              AS member_center,
            r.id                  AS member_id,
            CASE
                WHEN pg.sponsorship_name = 'FIXED'
                THEN 'Part-Sub'
                WHEN pg.sponsorship_name = 'FULL'
                THEN 'Full-Sub'
                WHEN pg.sponsorship_name = 'NONE'
                THEN 'None-Sub'
            END                   AS agr_type,
            pg.sponsorship_amount AS sponsor_amount,
            prod.globalid
        FROM
            persons com
        JOIN
            companyagreements ca
        ON
            ca.center = com.center
        AND ca.id = com.id
        JOIN
            params
        ON
            params.centerid = ca.center
        JOIN
            relatives r
        ON
            r.rtype = 3
        AND r.relativecenter = ca.center
        AND r.relativeid = ca.id
        AND r.relativesubid = ca.subid
        AND r.status = 1
        JOIN
            privilege_grants pg
        ON
            pg.granter_service = 'CompanyAgreement'
        AND pg.granter_center = ca.center
        AND pg.granter_id = ca.id
        AND pg.granter_subid = ca.subid
        JOIN
            product_privileges pp
        ON
            pp.privilege_set = pg.privilege_set
        AND pp.ref_type = 'GLOBAL_PRODUCT'
        JOIN
            products prod
        ON
            prod.globalid = pp.ref_globalid
        AND prod.ptype = 10
        WHERE
            com.sex = 'C'
        AND pg.valid_from <= params.currentLongDate
        AND
            (
                pg.valid_to IS NULL
            OR  pg.valid_to >= params.currentLongDate)
    )
SELECT
    p.center ||'p'|| p.id AS "Membership Number",
    CASE
        WHEN pea.txtvalue IS NULL
        THEN p.external_id
        ELSE pea.txtvalue
    END                            AS "Member External ID",
    par.centername                 AS "Center",
    NULL                           AS "Salutation",
    p.firstname                    AS "Firstname",
    p.lastname                     AS "Lastname",
    pro.name                       AS "Subscription Plan",
    NULL                           AS "Class Plan",
    pro.price                      AS "Product Price",
    s.subscription_price           AS "Member Paying Current Price",
    fp.price                       AS "Future Price",
    pro.price-s.subscription_price AS "Variance",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END                AS "Person Type",
    s.binding_end_date AS "Binding Date",
    NULL               AS "New Price",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END                      AS "Member Status",
    s.start_date             AS "Start Date",
    p.last_active_start_date AS "Most Recent Join Date",
    subpr.from_date          AS "Date of Last Price Change",
    sfp.start_date           AS "Current Freeze Start",
    sfp.end_date             AS "Current Freeze End",
    addon.name               AS "Add-on Name",
    addon.price              AS "Add-on Price",
    CASE
        WHEN comp.company_name IS NULL
        THEN com2.fullname
        ELSE comp.company_name
    END AS "Company Name",
    CASE
        WHEN p.persontype = 4 
        AND comp.agr_type IS NULL
        THEN 'None-Sub'
        ELSE comp.agr_type
    END AS "Corporate Subsidy Type",
    CASE
        WHEN comp.agr_type = 'Part-Sub'
        THEN s.subscription_price-comp.sponsor_amount
        WHEN comp.agr_type = 'Full-Sub'
        THEN 0
        WHEN comp.agr_type = 'None-Sub'
        THEN s.subscription_price
        WHEN p.persontype = 4 
        AND comp.agr_type IS NULL
        THEN s.subscription_price
    END AS "Member Portion Fee",
    CASE
        WHEN comp.agr_type = 'Part-Sub'
        THEN comp.sponsor_amount
        WHEN comp.agr_type = 'Full-Sub'
        THEN s.subscription_price
        WHEN comp.agr_type = 'None-Sub'
        THEN 0
        WHEN p.persontype = 4 
        AND comp.agr_type IS NULL
        THEN 0
    END AS "Corporate Portion Fee"
FROM
    persons p
JOIN
    params par
ON
    par.centerid = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    subscriptiontypes sty
ON
    sty.center = s.subscriptiontype_center
AND sty.id = s.subscriptiontype_id
JOIN
    products pro
ON
    pro.center = sty.center
AND pro.id = sty.id
JOIN
    (   SELECT
            RANK() over (
                     PARTITION BY
                         sp.subscription_center,
                         sp.subscription_id
                     ORDER BY
                         sp.from_date DESC) AS rnk,
            sp.subscription_center,
            sp.subscription_id,
            sp.from_date,
            sp.price
        FROM
            subscription_price sp
        WHERE
            sp.applied = 1
        AND sp.cancelled = 0) subpr
ON
    subpr.subscription_center = s.center
AND subpr.subscription_id = s.id
AND subpr.rnk = 1
LEFT JOIN
    subscription_freeze_period sfp
ON
    sfp.subscription_center = s.center
AND sfp.subscription_id = s.id
AND sfp.start_date <= par.currentDate
AND sfp.end_date >= par.currentDate
AND sfp.state = 'ACTIVE'
LEFT JOIN
    (   SELECT
            sa.subscription_center,
            sa.subscription_id,
            mpr.cached_productname       AS NAME,
            sa.individual_price_per_unit AS price
        FROM
            subscription_addon sa
        JOIN
            params
        ON
            params.centerid = sa.center_id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        WHERE
            sa.start_date <= params.currentDate
        AND
            (
                sa.end_date >= params.currentDate
            OR  sa.end_date IS NULL)
        AND sa.cancelled = false ) addon
ON
    addon.subscription_center = s.center
AND addon.subscription_id = s.id
LEFT JOIN
    companies comp
ON
    comp.member_center = p.center
AND comp.member_id = p.id
AND comp.globalid = pro.globalid
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    subscription_price fp
ON
    fp.subscription_center = s.center
AND fp.subscription_id = s.id
AND fp.from_date > par.currentDate
AND fp.cancelled = 0
LEFT JOIN
    relatives rel2
ON
    rel2.relativecenter = p.center
AND rel2.relativeid = p.id
AND rel2.rtype = 2
AND rel2.status = 1
LEFT JOIN
    persons com2
ON
    com2.center = rel2.center
AND com2.id = rel2.id
WHERE
    p.persontype NOT IN (2)
AND s.state IN (2,4)
AND p.center IN (:scope)
AND NOT EXISTS
    (   SELECT
            1
        FROM
            subscriptions sub
        JOIN
            subscriptiontypes st
        ON
            st.center = sub.subscriptiontype_center
        AND st.id = sub.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            product_and_product_group_link prgl
        ON
            prgl.product_center = pr.center
        AND prgl.product_id = pr.id
        JOIN
            product_group pg
        ON
            pg.id = prgl.product_group_id
        WHERE
            sub.center = s.center
        AND sub.id = s.id
        AND pg.name IN ('PIF Subscriptions',
                        'Complimentary Subsciptions'))
ORDER BY
    p.center,
    p.id