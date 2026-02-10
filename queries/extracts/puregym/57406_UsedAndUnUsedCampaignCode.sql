-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    CC_COUNT AS
    (
        SELECT
            /*+ materialize */
            cc.campaign_id,
            cc.used,
            cc.campaign_type,
            COUNT(*) AS total
        FROM
            campaign_codes cc
        GROUP BY
            cc.campaign_id,
            cc.used,
            cc.campaign_type
    )
SELECT
    'Prvilege Campaigns' AS CAMP_TYPE,
    prg.id,
    prg.name,
    CASE
        WHEN prg.blocked = 1
        THEN 'YES'
        ELSE 'NO'
    END AS Blocked,
    CASE
        WHEN prg.endtime < datetolongC(TO_CHAR( SYSDATE, 'YYYY-MM-dd HH24:MI' ),100)
        THEN 'EXPIRED'
        ELSE 'ACTIVE'
    END               AS Status,
    unusedcount.total AS UnUsed,
    usedcount.total   AS Used
FROM
    PRIVILEGE_RECEIVER_GROUPS prg
LEFT JOIN
    CC_COUNT usedcount
ON
    usedcount.campaign_id = prg.id
    AND usedcount.used = 1
    AND usedcount.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
LEFT JOIN
    CC_COUNT unusedcount
ON
    unusedcount.campaign_id = prg.id
    AND unusedcount.used = 0
    AND unusedcount.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
UNION
SELECT
    'Startup Campaigns' AS CAMP_TYPE,
    sc.id,
    sc.name,
    CASE
        WHEN sc.state = 'BLOCKED'
        THEN 'YES'
        ELSE 'NO'
    END AS Blocked,
    CASE
        WHEN sc.state = 'BLOCKED'
        THEN 'BLOCKED'
        WHEN sc.endtime < datetolongC(TO_CHAR( SYSDATE, 'YYYY-MM-dd HH24:MI' ),100)
        THEN 'EXPIRED'
        ELSE 'ACTIVE'
    END               AS Status,
    unusedcount.total AS UnUsed,
    usedcount.total   AS Used
FROM
    startup_campaign sc
LEFT JOIN
    CC_COUNT usedcount
ON
    usedcount.campaign_id = sc.id
    AND usedcount.used = 1
    AND usedcount.CAMPAIGN_TYPE = 'STARTUP'
LEFT JOIN
    CC_COUNT unusedcount
ON
    unusedcount.campaign_id =sc.id
    AND unusedcount.used = 0
    AND unusedcount.CAMPAIGN_TYPE = 'STARTUP'