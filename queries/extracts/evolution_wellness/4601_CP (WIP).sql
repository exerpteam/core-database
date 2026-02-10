-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')-interval '1 day' AS cutDate,
            CAST(datetolong(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')-interval '1 day',
            'YYYY-MM-DD')) AS BIGINT) AS cutLongDate,
            c.id                      AS CenterID
        FROM
            centers c
        WHERE
            c.country = 'TH'
    )
SELECT
    s.owner_center                    AS center,
    s.owner_id                        AS id,
    s.owner_center ||'p'|| s.owner_id AS "PERSONKEY",
    CASE
        WHEN mpr.globalid = 'MEMBERSHIP_LK_S'
        THEN 'SmallLockerID'
        WHEN mpr.globalid = 'MEMBERSHIP_LK_S__1'
        THEN 'SmallLockerID2'
        WHEN mpr.globalid = 'MEMBERSHIP_LK_S__2'
        THEN 'SmallLockerID3'
        WHEN mpr.globalid = 'MEMBERSHIP_LK_M'
        THEN 'LargeLockerID'
        WHEN mpr.globalid = 'MEMBERSHIP_LK_M__1'
        THEN 'LargeLockerID2'
        WHEN mpr.globalid = 'MEMBERSHIP_LK_M__2'
        THEN 'LargeLockerID3'
    END AS ext_attr
FROM
    evolutionwellness.subscriptions s
JOIN
    subscription_addon sa
ON
    sa.subscription_center = s.center
AND sa.subscription_id = s.id
JOIN
    params
ON
    params.centerid = sa.center_id
JOIN
    masterproductregister mpr
ON
    sa.addon_product_id = mpr.id
AND mpr.globalid IN ('MEMBERSHIP_LK_M',
                     'MEMBERSHIP_LK_M__1',
                     'MEMBERSHIP_LK_M__2',
                     'MEMBERSHIP_LK_S',
                     'MEMBERSHIP_LK_S__1',
                     'MEMBERSHIP_LK_S__2')
WHERE
    (
        sa.end_date = params.cutDate
    OR  (
            sa.ending_time >= params.cutLongDate
        AND sa.cancelled = true))
    AND s.center IN (:center)