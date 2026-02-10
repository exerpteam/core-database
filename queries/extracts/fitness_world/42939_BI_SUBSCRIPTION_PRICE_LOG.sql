-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    CAST ( ID AS VARCHAR(255))                                               AS "SUBSCRIPTION_PRICE_ID",
    FROM_DATE                                        AS "FROM_DATE",
	sp.SUBSCRIPTION_CENTER||'ss'||sp.SUBSCRIPTION_ID AS "SUBSCRIPTION_ID",
    sp.PRICE                                         AS "PRICE",
    sp.TYPE                                          AS "TYPE",
    sp.ENTRY_TIME                                    AS "ETS"
FROM
    SUBSCRIPTION_PRICE sp
