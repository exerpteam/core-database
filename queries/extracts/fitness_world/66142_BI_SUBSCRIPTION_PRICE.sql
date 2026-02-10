-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-1200
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT -- applied mutually exclusive with pending
    CAST ( sp.ID AS VARCHAR(255))                                                                 AS "ID",
    sp.subscription_center||'ss'||sp.subscription_id                                              AS "SUBSCRIPTION_ID",
    sp.type                                                                                       AS "TYPE",
    to_date(TO_CHAR(longtodateC(sp.entry_time,sp.subscription_center),'yyyy-MM-dd'),'yyyy-MM-dd') AS "ENTRY_DATE",
    TO_CHAR(longtodateC(sp.entry_time, sp.subscription_center),'hh24:mi:ss')                      AS "ENTRY_TIME",
    sp.from_date                                                                                  AS "FROM_DATE",
    sp.to_date                                                                                    AS "TO_DATE",
    TO_CHAR(sp.price , 'FM999999999999990D00')   AS "PRICE",
    CASE
        WHEN sp.cancelled = 1
        THEN 'TRUE'
        WHEN sp.cancelled = 0
        THEN 'FALSE'
    END                                                                                                     AS "CANCELLED",
    to_date(TO_CHAR(longtodateC(sp.CANCELLED_ENTRY_TIME,sp.subscription_center),'yyyy-MM-dd'),'yyyy-MM-dd') AS "CANCELLED_DATE",
    TO_CHAR(longtodateC(sp.CANCELLED_ENTRY_TIME, sp.subscription_center),'hh24:mi:ss')                      AS "CANCELLED_TIME",
    sp.SUBSCRIPTION_CENTER                                                                                  AS "CENTER_ID",
    TO_CHAR(COALESCE(sp.CANCELLED_ENTRY_TIME, MAX(sp.ENTRY_TIME) over (partition BY sp.subscription_center,sp.subscription_id ORDER BY sp.ENTRY_TIME DESC)),'FM999G999G999G999G999') AS "ETS"
FROM
    params,
    subscription_price sp
JOIN SUBSCRIPTIONS s
ON sp.subscription_center = s.CENTER
       AND sp.subscription_id = s.ID
WHERE
    (sp.CANCELLED_ENTRY_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
OR 
     sp.ENTRY_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
OR s.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
)
