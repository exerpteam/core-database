-- The extract is extracted from Exerp on 2026-02-08
--  
WITH

    PARAMS AS
    (
        SELECT
            CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE - interval
            '6 months' AS TIMESTAMP))) AS bigint)*1000 AS cutDate,
            CAST($$ApplyDate$$ AS DATE)                      AS applyDate,
            ADD_MONTHS(CAST($$ApplyDate$$ AS DATE), -6)         applyminus6
    )
    ,
    PARAMS2 AS
    (
        SELECT
            CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE - interval
            '6 months' AS TIMESTAMP))) AS bigint)*1000 AS cutDate,
            CAST($$ApplyDate$$ AS DATE)                      AS applyDate,
            ADD_MONTHS(CAST($$ApplyDate$$ AS DATE), -6)         applyminus6
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
            SUBSCRIPTIONS sub
        CROSS JOIN
            params
        
        JOIN
            SUBSCRIPTIONTYPES stype
        ON
            sub.SUBSCRIPTIONTYPE_CENTER = stype.CENTER
        AND sub.SUBSCRIPTIONTYPE_ID = stype.ID
WHERE sub.center IN ($$Scope$$) 
        AND stype.ST_TYPE = 1
            -- Only active memberships
        AND sub.STATE = 2
            -- Membership not frozen, just explanatory
        AND sub.STATE <> 4
            -- Exclude price update excluded
        AND sub.IS_PRICE_UPDATE_EXCLUDED = 0
        AND stype.IS_PRICE_UPDATE_EXCLUDED = 0
            -- Exclude members of type corporate
            -- AND p.PERSONTYPE <> 4
            -- Exlude members with binding after apply date
        AND (
                sub.BINDING_END_DATE IS NULL
            OR  sub.BINDING_END_DATE < params.applyDate)
            -- Exclude ending before apply date
        AND (
                sub.END_DATE IS NULL
            OR  sub.END_DATE > params.applyDate)
            -- Exclude members started within last 6 months
        AND sub.START_DATE < params.applyminus6
        AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    SUBSCRIPTION_PRICE sp
                WHERE
                    sp.SUBSCRIPTION_CENTER = sub.CENTER
                AND sp.SUBSCRIPTION_ID = sub.ID
                AND (
                        sp.TYPE IN ('NORMAL',
                                    'MANUAL')
                    OR  (
                            sp.TYPE IN ('SCHEDULED',
                                        'CONVERSION')
                        AND sp.APPLIED = 1))
                AND ADD_MONTHS(sp.FROM_DATE, 12) > CAST($$ApplyDate$$ AS DATE))
        AND (
                sub.OWNER_CENTER,sub.OWNER_ID) NOT IN
            (
                SELECT
                    cc.PERSONCENTER,
                    cc.PERSONID
                FROM
                    CASHCOLLECTIONCASES cc
                
                WHERE
                    cc.MISSINGPAYMENT = 1
                AND cc.STARTDATE < CURRENT_TIMESTAMP - 30
                AND cc.CLOSED = 0
                         AND cc.PERSONCENTER IN ($$Scope$$)
                AND (
                        cc.PERSONCENTER, cc.PERSONID) = ( sub.OWNER_CENTER,sub.OWNER_ID))
        AND (
                sub.OWNER_CENTER,sub.OWNER_ID) NOT IN
            (
                SELECT
                    op_rel.RELATIVECENTER,
                    op_rel.RELATIVEID
                FROM
                    CASHCOLLECTIONCASES cc
                JOIN
                    RELATIVES op_rel
                ON
                    op_rel.CENTER = CC.PERSONCENTER
                AND op_rel.ID = CC.PERSONID
                AND op_rel.RTYPE = 12
                AND op_rel.STATUS < 3
                
                WHERE
                    cc.MISSINGPAYMENT = 1
                AND cc.STARTDATE < CURRENT_TIMESTAMP - 30
                AND cc.CLOSED = 0
AND op_rel.RELATIVECENTER in ($$Scope$$)
                AND (
                        op_rel.RELATIVECENTER, op_rel.RELATIVEID) = ( sub.OWNER_CENTER,sub.OWNER_ID
                    ))
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK link
                WHERE
                    link.PRODUCT_CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                AND link.PRODUCT_ID = sub.SUBSCRIPTIONTYPE_ID
                AND $$excludeJunior$$ = 1
                AND link.PRODUCT_GROUP_ID IN (5406,5407,239,242,9802,9801,9803,9804,219) )
    )
    ,
    lp AS
    (
        SELECT
            rank() over (partition BY sp.SUBSCRIPTION_CENTER, sp.SUBSCRIPTION_ID ORDER BY
            sp.FROM_DATE DESC) AS rnk,
            sp.*
        FROM
            SUBSCRIPTION_PRICE sp
        WHERE
            sp.APPLIED = 1
        AND sp.CANCELLED = 0
        AND NOT (
                '4' IN ($$EXCLUDE_STATES$$)
            AND sp.PENDING = 1)
        AND NOT (
                '3' IN ($$EXCLUDE_STATES$$)
            AND sp.APPROVED = 1)
        AND EXISTS
            (
                SELECT
                    1
                FROM
                    subs
                WHERE
                    sp.SUBSCRIPTION_CENTER = subs.SUBSCRIPTION_CENTER
                AND sp.SUBSCRIPTION_ID = subs.SUBSCRIPTION_ID)
    )
    ,
    subs_persons AS
    (
        SELECT
            sub.SUBSCRIPTION_CENTER                                AS subcenter,
            sub.SUBSCRIPTION_ID                                      AS subid,
            centre.ID                                                   clubId,
            centre.SHORTNAME                                            club,
            p.EXTERNAL_ID                                            externalId,
            p.CENTER                                            AS PersonCenter,
            p.ID                                                    AS PersonId,
            comp.Fullname                                        AS CompanyName,
            ROUND(((CURRENT_DATE - p.birthdate)/365),0)                 age,
            ROUND(((CURRENT_DATE - p.FIRST_ACTIVE_START_DATE)/30),1)    tenure,
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
                ELSE 'UNKNOWN'
            END                                                AS PERSONTYPE,
            sub.SUBSCRIPTION_CENTER||'ss'||sub.SUBSCRIPTION_ID    eClubSubscriptionId,
            prod.name                                          AS subscription,
            CASE
                WHEN prod.BLOCKED = 1
                OR  joinProd.BLOCKED = 1
                THEN 'YES'
                ELSE 'NO'
            END        LEGACY,
            prod.PRICE PRODUCTPRICE,
            pp.PRICE_MODIFICATION_AMOUNT,
            sub.SUBSCRIPTION_PRICE                                      CURRENTPRICE,
            TO_CHAR(lp.from_date,'YYYY-MM-DD')                                 AS lastPriceIncrease,
            lp2.PRICE                                                        AS priceBeforeIncrease,
            pex.TXTVALUE                                                    lastPriceUpdateMigrated,
            COUNT(*) over (partition BY sub.SUBSCRIPTION_CENTER,sub.SUBSCRIPTION_ID) AS counter
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
            OR  (
                    ADD_MONTHS(TO_DATE(pex.TXTVALUE, 'YYYY-MM-DD'), 12) <= CAST($$ApplyDate$$ AS DATE)))
    )
    ,
    visits AS
    (
        SELECT
            c.PERSON_CENTER,
            c.PERSON_ID,
            c.id
        FROM
            params2,
            CHECKINS c
        WHERE
            c.CHECKIN_RESULT=1
        AND c.CHECKIN_TIME > params2.cutDate
        AND (
                c.person_id IS NOT NULL)
        
    )
SELECT
  distinct  t1.subcenter,
    t1.subid,
    t1.clubId     AS "ClubID",
    t1.club       AS "Club",
    t1.externalId AS "External ID",
    t1.age        AS "Age",
    t1.tenure     AS "Tenure (months)",
    --COALESCE(c.total_visits,0)   AS "Visits in the Last 6 months",
    
    t1.PERSONTYPE                       AS "PersonType",
    t1.COMPANYNAME                      AS "Company Name",
    t1.eClubSubscriptionId              AS "eClub Subscription ID",
    t1.subscription                     AS "Subscription",
    t1.LEGACY                           AS "Legacy",
    t1.PRODUCTPRICE                     AS "Product Price",
    t1.PRICE_MODIFICATION_AMOUNT        AS "Company Price Modification",
    t1.CURRENTPRICE                     AS "Current Price",
    t1.lastPriceIncrease                AS "Date of Last Price Increase",
    t1.priceBeforeIncrease              AS "Value Before LastPriceIncrease",
    t1.lastPriceUpdateMigrated          AS "Last Price Update Migrated",
    t1.counter                          AS "Count"
FROM
    subs_persons t1
    LEFT JOIN
    visits c
    ON
    t1.PersonCenter = c.PERSON_CENTER
    AND t1.PersonId = c.PERSON_ID
    