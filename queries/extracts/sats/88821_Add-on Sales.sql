WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS
            bigint) AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS bigint
            )+1000*60*60*24-1 AS toDate,
            c.id              AS centerID,
            c.name            AS Centername
        FROM
            centers c
    )
SELECT
    s.owner_center ||'p'|| s.owner_id                           AS memberid,
    sa.CENTER_ID                                                AS Addon_center,
    prod.NAME                                                   AS Addon_name,
    prod.PRICE                                                  AS Addon_price,
    TO_CHAR(longtodate(sa.CREATION_TIME), 'dd-MM-YYYY HH24:MI') AS Addon_creation,
    sa.START_DATE                                               AS Addon_start
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = sa.CENTER_ID
AND prod.GLOBALID = mpr.GLOBALID
JOIN
    params
ON
    params.centerID = sa.CENTER_ID
JOIN
    subscriptions s
ON
    s.center = sa.subscription_center
AND s.id = subscription_id
WHERE
    sa.CREATION_TIME BETWEEN params.fromDate AND params.toDate
    AND sa.center_id IN (:scope)
AND sa.cancelled = 'false'
ORDER BY
    sa.CREATION_TIME,
    sa.center_id,
    prod.name