SELECT
    e.IDENTITY  AS "CARDNO",
--    mpr.CACHED_PRODUCTNAME AS "Add On name",
--    pr.NAME  AS "subscription",
--    sa.START_DATE,
--    s.START_DATE,
    1           AS CARDSTATUS,
    p.FIRSTNAME AS "Name",
    p.LASTNAME  AS "LastName"
FROM
    persons p
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.center
AND s.OWNER_ID = p.id
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
AND sa.SUBSCRIPTION_ID = s.id
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    ENTITYIDENTIFIERS e
ON
    p.CENTER = e.REF_CENTER
AND p.ID = e.REF_ID
AND e.ENTITYSTATUS = 1
AND e.IDMETHOD = 1
LEFT JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
    s.CENTER IN (189,200,184)
AND ( 
(
            s.START_DATE <= TRUNC(exerpsysdate())
        AND (
                s.END_DATE > TRUNC(exerpsysdate())
            OR  s.END_DATE IS NULL)
        AND s.SUB_STATE !=8
        AND pr.NAME = '1 månad kontant bad Eskilstuna' )
OR (
            s.START_DATE <= TRUNC(exerpsysdate())
        AND (
                s.END_DATE > TRUNC(exerpsysdate())
            OR  s.END_DATE IS NULL)
        AND s.SUB_STATE !=8
		AND pr.NAME = 'Personalmedlemskap' )
OR  (
            sa.START_DATE <= TRUNC(exerpsysdate())
        AND (
                sa.END_DATE > TRUNC(exerpsysdate())
            OR  sa.END_DATE IS NULL)
        AND sa.CANCELLED = 0
        AND mpr.CACHED_PRODUCTNAME = 'Addon Eskilstuna bad' )
OR	(
            sa.START_DATE <= TRUNC(exerpsysdate())
        AND (
                sa.END_DATE > TRUNC(exerpsysdate())
            OR  sa.END_DATE IS NULL)
        AND sa.CANCELLED = 0
        AND mpr.CACHED_PRODUCTNAME = 'Add-on Eskilstuna bad' )	
        )

ORDER BY
    sa.START_DATE,
    s.START_DATE
