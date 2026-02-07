-- This is the version from 2026-02-05
--  
WITH
    package_type AS
    ( SELECT
        pr.center
        ,pr.id
        ,CASE
            WHEN bool_or(ppg.product_group_id IN (801)) -- Vantage
            THEN 'VANTAGE'
            WHEN bool_or(ppg.product_group_id IN (243,211)) --Platinum, Non Countable Platinum
            THEN 'PLATINUM'
            WHEN bool_or(ppg.product_group_id IN (201
                                                  , 207
                                                  , 241)) -- Diamond, Non Countable Diamond,
                -- Diamond Plus
            THEN 'PLATINUM_INFINITY'
            WHEN bool_or(ppg.product_group_id IN (3)) -- Team Members
            THEN 'TEAM'
            WHEN bool_or(ppg.product_group_id IN (601)) --Life
            THEN 'LIFE'
            WHEN bool_or(ppg.product_group_id IN (602)) -- Founder
            THEN 'FOUNDER'
            WHEN bool_or(ppg.product_group_id IN (403)) -- Standard
            THEN 'STANDARD'
            ELSE 'STANDARD'
        END AS package_type
    FROM
        products pr
    JOIN
        product_and_product_group_link ppg
    ON
        pr.center = ppg.product_center
    AND pr.id = ppg.product_id
    GROUP BY
        pr.center
        ,pr.id
    )
SELECT
    c.id                        AS "ClubID"
    ,c.name                     AS "Club Name"
    , pr.center||'prod'||pr.id  AS "Product ID"
    , pr.external_id            AS "Package Code"
    ,pr.globalid                AS "Package ID"
    ,pr.name                    AS "Package Description"
    , package_type.package_type AS "Package Type"
FROM
    products pr
JOIN
    package_type
ON
    package_type.center = pr.center
AND package_type.id = pr.id
JOIN
    centers c
ON
    c.id = pr.center
WHERE
    pr.ptype = 10
AND pr.center IN($$scope$$)