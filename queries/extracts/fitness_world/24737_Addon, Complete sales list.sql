-- This is the version from 2026-02-05
-- Ticket 43789
SELECT
    DISTINCT sa.CENTER_ID "Scope",
    prod.NAME "Addon name",
    prod.PRICE "Addon price from product",
    sprod.NAME "sub name",
    sprod.PRICE "sub price from product",
    s.BINDING_PRICE,
    longToDate(sa.CREATION_TIME) "Addon creation date",
    sa.START_DATE "Addon start date",
    sa.END_DATE "Addon end date",
    COALESCE(sa.SALES_CENTER_ID, first_value(inv.CASHREGISTER_CENTER) over(
                                                                       PARTITION BY
                                                                           sa.ID
                                                                       ORDER BY
                                                                           spp.SUBID ASC))
    sales_center,
    s.END_DATE "Main subscription end date",
    p.CENTER || 'p' || p.ID "Member id",
    p.sex,
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
    END "main Person type",
    longtodate(s.start_date) AS "subscription start date"
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    MASTERPRODUCTREGISTER mpr
    ON  mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
    ON  prod.CENTER = sa.SUBSCRIPTION_CENTER
        AND prod.GLOBALID = mpr.GLOBALID
JOIN
    SUBSCRIPTIONS s
    ON  s.CENTER = sa.SUBSCRIPTION_CENTER
        AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    PRODUCTS sprod
    ON  sprod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND sprod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
    ON  p.CENTER = s.OWNER_CENTER
        AND p.ID = s.OWNER_ID
LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
    ON  spp.CENTER = sa.SUBSCRIPTION_CENTER
        AND spp.ID = sa.SUBSCRIPTION_ID
LEFT JOIN
    SPP_INVOICELINES_LINK l
    ON  l.PERIOD_CENTER = spp.CENTER
        AND l.PERIOD_ID = spp.ID
        AND l.PERIOD_SUBID = spp.SUBID
LEFT JOIN
    INVOICELINES invl
    ON  invl.CENTER = l.INVOICELINE_CENTER
        AND invl.ID = l.INVOICELINE_ID
        AND invl.SUBID = l.INVOICELINE_SUBID
LEFT JOIN
    INVOICES inv
    ON  inv.CENTER = invl.CENTER
        AND inv.id = invl.ID
        AND inv.CASHREGISTER_CENTER IS NOT NULL
WHERE
    p.center IN ($$scope$$)
	AND s.START_DATE in (:dato)
	and s.end_date in (:slutdato)