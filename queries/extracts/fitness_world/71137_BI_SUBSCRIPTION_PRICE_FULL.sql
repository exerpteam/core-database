-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT -- applied mutually exclusive with pending
    CAST ( sp.ID AS VARCHAR(255))                                                                 AS "ID",
    sp.subscription_center||'ss'||sp.subscription_id                                              AS "SUBSCRIPTION_ID",
    sp.type                                                                                       AS "TYPE",
    to_date(TO_CHAR(longtodateC(sp.entry_time,sp.subscription_center),'yyyy-MM-dd'),'yyyy-MM-dd') AS "ENTRY_DATE",
    TO_CHAR(longtodateC(sp.entry_time, sp.subscription_center),'hh24:mi:ss')                      AS "ENTRY_TIME",
    sp.from_date                                                                                  AS "FROM_DATE",
    sp.to_date                                                                                    AS "TO_DATE",
    sp.price                                                                                      AS "PRICE",
    CASE
        WHEN sp.cancelled = 1
        THEN 'TRUE'
        WHEN sp.cancelled = 0
        THEN 'FALSE'
    END                                                                                                     AS "CANCELLED",
    to_date(TO_CHAR(longtodateC(sp.CANCELLED_ENTRY_TIME,sp.subscription_center),'yyyy-MM-dd'),'yyyy-MM-dd') AS "CANCELLED_DATE",
    TO_CHAR(longtodateC(sp.CANCELLED_ENTRY_TIME, sp.subscription_center),'hh24:mi:ss')                      AS "CANCELLED_TIME",
    sp.SUBSCRIPTION_CENTER                                                                                  AS "CENTER_ID",
	COALESCE(sp.CANCELLED_ENTRY_TIME, MAX(sp.ENTRY_TIME) over (partition BY sp.subscription_center,sp.subscription_id ORDER BY sp.ENTRY_TIME DESC)) AS "ETS"
,sp.entry_time
,sp.CANCELLED_ENTRY_TIME 
FROM
   
    subscription_price sp
WHERE sp.subscription_center||'ss'||sp.subscription_id = '114ss209807'
