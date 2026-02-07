WITH recursive
     START_QUERY AS
     (
         SELECT
             a.id,
             a.name,
             a.parent,
             pa.name AS parentname,
             ac.CENTER,
             c.name AS centername,
             c.zipcode
         FROM
             AREAS a
         LEFT JOIN
             AREA_CENTERS ac
         ON
             a.ID = ac.AREA
         LEFT JOIN
             areas pa
         ON
             a.parent = pa.id
         LEFT JOIN
             centers c
         ON
             ac.center = c.id
     )
     ,
     sub_area
     (
         id,
         name,
         parent,
         parentname,
         center,
         centername,
         zipcode
     ) AS
     (  SELECT
             Sa.id,
             Sa.name,
             Sa.parent,
             Sa.parentname,
             sa.center,
             sa.centername,
             sa.zipcode
         FROM
             START_QUERY sa
         
         UNION ALL
       
             SELECT
             a.id,
             a.name,
             a.parent,
             a.name AS parentname,
             sa.center,
             sa.centername,
             c.zipcode
         FROM
             sub_area sa
         JOIN
             areas a
         ON
             sa.PARENT = a.id
         JOIN
             centers c
         ON
             sa.center = c.id)
     ,
     TEMP_TABLE AS
     (
         SELECT
             *
         FROM
             sub_area
     )
     ,
     AVAILABILITY AS
     (
         SELECT
             sc.ID,
             sc.NAME,
             sc.STARTTIME,
             sc.ENDTIME,
             sc.AVAILABLE_SCOPES,
             sc.PLUGIN_CODES_NAME
         FROM
             STARTUP_CAMPAIGN sc
         WHERE
             sc.STATE = 'ACTIVE'
         AND TRUNC(longtodate(sc.STARTTIME)) <= CURRENT_DATE
         AND longtodate(sc.ENDTIME) >= CURRENT_DATE
         AND sc.PLUGIN_CODES_NAME != 'NO_CODES'
     )
     ,
   START_CAMPAIGNS AS
     (
         SELECT
             avail.ID,
             avail.NAME,
             avail.STARTTIME,
             avail.ENDTIME,
             avail.PLUGIN_CODES_NAME,
             unnest(string_to_array(AVAILABLE_SCOPES, ',')) AVAILABILITY
         FROM
             AVAILABILITY avail 
     ) 
     ,
     STARTUP_CAMPAIGNS AS
     (
         SELECT DISTINCT
             stcam.ID,
             stcam.NAME,
             stcam.STARTTIME,
             stcam.ENDTIME,
             stcam.PLUGIN_CODES_NAME,
             SUBSTR(stcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
             SUBSTR(stcam.AVAILABILITY, 2,LENGTH(stcam.AVAILABILITY)-1) AS SCOPE_ID
         FROM
             START_CAMPAIGNS stcam
     )
     ,
     AVAILABILITY_PRIV AS
     (
         SELECT
             prg.ID,
             prg.NAME,
             prg.STARTTIME,
             prg.ENDTIME,
             prg.AVAILABLE_SCOPES,
             prg.PLUGIN_CODES_NAME
         FROM
             PRIVILEGE_RECEIVER_GROUPS prg
         WHERE
             prg.RGTYPE = 'CAMPAIGN'
         AND prg.BLOCKED = 0
         AND longtodate(prg.ENDTIME) >= CURRENT_DATE
         AND longtodate(prg.STARTTIME) <= CURRENT_DATE
         AND prg.PLUGIN_CODES_NAME != 'NO_CODES'
     )
     ,
     PRIV_CAMPAIGNS AS
     (
         SELECT
             avail_priv.ID,
             avail_priv.NAME,
             avail_priv.STARTTIME,
             avail_priv.ENDTIME,
             avail_priv.PLUGIN_CODES_NAME,
             unnest(string_to_array(AVAILABLE_SCOPES, ',')) AVAILABILITY
         FROM
             AVAILABILITY_PRIV avail_priv 
     )
     ,
     PRIVILEGE_CAMPAIGNS AS
     (
         SELECT DISTINCT
             prcam.ID,
             prcam.NAME,
             prcam.STARTTIME,
             prcam.ENDTIME,
             prcam.PLUGIN_CODES_NAME,
             SUBSTR(prcam.AVAILABILITY,1,1)                             AS SCOPE_TYPE,
             SUBSTR(prcam.AVAILABILITY, 2,LENGTH(prcam.AVAILABILITY)-1) AS SCOPE_ID
         FROM
             PRIV_CAMPAIGNS prcam
     )
 SELECT DISTINCT
     *
 FROM
     (
         SELECT
             "Campaign Id",
             "Campaign Name",
             "Active From",
             "Active To",
             pg.PRIVILEGE_SET AS "Privilege Set Id",
             ps.NAME AS "Privilege Set Name",
             CASE
                 WHEN "Code Type" = 'GENERATED'
                 THEN 'SINGLE USE'
                 WHEN "Code Type" = 'UNIQUE'
                 THEN 'MULTI USE'
                 ELSE 'UNKNOWN'
             END AS "Code type"
         FROM
             (
                 SELECT
                     sc_area.ID                    AS "Campaign Id",
                     sc_area.NAME                  AS "Campaign Name",
                     longtodate(sc_area.STARTTIME) AS "Active From",
                     longtodate(sc_area.ENDTIME)   AS "Active To",
                     sc_area.PLUGIN_CODES_NAME     AS "Code Type"
                 FROM
                     centers c
                 JOIN
                     TEMP_TABLE tt
                 ON
                     tt.CENTER = c.ID
                 AND tt.ID IS NOT NULL
                 AND tt.CENTER IS NOT NULL
                 LEFT JOIN
                     STARTUP_CAMPAIGNS sc_area
                 ON
                     sc_area.SCOPE_ID = tt.ID::varchar
                 AND sc_area.SCOPE_TYPE IN ('A',
                                            'T')
                 AND tt.ID IS NOT NULL
                 WHERE
                     c.id IN (:scope)
                 UNION ALL
                 SELECT
                     sc_center.ID                    AS "Campaign Id",
                     sc_center.NAME                  AS "Campaign Name",
                     longtodate(sc_center.STARTTIME) AS "Active From",
                     longtodate(sc_center.ENDTIME)   AS "Active To",
                     sc_center.PLUGIN_CODES_NAME     AS "Code Type"
                 FROM
                     centers c
                 LEFT JOIN
                     STARTUP_CAMPAIGNS sc_center
                 ON
                     sc_center.SCOPE_ID = c.ID::varchar
                 AND sc_center.SCOPE_TYPE = 'C'
                 WHERE
                     c.id IN (:scope) )t
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.GRANTER_ID = "Campaign Id"
         AND pg.GRANTER_SERVICE = 'StartupCampaign'
         JOIN
             PRIVILEGE_SETS ps
         ON
             ps.ID = pg.PRIVILEGE_SET
         UNION ALL
         SELECT
             "Campaign Id",
             "Campaign Name",
             "Active From",
             "Active To",
             pg.PRIVILEGE_SET AS "Privilege Set Id",
             ps.NAME AS "Privilege Set Name",
             CASE
                 WHEN "Code Type" = 'GENERATED'
                 THEN 'SINGLE USE'
                 WHEN "Code Type" = 'UNIQUE'
                 THEN 'MULTI USE'
                 ELSE 'UNKNOWN'
             END AS "Code type"
         FROM
             (
                 SELECT
                     prg_area.ID                    AS "Campaign Id",
                     prg_area.NAME                  AS "Campaign Name",
                     longtodate(prg_area.STARTTIME) AS "Active From",
                     longtodate(prg_area.ENDTIME)   AS "Active To",
                     prg_area.PLUGIN_CODES_NAME     AS "Code Type"
                 FROM
                     centers c
                 JOIN
                     TEMP_TABLE tt
                 ON
                     tt.CENTER = c.ID
                 AND tt.ID IS NOT NULL
                 AND tt.CENTER IS NOT NULL
                 LEFT JOIN
                     PRIVILEGE_CAMPAIGNS prg_area
                 ON
                     prg_area.SCOPE_ID = tt.ID::varchar
                 AND prg_area.SCOPE_TYPE IN ('A',
                                             'T')
                 AND tt.ID IS NOT NULL
                 WHERE
                     c.id IN (:scope)
                 UNION ALL
                 SELECT
                     prg_center.ID                    AS "Campaign Id",
                     prg_center.NAME                  AS "Campaign Name",
                     longtodate(prg_center.STARTTIME) AS "Active From",
                     longtodate(prg_center.ENDTIME)   AS "Active To",
                     prg_center.PLUGIN_CODES_NAME     AS "Code Type"
                 FROM
                     centers c
                 LEFT JOIN
                     PRIVILEGE_CAMPAIGNS prg_center
                 ON
                     prg_center.SCOPE_ID = c.ID::varchar
                 AND prg_center.SCOPE_TYPE = 'C'
                 WHERE
                     c.id IN (:scope) )t2
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             pg.GRANTER_ID = "Campaign Id"
         AND pg.GRANTER_SERVICE = 'ReceiverGroup'
         JOIN
             PRIVILEGE_SETS ps
         ON
             ps.ID = pg.PRIVILEGE_SET )t3
 WHERE
     "Campaign Name" IS NOT NULL
 ORDER BY
 "Campaign Name",
 "Privilege Set Id"
