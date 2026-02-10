-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    scopes AS MATERIALIZED (
        SELECT id
        FROM centers c
        WHERE c.id IN ($$Scope$$)
    ),
    params AS MATERIALIZED (
        SELECT
            (EXTRACT(EPOCH FROM ((date_trunc('month', CURRENT_DATE) - INTERVAL '6 months')
                AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint AS cutDate_ms,
            ((date_trunc('month', CURRENT_DATE) - INTERVAL '6 months')
                AT TIME ZONE 'Australia/Sydney')::timestamp AS cutDate_ts,
            CAST($$ApplyDate$$ AS DATE) AS applyDate,
            (CAST($$ApplyDate$$ AS DATE) - INTERVAL '6 months') AS applyminus6,
            (CAST($$ApplyDate$$ AS DATE) - INTERVAL '3 months') AS applyminus3
    ),
    params2 AS MATERIALIZED (
        SELECT
            (EXTRACT(EPOCH FROM ((date_trunc('month', CURRENT_DATE) - INTERVAL '6 months')
                AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint AS cutDate_ms,
            ((date_trunc('month', CURRENT_DATE) - INTERVAL '6 months')
                AT TIME ZONE 'Australia/Sydney')::timestamp AS cutDate_ts,
            CAST($$ApplyDate$$ AS DATE) AS applyDate,
            (CAST($$ApplyDate$$ AS DATE) - INTERVAL '6 months') AS applyminus6
    ),
    subs AS (
        SELECT
            sub.center AS subscription_center,
            sub.id AS subscription_id,
            sub.owner_center,
            sub.owner_id,
            sub.subscriptiontype_center,
            sub.subscriptiontype_id,
            stype.productnew_center,
            stype.productnew_id,
            sub.subscription_price
        FROM subscriptions sub
        JOIN scopes ON scopes.id = sub.center
        JOIN subscriptiontypes stype
          ON sub.subscriptiontype_center = stype.center
         AND sub.subscriptiontype_id = stype.id
        CROSS JOIN params
        WHERE stype.st_type = 1
          AND sub.state = 2
          AND sub.state <> 4
          AND sub.is_price_update_excluded = 0
          AND stype.is_price_update_excluded = 0
          AND (sub.binding_end_date IS NULL OR sub.binding_end_date < params.applyDate)
          AND (sub.end_date IS NULL OR sub.end_date > params.applyDate)
          AND sub.start_date < params.applyminus3
          AND NOT EXISTS (
              SELECT 1
              FROM subscription_price sp
              WHERE sp.subscription_center = sub.center
                AND sp.subscription_id = sub.id
                AND (
                       sp.type IN ('NORMAL','MANUAL')
                    OR (
                       sp.type IN ('SCHEDULED','CONVERSION')
                       AND sp.applied = 1
                       )
                    )
                AND sp.from_date >= params.applyminus3
          )
          AND NOT EXISTS (
              SELECT 1
              FROM cashcollectioncases cc
              WHERE cc.personcenter = sub.owner_center
                AND cc.personid = sub.owner_id
                AND cc.missingpayment = 1
                AND cc.startdate < (CURRENT_TIMESTAMP - INTERVAL '30 days')
                AND cc.closed = 0
                AND EXISTS (SELECT 1 FROM scopes s WHERE s.id = cc.personcenter)
          )
          AND NOT EXISTS (
              SELECT 1
              FROM cashcollectioncases cc
              JOIN relatives op_rel
                ON op_rel.center = cc.personcenter
               AND op_rel.id = cc.personid
               AND op_rel.rtype = 12
               AND op_rel.status < 3
              WHERE cc.missingpayment = 1
                AND cc.startdate < (CURRENT_TIMESTAMP - INTERVAL '30 days')
                AND cc.closed = 0
                AND op_rel.relativecenter = sub.owner_center
                AND op_rel.relativeid = sub.owner_id
                AND EXISTS (SELECT 1 FROM scopes s WHERE s.id = op_rel.center)
          )
          AND NOT EXISTS (
              SELECT 1
              FROM product_and_product_group_link link
              WHERE link.product_center = sub.subscriptiontype_center
                AND link.product_id = sub.subscriptiontype_id
                AND $$excludeJunior$$ = 1
                AND link.product_group_id IN (5406,5407,239,242,9802,9801,9803,9804,219)
          )
    ),
    lp AS MATERIALIZED (
        SELECT
            rank() OVER (PARTITION BY sp.subscription_center, sp.subscription_id ORDER BY sp.from_date DESC) AS rnk,
            sp.subscription_center,
            sp.subscription_id,
            sp.from_date,
            sp.price
        FROM subscription_price sp
        WHERE sp.applied = 1
          AND sp.cancelled = 0
          AND (($$EXCLUDE_STATES$$::text <> '4' OR sp.pending <> 1)
           AND ($$EXCLUDE_STATES$$::text <> '3' OR sp.approved <> 1))
          AND EXISTS (
              SELECT 1
              FROM subs
              WHERE sp.subscription_center = subs.subscription_center
                AND sp.subscription_id = subs.subscription_id
          )
    ),
    subs_persons AS (
        SELECT
            sub.subscription_center AS subcenter,
            sub.subscription_id AS subid,
            centre.id AS clubid,
            centre.shortname AS club,
            p.external_id AS externalid,
            p.center AS personcenter,
            p.id AS personid,
            comp.fullname AS companyname,
            date_part('year', age(current_date, p.birthdate)) AS age,
            (date_part('year', age(current_date, p.first_active_start_date)) * 12
             + date_part('month', age(current_date, p.first_active_start_date)))::numeric(10,1) AS tenure_months,
            CASE p.persontype
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                ELSE 'UNKNOWN'
            END AS persontype,
            sub.subscription_center || 'ss' || sub.subscription_id AS eclubsubscriptionid,
            prod.name AS subscription,
            CASE WHEN prod.blocked = 1 OR joinprod.blocked = 1 THEN 'YES' ELSE 'NO' END AS legacy,
            prod.price AS productprice,
            pp.price_modification_amount,
            sub.subscription_price AS currentprice,
            TO_CHAR(lp.from_date,'YYYY-MM-DD') AS lastpriceincrease,
            lp2.price AS pricebeforeincrease,
            pex.txtvalue AS lastpriceupdatemigrated
        FROM subs sub
        JOIN products prod
            ON sub.subscriptiontype_center = prod.center
           AND sub.subscriptiontype_id = prod.id
        JOIN centers centre
            ON sub.subscription_center = centre.id
        JOIN products joinprod
            ON sub.productnew_center = joinprod.center
           AND sub.productnew_id = joinprod.id
        JOIN persons p
            ON p.center = sub.owner_center
           AND p.id = sub.owner_id
        LEFT JOIN relatives r
            ON r.rtype = 3
           AND r.center = p.center
           AND r.id = p.id
           AND r.status < 2
        LEFT JOIN persons comp
            ON comp.center = r.relativecenter
           AND comp.id = r.relativeid
        LEFT JOIN person_ext_attrs pex
            ON pex.personcenter = p.center
           AND pex.personid = p.id
           AND pex.name = 'LAST_PRICE_INCREASE'
        LEFT JOIN privilege_grants pg
            ON pg.granter_service = 'CompanyAgreement'
           AND pg.granter_center = r.relativecenter
           AND pg.granter_id = r.relativeid
           AND pg.granter_subid = r.relativesubid
           AND pg.valid_to IS NULL
        LEFT JOIN privilege_sets ps
            ON ps.id = pg.privilege_set
        LEFT JOIN product_privileges pp
            ON pp.privilege_set = ps.id
           AND pp.ref_globalid = prod.globalid
           AND pp.valid_to IS NULL
        LEFT JOIN lp
            ON lp.subscription_center = sub.subscription_center
           AND lp.subscription_id = sub.subscription_id
           AND lp.rnk = 1
        LEFT JOIN lp AS lp2
            ON lp2.subscription_center = sub.subscription_center
           AND lp2.subscription_id = sub.subscription_id
           AND lp2.rnk = 2
        WHERE (pex.personcenter IS NULL
               OR ( (to_date(pex.txtvalue, 'YYYY-MM-DD') + INTERVAL '3 months') <= CAST($$ApplyDate$$ AS DATE) ))
    ),
    person_subs_agg AS MATERIALIZED (
        SELECT
            subcenter,
            subid,
            clubid,
            club,
            externalid,
            personcenter,
            personid,
            companyname,
            age,
            tenure_months AS tenure,
            persontype,
            eclubsubscriptionid,
            subscription,
            legacy,
            productprice,
            price_modification_amount,
            currentprice,
            lastpriceincrease,
            pricebeforeincrease,
            lastpriceupdatemigrated,
            COUNT(*) AS counter
        FROM subs_persons
        GROUP BY
            subcenter, subid, clubid, club, externalid, personcenter, personid,
            companyname, age, tenure_months, persontype, eclubsubscriptionid, subscription,
            legacy, productprice, price_modification_amount, currentprice, lastpriceincrease,
            pricebeforeincrease, lastpriceupdatemigrated
    ),
    visits AS MATERIALIZED (
        SELECT DISTINCT
            c.person_center,
            c.person_id,
            COUNT(*) AS total_visits
        FROM checkins c
        JOIN scopes ON scopes.id = c.person_center
        JOIN person_subs_agg t1
          ON t1.personcenter = c.person_center
         AND t1.personid = c.person_id
        CROSS JOIN params2
        WHERE
        (extract(epoch FROM (c.checkout_time - c.checkin_time)) >= 1000)  
        AND c.checkin_time > params2.cutDate_ts
        AND c.person_id IS NOT NULL
        GROUP BY c.person_id, c.person_center
    )
SELECT
    t1.subcenter,
    t1.subid,
    t1.clubId,
    t1.club
FROM person_subs_agg t1
LEFT JOIN visits c
  ON t1.personcenter=c.person_center
 AND t1.personid=c.person_id;
