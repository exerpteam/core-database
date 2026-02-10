-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     allCamp.NAME,
     allCamp.CENTER,
     allCamp.CENTER_NAME,
     longToDate(allCamp.STARTTIME) STARTTIME,
     longToDate(allCamp.ENDTIME) ENDTIME,
     allCamp.RECEIVER_GROUP_TYPE,
     allCamp.CODE_TYPE
 FROM
     (
         SELECT DISTINCT
             prg.NAME,
             ac.CENTER,
             c.SHORTNAME center_name,
                         prg.STARTTIME STARTTIME,
             prg.ENDTIME ENDTIME,
             CASE prg.RGTYPE WHEN 'CAMPAIGN' THEN 'CAMPAIGN' WHEN 'UNLIMITED' THEN 'TARGET GROUP' ELSE 'UNDEFINED' END RECEIVER_GROUP_TYPE,
             CASE prg.PLUGIN_CODES_NAME WHEN 'UNIQUE' THEN 'MULTY USAGE' WHEN 'GENERATED' THEN 'ONE TIME USAGE' WHEN 'NO_CODES' THEN 'NO CODES' ELSE 'UNDEFINED' END CODE_TYPE
         FROM
             PRIVILEGE_RECEIVER_GROUPS prg
         JOIN AREA_CENTERS ac
         ON
             1=1
         JOIN CENTERS c
         ON
             c.ID = ac.CENTER
         WHERE
             (
                 POSITION(',C' || ac.CENTER || ',' IN ',' || prg.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',A' || ac.AREA || ',' IN ',' || prg.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',T1,' IN ',' || prg.AVAILABLE_SCOPES || ',') != 0
             )
             AND prg.BLOCKED = 0
         UNION
         SELECT DISTINCT
             suc.NAME,
             ac.CENTER,
             c.SHORTNAME center_name,
             suc.STARTTIME STARTTIME,
             suc.ENDTIME ENDTIME,
             'STARTUP CAMPAIGN' RECEIVER_GROUP_TYPE,
             CASE suc.PLUGIN_CODES_NAME WHEN 'UNIQUE' THEN 'MULTY USAGE' WHEN 'GENERATED' THEN 'ONE TIME USAGE' WHEN 'NO_CODES' THEN 'NO CODES' ELSE 'UNDEFINED' END CODE_TYPE
         FROM
             STARTUP_CAMPAIGN suc
         JOIN AREA_CENTERS ac
         ON
             1=1
         JOIN CENTERS c
         ON
             c.ID = ac.CENTER
         WHERE
             (
                 POSITION(',C' || ac.CENTER || ',' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',A' || ac.AREA || ',' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
                 OR POSITION(',T1,' IN ',' || suc.AVAILABLE_SCOPES || ',') != 0
             )
             AND suc.STATE IN ('ACTIVE')
     )
     allCamp
 WHERE
     allCamp.center IN (:scope)
     AND
     (
         allCamp.RECEIVER_GROUP_TYPE = 'TARGET GROUP'
         OR :activeAtDate BETWEEN allCamp.STARTTIME AND allCamp.ENDTIME
     )
