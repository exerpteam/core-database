-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    'SC_'||st.ID                                        AS "ID",
    st.STATE                                            AS "STATE",
    'STARTUP_CAMPAIGN'                                  AS "TYPE",
    st.NAME                                             AS "NAME",
    TO_CHAR(longtodateC(st.STARTTIME,100),'yyyy-MM-dd') AS "START_DATE",
    TO_CHAR(longtodateC(st.ENDTIME,100),'yyyy-MM-dd')   AS "END_DATE",
     st.PLUGIN_CODES_NAME as "CAMPAIGN_CODES_TYPE"
FROM
    STARTUP_CAMPAIGN st
UNION ALL
SELECT DISTINCT
    CASE
        WHEN rg.RGTYPE ='CAMPAIGN'
        THEN 'C_'||rg.ID
        WHEN rg.RGTYPE ='UNLIMITED'
        THEN 'TG_'||rg.ID
    END AS "ID",
    CASE
        WHEN rg.BLOCKED= 1
        THEN 'BLOCKED'
        ELSE 'ACTIVE'
    END AS "STATE",
    CASE
        WHEN rg.RGTYPE ='CAMPAIGN'
        THEN 'CAMPAIGN'
        WHEN rg.RGTYPE ='UNLIMITED'
        THEN 'TARGET_GROUP'
    END                                                 AS "TYPE",
    rg.NAME                                             AS "NAME",
    TO_CHAR(longtodateC(rg.STARTTIME,100),'yyyy-MM-dd') AS "START_DATE",
    TO_CHAR(longtodateC(rg.ENDTIME,100),'yyyy-MM-dd')   AS "END_DATE",
    rg.PLUGIN_CODES_NAME as "CAMPAIGN_CODES_TYPE"
FROM
    PRIVILEGE_RECEIVER_GROUPS rg
