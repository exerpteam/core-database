SELECT 
        CASE
                WHEN prg.BLOCKED IS NOT NULL THEN
                        CASE
                                WHEN prg.BLOCKED = 1 or (sysdate not between longToDate(prg.STARTTIME) and longToDate(prg.ENDTIME)) THEN 
                                        'FALSE'
                                ELSE 
                                        'TRUE'
                        END 
                ELSE
                        CASE
                                WHEN sysdate not between longToDate(sc.STARTTIME) and longToDate(sc.ENDTIME) THEN
                                        'FALSE'
                                ELSE
                                        'TRUE'
                        END
        END AS "ACTIVE",
        CASE
                WHEN prg.ID IS NOT NULL THEN
                        prg.ID
                ELSE
                        sc.ID
        END AS "ID",
        CASE
                WHEN prg.RGTYPE IS NOT NULL THEN
                        prg.RGTYPE
                WHEN sc.ID IS NOT NULL THEN 
                        'STARTUP CAMPAIGN'
                ELSE
                        NULL
        END AS "TPYE",
        CASE
                WHEN prg.SCOPE_TYPE IS NOT NULL THEN
                        prg.SCOPE_TYPE
                ELSE
                        sc.SCOPE_TYPE
        END AS "SCOPE_TYPE",
        CASE
                WHEN prg.SCOPE_ID IS NOT NULL THEN 
                        prg.SCOPE_ID
                ELSE
                        sc.SCOPE_ID
        END AS "SCOPE_ID",
        CASE
                WHEN prg.BLOCKED IS NOT NULL THEN
                        prg.BLOCKED
                ELSE
                        NULL
        END AS "BLOCKED",
        CASE
                WHEN prg.NAME IS NOT NULL THEN 
                        prg.NAME
                ELSE
                        sc.NAME
        END AS "NAME",
        CASE
                WHEN prg.PLUGIN_NAME IS NOT NULL THEN
                        prg.PLUGIN_NAME
                ELSE
                        sc.PLUGIN_NAME
        END AS "PLUGIN_NAME",
        CASE 
                WHEN prg.PLUGIN_CONFIG IS NOT NULL THEN
                        prg.PLUGIN_CONFIG
                ELSE
                        sc.PLUGIN_CONFIG
        END AS "PLUGIN_CONFIG",
        CASE
                WHEN prg.STARTTIME IS NOT NULL THEN
                        longToDate(prg.STARTTIME)
                ELSE
                        longToDate(sc.STARTTIME)
        END AS "STARTTIME",
        CASE
                WHEN prg.ENDTIME IS NOT NULL THEN
                       longToDate(prg.ENDTIME)
                ELSE
                       longToDate(sc.ENDTIME)
        END AS "ENDTIME",
        CASE
                WHEN prg.WEB_TEXT IS NOT NULL THEN
                        prg.WEB_TEXT
                ELSE
                        sc.WEB_TEXT
        END AS "WEB_TEXT",
        CASE
                WHEN prg.AVAILABLE_SCOPES IS NOT NULL THEN
                        prg.AVAILABLE_SCOPES
                ELSE
                        sc.AVAILABLE_SCOPES
        END AS "AVAILABLE_SCOPES",
        CASE
                WHEN prg.PLUGIN_CODES_NAME IS NOT NULL THEN
                        prg.PLUGIN_CODES_NAME
                ELSE
                        sc.PLUGIN_CODES_NAME
        END AS "PLUGIN_CODES_NAME",
        CASE
                WHEN prg.PLUGIN_CODES_CONFIG IS NOT NULL THEN
                        prg.PLUGIN_CODES_CONFIG
                ELSE
                        sc.PLUGIN_CODES_CONFIG
        END AS "PLUGIN_CODES_CONFIG"  
                      
FROM
        CAMPAIGN_CODES cc
LEFT JOIN 
        PRIVILEGE_RECEIVER_GROUPS prg ON cc.CAMPAIGN_ID = prg.ID AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP' AND prg.STARTTIME BETWEEN :startDate AND :endDate 
LEFT JOIN
        STARTUP_CAMPAIGN sc ON cc.CAMPAIGN_ID = sc.ID AND cc.CAMPAIGN_TYPE = 'STARTUP' AND sc.STARTTIME BETWEEN :startDate AND :endDate
WHERE
        cc.CODE = :code
AND
        (
                prg.ID IS NOT NULL 
                OR 
                sc.ID IS NOT NULL
        )
        