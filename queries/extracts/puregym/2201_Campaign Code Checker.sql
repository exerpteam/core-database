-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     CASE
         WHEN prg.BLOCKED = 1 or (current_timestamp not between longToDate(prg.STARTTIME) and longToDate(prg.ENDTIME))
         THEN 'FALSE'
         ELSE 'TRUE'
     END AS "ACTIVE",
     prg.ID,
     prg.RGTYPE,
     prg.SCOPE_TYPE,
     prg.SCOPE_ID,
     prg.BLOCKED,
     prg.NAME,
     prg.PLUGIN_NAME,
     prg.PLUGIN_CONFIG,
     longToDate(prg.STARTTIME) STARTTIME,
     longToDate(prg.ENDTIME) ENDTIME,
     prg.WEB_TEXT,
     prg.AVAILABLE_SCOPES,
     prg.PLUGIN_CODES_NAME,
     prg.PLUGIN_CODES_CONFIG
 FROM
     PRIVILEGE_RECEIVER_GROUPS prg
 WHERE
     prg.ID IN
     (
         SELECT
             cc.CAMPAIGN_ID
         FROM
             CAMPAIGN_CODES cc
         WHERE
             code = :code
             AND prg.STARTTIME BETWEEN :startDate AND :endDate
     )
