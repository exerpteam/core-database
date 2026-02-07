SELECT DISTINCT
    'SC_'||st.ID                                                              AS "ID",
    st.STATE                                                                  AS "STATE",
    'STARTUP_CAMPAIGN'                                                        AS "TYPE",
    st.NAME                                                                   AS "NAME",
    st.period_type                                                            AS "PERIOD_TYPE",
    CASE
        WHEN st.period_unit = 0
        THEN 'WEEK'
        WHEN st.period_unit =1
        THEN 'DAY'
        WHEN st.period_unit = 2
        THEN 'MONTH'
        WHEN st.period_unit = 3
        THEN 'YEAR'
        WHEN st.period_unit =4
        THEN 'HOUR'
        WHEN st.period_unit = 5
        THEN 'MINUTE'
        WHEN st.period_unit = 6
        THEN 'SECOND'
        WHEN st.period_unit IS NULL
        THEN NULL
        ELSE 'UNKNOWN'
    END                                                                       AS "PERIOD_UNIT",
    st.period_value                                                           AS "PERIOD_VALUE",
    CASE WHEN st.privilege_change_binding_type = 'EXTEND_BY_PRIVILEGE_PERIOD' THEN 1
         ELSE 0
    END  AS "PERIOD_EXTEND_BINDING", 
    to_date(TO_CHAR(longtodateC(st.STARTTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd') AS "START_DATE",
    to_date(TO_CHAR(longtodateC(st.ENDTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd')   AS "END_DATE",
    st.PLUGIN_CODES_NAME                                                      AS "CAMPAIGN_CODES_TYPE",
    free_period_type                                                          AS "FREE_PERIOD_TYPE",
    CASE
        WHEN st.free_period_unit = 0
        THEN 'WEEK'
        WHEN st.free_period_unit =1
        THEN 'DAY'
        WHEN st.free_period_unit = 2
        THEN 'MONTH'
        WHEN st.free_period_unit = 3
        THEN 'YEAR'
        WHEN st.free_period_unit =4
        THEN 'HOUR'
        WHEN st.free_period_unit = 5
        THEN 'MINUTE'
        WHEN st.free_period_unit = 6
        THEN 'SECOND'
        WHEN st.free_period_unit IS NULL
        THEN NULL
        ELSE 'UNKNOWN'
    END AS                                                            "FREE_PERIOD_UNIT",
    free_period_value                                                 "FREE_PERIOD_VALUE",
    CAST(CAST (st.free_period_extends_binding AS INT) AS SMALLINT) AS "FREE_PERIOD_EXTEND_BINDING",
    st.privilege_change_binding_type as "PRIVILEGE_CHANGE_BINDING_TYPE",
    longtodateTZ(st.STARTTIME, 'UTC')||'+0000'                               AS "START_DATE_UTC_TIME",
    longtodateTZ(st.ENDTIME, 'UTC')||'+0000'                                 AS "END_DATE_UTC_TIME"
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
    END                                                                       AS "TYPE",
    rg.NAME                                                                   AS "NAME",
    NULL                                                                      AS "PERIOD_TYPE",
    NULL                                                                      AS "PERIOD_UNIT",
    cast(NULL as INT)                                                         AS "PERIOD_VALUE",
    cast(NULL as INT)                                                         AS "PERIOD_EXTEND_BINDING",
    to_date(TO_CHAR(longtodateC(rg.STARTTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd') AS "START_DATE",
    to_date(TO_CHAR(longtodateC(rg.ENDTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd')   AS "END_DATE",
    rg.PLUGIN_CODES_NAME                                                      AS "CAMPAIGN_CODES_TYPE",
    NULL                                                                      AS "FREE_PERIOD_TYPE",
    NULL                                                                      AS "FREE_PERIOD_UNIT",
    CAST(NULL AS INTEGER)                                                     AS "FREE_PERIOD_VALUE",
    CAST(NULL AS SMALLINT)                                                    AS "FREE_PERIOD_EXTEND_BINDING",
    NULL                                                                      AS "PRIVILEGE_CHANGE_BINDING_TYPE",
    longtodateTZ(rg.STARTTIME, 'UTC')||'+0000'                                AS "START_DATE_UTC_TIME",
    longtodateTZ(rg.ENDTIME, 'UTC')||'+0000'                                  AS "END_DATE_UTC_TIME"
FROM
    PRIVILEGE_RECEIVER_GROUPS rg
UNION ALL
SELECT DISTINCT
   'BC_'||bc.ID                                                               AS "ID",
    bc.STATE                                                                  AS "STATE",
    'BUNDLE_CAMPAIGN'                                                         AS "TYPE",
    bc.NAME                                                                   AS "NAME",
    NULL                                                                      AS "PERIOD_TYPE",
    NULL                                                                      AS "PERIOD_UNIT",
    cast(NULL as INT)                                                         AS "PERIOD_VALUE",
    cast(NULL as INT)                                                         AS "PERIOD_EXTEND_BINDING",
    to_date(TO_CHAR(longtodateC(bc.STARTTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd') AS "START_DATE",
    to_date(TO_CHAR(longtodateC(bc.ENDTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd')   AS "END_DATE",
    bc.PLUGIN_CODES_NAME                                                      AS "CAMPAIGN_CODES_TYPE",
    NULL                                                                      AS "FREE_PERIOD_TYPE",
    NULL                                                                      AS "FREE_PERIOD_UNIT",
    CAST(NULL AS INTEGER)                                                     AS "FREE_PERIOD_VALUE",
    CAST(NULL AS SMALLINT)                                                    AS "FREE_PERIOD_EXTEND_BINDING",
    NULL                                                                      AS "PRIVILEGE_CHANGE_BINDING_TYPE",
    longtodateTZ(bc.STARTTIME, 'UTC')||'+0000'                                AS "START_DATE_UTC_TIME",
    longtodateTZ(bc.ENDTIME, 'UTC')||'+0000'                                  AS "END_DATE_UTC_TIME"  
FROM
    BUNDLE_CAMPAIGN bc      
    