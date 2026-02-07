-- This is the version from 2026-02-05
-- * TYPE: 
 INCLUDE: This will give you the members that are on an agreements that has ANY sponsor variant defined in SPONSORSHIP below
EXCLUDE: This will give you the members that are on an agreements that DON'T HAVE ANY sponsor variant defined in SPONSORSHIP below
* SPONSORSHIP
NONE
PERCENTAGE
FULL

SELECT DISTINCT
    p.CENTER || 'p' || p.ID pid,
    p.FULLNAME,
    c.LASTNAME                       cmpany_name,
    ca.NAME                          company_agreement,
    NVL(sp.PRICE,s.BINDING_PRICE) price
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
left JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.ID
    AND sp.CANCELLED = 0
    AND sp.FROM_DATE < exerpsysdate()
    AND (
        sp.TO_DATE IS NULL
        OR sp.TO_DATE > exerpsysdate())
    --    AND sp.APPLIED = 1
    AND ((
            s.BINDING_END_DATE < exerpsysdate()
            AND s.BINDING_END_DATE IS NOT NULL
            AND sp.BINDING = 1)
        OR sp.BINDING = 0)
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    RELATIVES rel
ON
    rel.CENTER = s.OWNER_CENTER
    AND rel.ID = s.OWNER_ID
    AND rel.RTYPE = 3
    AND rel.STATUS = 1
JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.ID = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
JOIN
    PERSONS c
ON
    c.CENTER = ca.CENTER
    AND c.ID = ca.ID
WHERE
    prod.GLOBALID = 'EFT_CORPORATE_NORMAL'
    AND s.STATE IN (2,4,8)
    AND s.center IN ($$scope$$)
    --FULL
    --NONE
    --PERCENTAGE
    --and ($$type$$ = 'EXCLUDE'
    AND ( (
            $$type$$ = 'EXCLUDE'
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRIVILEGE_GRANTS pg
                WHERE
                    pg.GRANTER_CENTER = ca.CENTER
                    AND pg.GRANTER_ID = ca.ID
                    AND pg.GRANTER_SUBID = ca.SUBID
                    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                    AND pg.SPONSORSHIP_NAME in ($$SPONSORSHIP$$)
                    AND (
                        pg.VALID_FROM <= dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                        AND (
                            pg.VALID_TO IS NULL
                            OR pg.VALID_TO > dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))) ))
        OR (
            $$type$$ = 'INCLUDE'
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    PRIVILEGE_GRANTS pg
                WHERE
                    pg.GRANTER_CENTER = ca.CENTER
                    AND pg.GRANTER_ID = ca.ID
                    AND pg.GRANTER_SUBID = ca.SUBID
                    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
                    AND pg.SPONSORSHIP_NAME in ($$SPONSORSHIP$$)
                    AND (
                        pg.VALID_FROM <= dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
                        AND (
                            pg.VALID_TO IS NULL
                            OR pg.VALID_TO > dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')))) ) ) )