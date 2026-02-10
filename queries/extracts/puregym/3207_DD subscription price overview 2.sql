-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    c.name       AS "Club name",
 CASE
        WHEN c.STARTUPDATE>SYSDATE
        THEN 'Pre-Join'
        ELSE 'Open'
    END                                  AS "Status",
    a.name       AS "Regional manager",
    prod.name    AS "Subscription name",
    spnor.PRICE  AS "Current live monthly fee (GBP)" ,
    spin.PRICE   AS "Current live initial fee (GBP)" ,
    ss.PRICE_NEW AS "Current live joining fee (GBP)",
    a2.name      AS "Price Tier"
FROM
    PUREGYM.SUBSCRIPTION_SALES ss
JOIN
    PUREGYM.PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
    AND prod.ID = ss.SUBSCRIPTION_TYPE_ID
and prid.GLOBALID NOT IN ('GYMFLEX_12M_EFT',
                                    'GYMFLEX_9M_EFT')
JOIN
    PUREGYM.centers c
ON
    c.id = prod.center
JOIN
    PUREGYM.AREA_CENTERS AC
ON
    C.ID = AC.CENTER
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE spin
ON
    spin.SUBSCRIPTION_CENTER = ss.SUBSCRIPTION_CENTER
    AND spin.SUBSCRIPTION_ID = ss.SUBSCRIPTION_ID
    AND spin.TYPE = 'INITIAL'
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE spnor
ON
    spnor.SUBSCRIPTION_CENTER = ss.SUBSCRIPTION_CENTER
    AND spnor.SUBSCRIPTION_ID = ss.SUBSCRIPTION_ID
    AND spnor.TYPE = 'NORMAL'
JOIN
    PUREGYM.AREAS A
ON
    A.ID = AC.AREA
    -- Area Managers/UK
    AND A.PARENT = 61
JOIN
    AREA_CENTERS AC2
ON
    C.ID = AC2.CENTER
JOIN
    AREAS A2
ON
    A2.ID = AC2.AREA
    -- Price Tier
    AND A2.PARENT = 31
WHERE
    prod.CENTER IN (:scope)
    AND ss.SALES_DATE BETWEEN :fromDate AND :toDate
ORDER BY
    "Club name",
    "Regional manager",
    "Current live monthly fee (GBP)"