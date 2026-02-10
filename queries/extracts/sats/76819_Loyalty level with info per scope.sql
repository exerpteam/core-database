-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     results.CENTER ,
     results.ID ,
     results.PERSONKEY,
     results.COUNT_ACTIVE_DAYS,
     results.TOTAL_CHECKINS,
     results.current_group
 FROM
     (
         SELECT
     innersql.CENTER ,
     innersql.ID ,
     innersql.PERSONKEY,
     innersql.COUNT_ACTIVE_DAYS,
     innersql.current_group,
     count(*) AS TOTAL_CHECKINS
         FROM
                 (
                 SELECT DISTINCT
                     p.CENTER ,
                     p.ID ,
                     p.CENTER||'p'||p.ID as PERSONKEY,
                     p.FIRSTNAME,
                     p.LASTNAME,
                     COALESCE(ext.TXTVALUE,'NONE') as current_group,
                     extract(days from (current_timestamp - p.LAST_ACTIVE_START_DATE)) + 1 AS COUNT_ACTIVE_DAYS,
                     pt.center as ptcenter,
                     pt.id as ptid
                 FROM
                     PERSONS p
                 join
                 persons pt
                 ON
     pt.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
 AND pt.TRANSFERS_CURRENT_PRS_ID = p.ID
                 JOIN
                     CENTERS c
                 ON
                     c.ID = p.CENTER
                 LEFT JOIN
                     PERSON_EXT_ATTRS ext
                 ON
                     ext.PERSONCENTER = p.CENTER
                     AND ext.PERSONID = p.ID
                     AND ext.NAME = 'UNBROKENMEMBERSHIPGROUPALL'
                 WHERE
                 p.center in (:scope)
                and p.status in (1,3)
                      ) innersql
            LEFT JOIN
                         checkins ch
                  ON
                         ch.person_center = innersql.ptcenter
                         AND ch.person_id = innersql.ptid
                         and ch.CHECKIN_RESULT < 3
                         and ch.CHECKIN_TIME > DATETOLONGC(TO_CHAR(current_timestamp - cast(COALESCE(innersql.COUNT_ACTIVE_DAYS,0) as integer),'YYYY-MM-DD HH24:MI'), ch.CHECKIN_CENTER)
                         GROUP BY
                         innersql.CENTER,
                         innersql.ID,
                         innersql.PERSONKEY,
                         innersql.FIRSTNAME,
                         innersql.LASTNAME,
                         innersql.CURRENT_GROUP,
                         innersql.COUNT_ACTIVE_DAYS
           ) results
