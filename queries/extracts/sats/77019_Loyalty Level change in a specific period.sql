SELECT
    results.CENTER ,
    results.ID ,
    results.PERSONKEY,
    case
    when results.daysplus is not null
    then results.COUNT_ACTIVE_DAYS+results.daysplus 
    else results.COUNT_ACTIVE_DAYS
end as COUNT_ACTIVE_DAYS,
    case
    when results.checkinsplus is not null
    then results.TOTAL_CHECKINS+results.checkinsplus
    else results.TOTAL_CHECKINS
    end  as TOTAL_CHECKINS,
    results.current_group,
    results.level_change_date,
    results.LAST_ACTIVE_START_DATE
FROM
    (
        SELECT
            innersql.CENTER ,
            innersql.ID ,
            innersql.PERSONKEY,
            innersql.COUNT_ACTIVE_DAYS,
            innersql.current_group,
            innersql.level_change_date,
            innersql.LAST_ACTIVE_START_DATE,
            rank() over (PARTITION BY innersql.PERSONKEY ORDER BY innersql.level_change_date ) AS rnk ,
            COUNT(*)                                                                           AS TOTAL_CHECKINS,
 innersql.checkinsplus,
 innersql.daysplus
        FROM
            (
                SELECT DISTINCT
                    p.CENTER ,
                    p.ID ,
                    p.CENTER||'p'||p.ID AS PERSONKEY,
                    p.FIRSTNAME,
                    p.LASTNAME,
                    NVL(ext.TXTVALUE,'NONE')                          AS current_group,
                    TRUNC(SYSDATE - p.LAST_ACTIVE_START_DATE) + 1     AS COUNT_ACTIVE_DAYS,
                    TO_CHAR(longtodate(pcl.ENTRY_TIME), 'dd-mm-yyyy') AS level_change_date,
                    TO_CHAR(p.LAST_ACTIVE_START_DATE,'dd-mm-yyyy')    AS LAST_ACTIVE_START_DATE,
                    pt.center                                         AS ptcenter,
                    pt.id                                             AS ptid,
 ext2.txtvalue as checkinsplus,
                    ext3.txtvalue as daysplus
                FROM
                    PERSONS p
                JOIN
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
              LEFT JOIN
                    PERSON_EXT_ATTRS ext2
                ON
                    ext2.PERSONCENTER = p.CENTER
                    AND ext2.PERSONID = p.ID
                    AND ext2.NAME = 'LOYALTYCHECKINPLUS'
                    LEFT JOIN
                    PERSON_EXT_ATTRS ext3
                ON
                    ext3.PERSONCENTER = p.CENTER
                    AND ext3.PERSONID = p.ID
                    AND ext3.NAME = 'EXTRADAYSLOYALTY'
                LEFT JOIN
                    PERSON_CHANGE_LOGS pcl
                ON
                    p.center = pcl.person_center
                    AND p.id = pcl.person_id
                    AND ext.name = pcl.CHANGE_ATTRIBUTE
                    AND pcl.NEW_VALUE = ext.txtvalue
                WHERE
               longtodate(pcl.ENTRY_TIME) between (:levelchangedatefrom) and (:levelchangedateto)
and p.center in (:scope) ) innersql
        LEFT JOIN
            checkins ch
        ON
            ch.person_center = innersql.ptcenter
            AND ch.person_id = innersql.ptid
            AND ch.CHECKIN_RESULT < 3
            AND ch.CHECKIN_TIME > DATETOLONGC(TO_CHAR(SYSDATE - NVL(innersql.COUNT_ACTIVE_DAYS,0),'YYYY-MM-DD HH24:MI'), ch.CHECKIN_CENTER)
        GROUP BY
            innersql.CENTER,
            innersql.ID,
            innersql.PERSONKEY,
            innersql.FIRSTNAME,
            innersql.LASTNAME,
            innersql.CURRENT_GROUP,
            innersql.COUNT_ACTIVE_DAYS,
            innersql.level_change_date,
            innersql.LAST_ACTIVE_START_DATE,
            innersql.checkinsplus,
 innersql.daysplus ) results
WHERE
    results.rnk = 1