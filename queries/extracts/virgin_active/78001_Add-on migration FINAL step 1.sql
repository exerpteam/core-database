-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            --TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')                     AS currentDate,
            DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) +interval '1 month' -
            interval '1 day'                                                             AS cutDate,
            DATE_TRUNC('month', TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')) +interval '1 month' AS
                    sub_start,
            c.id AS centerid
        FROM
            centers c
        WHERE
            c.country = 'GB'
    )
SELECT DISTINCT
    s.owner_center ||'p'|| s.owner_id AS person_key,
    s.center ||'ss'|| s.id            AS sub_key,
    sa.id                             AS addon_key,
    sa.center_id                      AS addon_center,
    sa.end_date                       AS old_addon_enddate,
    par.cutDate                       AS new_addon_enddate,
    sa.binding_end_date               AS addon_binding,
    sa.individual_price_per_unit      AS addon_price,
    par.sub_start                     AS new_sub_start,
    s.billed_until_date               AS sub_billed_until,
    mpr.globalid                      AS addon_globalid,
    pr.globalid                       AS new_sub_globalid,
    pr.name
FROM
    subscriptions s
JOIN
    params par
ON
    par.centerid = s.center
JOIN
    subscription_addon sa
ON
    sa.subscription_center = s.center
AND sa.subscription_id = s.id
JOIN
    masterproductregister mpr
ON
    sa.addon_product_id = mpr.id
LEFT JOIN
    products pr
ON
    pr.name = mpr.cached_productname
AND pr.ptype = 10
AND sa.center_id = pr.center
AND pr.blocked = false
WHERE
    sa.cancelled = false
AND (
        sa.end_date IS NULL
    OR  sa.end_date > par.cutDate)
AND mpr.CACHED_PRODUCTNAME IN ('Active Aces Max 6 12 Month by DD 120 mins' ,
                               'Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Active Aces Max 6 12 Month by DD 90 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 120 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 60 mins' ,
                               'Active Aces Max 6 3 Month Racq by DD 90 mins' ,
                               'Active Performance Aces Max 6 12m by DD 120 mins' ,
                               'Active Performance Aces Max 6 12m by DD 90 mins' ,
                               'Active Performance Aces Max 6 3 Month by DD 120min' ,
                               'Group Max 6 12 Month Swim by DD' ,
                               'Group Max 6 3 Month Swim by DD' ,
                               'Mini Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Mini Active Aces Max 6 12 Month by DD 90 mins' ,
                               'Mini Active Aces Max 6 3 Month Racq by DD 60 mins' ,
                               'NM Active Aces Max 6 12 Month by DD 60 mins' ,
                               'NM Active Aces Max 6 3 Month by DD 60 mins' ,
                               'NM Group Max 6 12 Month Swim by DD' ,
                               'NM Group Max 6 3 Month Swim by DD' ,
                               'NM Mini Active Aces Max 6 12 Month by DD 60 mins' ,
                               'NM Mini Active Aces Max 6 3 Month by DD 60 mins' ,
                               'NM Parent & Baby Max 8 12 Month Swim by DD' ,
                               'NM Parent & Baby Max 8 3 Month Swim by DD' ,
                               'NM Private 121 12 Month Swim by DD' ,
                               'NM Private 121 3 Month Swim by DD' ,
                               'NM Private 221 12 Month Swim by DD' ,
                               'NM Private 221 3 Month Swim by DD' ,
                               'NM Small Group Max 4 12 Month Swim by DD' ,
                               'NM Small Group Max 4 3 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 12 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 12 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 3 Month Swim by DD' ,
                               'NM Squad Max 12 x 1 3 Month Swim by DD' ,
                               'NM Squads Max 8 12 Month by DD 90 mins' ,
                               'NM Squads Max 8 3 Month by DD 90 mins' ,
                               'NM Tiny Active Aces Max 6 12 Month by DD 45 mins' ,
                               'NM Tiny Active Aces Max 6 3 Month by DD 45 mins' ,
                               'Parent & Baby Max 8 12 Month Swim by DD' ,
                               'Parent & Baby Max 8 3 Month Swim by DD' ,
                               'Private 121 12 Month Swim by DD' ,
                               'Private 121 3 Month Swim by DD' ,
                               'Private 221 12 Month Swim by DD' ,
                               'Private 221 3 Month Swim by DD' ,
                               'Small Group Max 4 12 Month Swim by DD' ,
                               'Small Group Max 4 3 Month Swim by DD' ,
                               'Squad Max 12 x 1 12 Month Swim by DD' ,
                               'Squad Max 12 x 1 12 Month Swim by DD' ,
                               'Squad Max 12 x 1 3 Month Swim by DD' ,
                               'Squad Max 12 x 1 3 Month Swim by DD' ,
                               'Squads Max 8 12 Month by DD 90 mins' ,
                               'Squads Max 8 3 Month Racq by DD 90 mins' ,
                               'Tiny Active Aces Max 6 12 Month by DD 45 mins' ,
                               'Tiny Active Aces Max 6 12 Month by DD 60 mins' ,
                               'Tiny Active Aces Max 6 3 Month Racq by DD 45 mins')