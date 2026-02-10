-- The extract is extracted from Exerp on 2026-02-08
-- Created for Ebbie on request from SR-336551 to amend the logic to exclude any members who had a price increase 3 months ago
WITH
    scopes AS MATERIALIZED
    (
        SELECT
            id
        FROM
            centers c
        WHERE
            c.id IN ($$Scope$$)
    )
    ,
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(
                extract(
                    epoch FROM timezone('Europe/London',
                    CAST(CURRENT_DATE - interval '3 months' AS TIMESTAMP))
                ) AS bigint
            ) * 1000 AS cutDate,
            
            CAST($$ApplyDate$$ AS DATE) AS applyDate,
            ADD_MONTHS(CAST($$ApplyDate$$ AS DATE), -6) AS applyminus6,
            ADD_MONTHS(CAST($$ApplyDate$$ AS DATE), -3) AS applyminus3
    )
    ,
    PARAMS2 AS MATERIALIZED
    (
        SELECT
            CAST(
                extract(
                    epoch FROM timezone('Europe/London',
                    CAST(CURRENT_DATE - interval '3 months' AS TIMESTAMP))
                ) AS bigint
            ) * 1000 AS cutDate,

            CAST($$ApplyDate$$ AS DATE) AS applyDate,
            ADD_MONTHS(CAST($$ApplyDate$$ AS DATE), -6) AS applyminus6
    )
    ,
    subs AS
    (
        SELECT
            sub.center                        AS SUBSCRIPTION_CENTER,
            sub.id                            AS SUBSCRIPTION_ID,
            (sub.center , sub.id)             AS subscription_key,
            (sub.owner_center , sub.owner_id) AS owner_key,
            sub.owner_center,
            sub.owner_id,
            sub.SUBSCRIPTIONTYPE_CENTER,
            sub.SUBSCRIPTIONTYPE_ID,
            stype.PRODUCTNEW_CENTER,
            stype.PRODUCTNEW_ID,
            sub.SUBSCRIPTION_PRICE
        FROM
            params,
            SUBSCRIPTIONS sub
        JOIN
            scopes
        ON
            scopes.id = sub.center
        JOIN
            SUBSCRIPTIONTYPES stype
        ON
            sub.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
        AND sub.SUBSCRIPTIONTYPE_ID = stype.ID
        WHERE
            sub.center IN (SELECT id FROM scopes)
        AND stype.ST_TYPE = 1
        AND sub.STATE = 2
        AND sub.STATE <> 4
        AND sub.IS_PRICE_UPDATE_EXCLUDED = 0
        AND stype.IS_PRICE_UPDATE_EXCLUDED = 0
        AND (sub.BINDING_END_DATE IS NULL OR sub.BINDING_END_DATE < params.applyDate)
        AND (sub.END_DATE IS NULL OR sub.END_DATE > params.applyDate)
        AND sub.START_DATE < params.applyminus3
        AND (sub.center, sub.id) NOT IN
        (
            SELECT
                sp.SUBSCRIPTION_CENTER, sp.SUBSCRIPTION_ID
            FROM
                SUBSCRIPTION_PRICE sp
            WHERE
                sp.SUBSCRIPTION_CENTER = sub.CENTER
            AND sp.SUBSCRIPTION_ID = sub.ID
            AND (
                    sp.TYPE IN ('NORMAL','MANUAL')
                OR (
                        sp.TYPE IN ('SCHEDULED','CONVERSION')
                    AND sp.APPLIED = 1
                )
            )
            AND sp.FROM_DATE >= params.applyminus3
        )
        AND (sub.OWNER_CENTER,sub.OWNER_ID) NOT IN
        (
            SELECT
                cc.PERSONCENTER, cc.PERSONID
            FROM
                CASHCOLLECTIONCASES cc
            JOIN
                scopes
            ON
                scopes.id = cc.personcenter
            WHERE
                cc.MISSINGPAYMENT = 1
            AND cc.STARTDATE < CURRENT_TIMESTAMP - 30
            AND cc.CLOSED = 0
            AND (cc.PERSONCENTER, cc.PERSONID) = (sub.OWNER_CENTER,sub.OWNER_ID)
        )
        AND (sub.OWNER_CENTER,sub.OWNER_ID) NOT IN
        (
            SELECT
                op_rel.RELATIVECENTER, op_rel.RELATIVEID
            FROM
                CASHCOLLECTIONCASES cc
            JOIN
                RELATIVES op_rel
            ON
                op_rel.CENTER = cc.PERSONCENTER
            AND op_rel.ID = cc.PERSONID
            AND op_rel.RTYPE = 12
            AND op_rel.STATUS < 3
            JOIN
                scopes
            ON
                scopes.id = op_rel.CENTER
            WHERE
                cc.MISSINGPAYMENT = 1
            AND cc.STARTDATE < CURRENT_TIMESTAMP - 30
            AND cc.CLOSED = 0
            AND (op_rel.RELATIVECENTER, op_rel.RELATIVEID) =
                (sub.OWNER_CENTER,sub.OWNER_ID)
        )
        AND (sub.SUBSCRIPTIONTYPE_CENTER, sub.SUBSCRIPTIONTYPE_ID) NOT IN
        (
            SELECT
                link.PRODUCT_CENTER, link.PRODUCT_ID
            FROM
                PRODUCT_AND_PRODUCT_GROUP_LINK link
            WHERE
                link.PRODUCT_CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND link.PRODUCT_ID = sub.SUBSCRIPTIONTYPE_ID
            AND $$excludeJunior$$ = 1
            AND link.PRODUCT_GROUP_ID IN (5406,5407,239,242,9802,9801,9803,9804,219)
        )
    )
    ,
    lp AS MATERIALIZED
    (
        SELECT
            RANK() OVER (
                PARTITION BY sp.SUBSCRIPTION_CENTER, sp.SUBSCRIPTION_ID
                ORDER BY sp.FROM_DATE DESC
            ) AS rnk,
            sp.subscription_center,
            sp.subscription_id,
            sp.from_date,
            sp.price
        FROM
            SUBSCRIPTION_PRICE sp
        WHERE
            sp.APPLIED = 1
        AND sp.CANCELLED = 0
        AND NOT ($$EXCLUDE_STATES$$ = '4' AND sp.PENDING = 1)
        AND NOT ($$EXCLUDE_STATES$$ = '3' AND sp.APPROVED = 1)
        AND EXISTS
        (
            SELECT 1
            FROM subs
            WHERE sp.SUBSCRIPTION_CENTER = subs.SUBSCRIPTION_CENTER
            AND sp.SUBSCRIPTION_ID = subs.SUBSCRIPTION_ID
        )
    )
    ,
    subs_persons AS
    (
        SELECT
            sub.SUBSCRIPTION_CENTER AS subcenter,
            sub.SUBSCRIPTION_ID AS subid,
            centre.ID AS clubId,
            centre.SHORTNAME AS club,
            p.EXTERNAL_ID AS externalId,
            p.CENTER AS PersonCenter,
            p.ID AS PersonId,
            comp.Fullname AS CompanyName,
            ROUND(((CURRENT_DATE - p.birthdate)/365),0) AS age,
            ROUND(((CURRENT_DATE - p.FIRST_ACTIVE_START_DATE)/30),1) AS tenure,
            CASE p.PERSONTYPE
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
            END AS PERSONTYPE,
            sub.SUBSCRIPTION_CENTER || 'ss' || sub.SUBSCRIPTION_ID AS eClubSubscriptionId,
            prod.name AS subscription,
            CASE
                WHEN prod.BLOCKED = 1 OR joinProd.BLOCKED = 1 THEN 'YES'
                ELSE 'NO'
            END AS LEGACY,
            prod.PRICE AS PRODUCTPRICE,
            pp.PRICE_MODIFICATION_AMOUNT,
            sub.SUBSCRIPTION_PRICE AS CURRENTPRICE,
            TO_CHAR(lp.from_date,'YYYY-MM-DD') AS lastPriceIncrease,
            lp2.PRICE AS priceBeforeIncrease,
            pex.TXTVALUE AS lastPriceUpdateMigrated
        FROM
            subs sub
        JOIN
            PRODUCTS prod
        ON
            sub.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
        AND sub.SUBSCRIPTIONTYPE_ID = prod.ID
        JOIN
            CENTERS centre
        ON
            sub.SUBSCRIPTION_CENTER = centre.ID
        JOIN
            PRODUCTS joinProd
        ON
            sub.PRODUCTNEW_CENTER = joinProd.CENTER
        AND sub.PRODUCTNEW_ID = joinProd.ID
        JOIN
            persons p
        ON
            p.CENTER = sub.OWNER_CENTER
        AND p.ID = sub.OWNER_ID
        LEFT JOIN
            RELATIVES r
        ON
            r.RTYPE = 3
        AND r.CENTER = p.CENTER
        AND r.ID = p.ID
        AND r.STATUS < 2
        LEFT JOIN
            persons comp
        ON
            comp.CENTER = r.RELATIVECENTER
        AND comp.ID = r.RELATIVEID
        LEFT JOIN
            person_ext_attrs pex
        ON
            pex.PERSONCENTER = p.CENTER
        AND pex.PERSONID = p.ID
        AND pex.NAME = 'LAST_PRICE_INCREASE'
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE = 'CompanyAgreement'
        AND pg.GRANTER_CENTER = r.RELATIVECENTER
        AND pg.GRANTER_ID = r.RELATIVEID
        AND pg.GRANTER_SUBID = r.RELATIVESUBID
        AND pg.VALID_TO IS NULL
        LEFT JOIN
            PRIVILEGE_SETS ps
        ON
            ps.ID = pg.PRIVILEGE_SET
        LEFT JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = ps.id
        AND pp.REF_GLOBALID = prod.GLOBALID
        AND pp.VALID_TO IS NULL
        LEFT JOIN
            lp
        ON
            lp.SUBSCRIPTION_CENTER = sub.SUBSCRIPTION_CENTER
        AND lp.SUBSCRIPTION_ID = sub.SUBSCRIPTION_ID
        AND lp.RNK = 1
        LEFT JOIN
            lp AS lp2
        ON
            lp2.SUBSCRIPTION_CENTER = sub.SUBSCRIPTION_CENTER
        AND lp2.SUBSCRIPTION_ID = sub.SUBSCRIPTION_ID
        AND lp2.RNK = 2
        WHERE
            (
                pex.PERSONCENTER IS NULL
                OR ADD_MONTHS(TO_DATE(pex.TXTVALUE, 'YYYY-MM-DD'), 3)
                    <= CAST($$ApplyDate$$ AS DATE)
            )
    )
    ,
    person_subs_agg AS MATERIALIZED
    (
        SELECT DISTINCT
            *,
            COUNT(*) AS counter
        FROM
            subs_persons
        GROUP BY
            subcenter, subid, clubid, club, externalid,
            personcenter, personid, companyname, age, tenure,
            persontype, eclubsubscriptionid, subscription, legacy,
            productprice, price_modification_amount, currentprice,
            lastpriceincrease, pricebeforeincrease, lastpriceupdatemigrated
    )
    ,
    visits AS MATERIALIZED
    (
        SELECT DISTINCT
            c.PERSON_CENTER,
            c.PERSON_ID,
            COUNT(*) AS total_visits
        FROM
            params2,
            CHECKINS c
        JOIN
            scopes
        ON
            scopes.id = c.person_center
        JOIN
            person_subs_agg t1
        ON
            t1.PersonCenter = c.PERSON_CENTER
        AND t1.PersonId = c.PERSON_ID
        WHERE
            c.checkout_time != c.checkin_time
        AND NOT c.checkout_time - c.checkin_time < 1000
        AND c.CHECKIN_TIME > params2.cutDate
        AND c.person_id IS NOT NULL
        GROUP BY
            person_id, person_center
    )
SELECT
    t1.subcenter,
    t1.subid,
    t1.clubId AS "ClubID",
    t1.club AS "Club",
    t1.externalId AS "External ID",
    t1.age AS "Age",
    t1.tenure AS "Tenure (months)",
    COALESCE(c.total_visits,0) AS "Visits in the Last 3 months",
    t1.PERSONTYPE AS "PersonType",
    t1.COMPANYNAME AS "Company Name",
    t1.eClubSubscriptionId AS "eClub Subscription ID",
    t1.subscription AS "Subscription",
    t1.LEGACY AS "Legacy",
    t1.PRODUCTPRICE AS "Product Price",
    t1.PRICE_MODIFICATION_AMOUNT AS "Company Price Modification",
    t1.CURRENTPRICE AS "Current Price",
    t1.lastPriceIncrease AS "Date of Last Price Increase",
    t1.priceBeforeIncrease AS "Value Before LastPriceIncrease",
    t1.lastPriceUpdateMigrated AS "Last Price Update Migrated",
    t1.counter AS "Count"
FROM
    person_subs_agg t1
LEFT JOIN
    visits c
ON
    t1.PersonCenter = c.PERSON_CENTER
AND t1.PersonId = c.PERSON_ID;
