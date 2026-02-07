SELECT
    comp.CENTER || 'p' || comp.id comp_id,
    comp.FULLNAME company_name,
    ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID agreement_id,
    ca.NAME agreement_name,
    pg.SPONSORSHIP_NAME sponsorship,
    pg.SPONSORSHIP_AMOUNT,
    ps.NAME privilege_set_name,
    DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted') agreement_STATE,
    longToDate(prodp.VALID_FROM) privilege_valid_from,
    longToDate(prodp.VALID_TO) privilege_valid_to,
    prodp.PRICE_MODIFICATION_NAME,
    prodp.PRICE_MODIFICATION_AMOUNT,
    mpr.GLOBALID product_globalid,
    mpr.CACHED_PRODUCTNAME product_name,
    mpr.STATE product_state
FROM
    PERSONS comp
JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = comp.CENTER
    AND ca.ID = comp.id
JOIN PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
JOIN PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
JOIN PRODUCT_PRIVILEGES prodp
ON
    prodp.PRIVILEGE_SET = ps.id
JOIN MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prodp.REF_GLOBALID
    AND mpr.ID = mpr.DEFINITION_KEY
WHERE
    comp.CENTER IN
    (
        SELECT
            c.ID
        FROM
            CENTERS c
        WHERE
            c.COUNTRY = 'DK'
    )
    AND
    (
        prodp.VALID_TO IS NULL
        OR prodp.VALID_TO > dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
    )