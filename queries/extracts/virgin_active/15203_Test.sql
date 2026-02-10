-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.name                           AS "Club",
    s.OWNER_CENTER||'p'|| s.OWNER_ID AS "ID Member",
    pr.name                          AS "Subs",
    'Startup Campaign'               AS "Type",
    cc.code                          AS "Campaign Code",
    CASE
        WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
        THEN TO_CHAR(s.BINDING_END_DATE+1,'yyyy-MM-dd')
        WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
            AND s.STUP_FREE_PERIOD_UNIT = 1
        THEN TO_CHAR(s.BINDING_END_DATE +1 - s.STUP_FREE_PERIOD_VALUE,'yyyy-MM-dd')
        WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
            AND s.STUP_FREE_PERIOD_UNIT = 2
        THEN TO_CHAR(add_months(s.BINDING_END_DATE+1,-1*s.STUP_FREE_PERIOD_VALUE ),'yyyy-MM-dd')
    END AS "From Date",
    CASE
        WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
            AND s.STUP_FREE_PERIOD_UNIT = 1
        THEN TO_CHAR(s.BINDING_END_DATE + s.STUP_FREE_PERIOD_VALUE,'yyyy-MM-dd')
        WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
            AND s.STUP_FREE_PERIOD_UNIT = 2
        THEN TO_CHAR(add_months(s.BINDING_END_DATE,s.STUP_FREE_PERIOD_VALUE ),'yyyy-MM-dd')
        WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
        THEN TO_CHAR(s.BINDING_END_DATE,'yyyy-MM-dd')
    END AS "To Date"
FROM
    VA.SUBSCRIPTIONS s
JOIN
    VA.STARTUP_CAMPAIGN sc
ON
    sc.id = s.STARTUP_FREE_PERIOD_ID
LEFT JOIN
    VA.CAMPAIGN_CODES cc
ON
    cc.id = s.CAMPAIGN_CODE_ID
JOIN
    PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    centers c
ON
    c.id = s.center
WHERE
    s.STUP_FREE_PERIOD_UNIT IS NOT NULL
    AND s.BINDING_END_DATE >= add_months(SYSDATE,1) -- for free period days from campaign that are not used yet


    AND s.center = 102
    AND s.id = 27126