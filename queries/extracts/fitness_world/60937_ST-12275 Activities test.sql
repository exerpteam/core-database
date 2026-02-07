-- This is the version from 2026-02-05
--  
WITH
    subareas AS
    (
        SELECT
            /*+ materialize */
            CONNECT_BY_ROOT a.ID AS ID,
            a.ID                 AS SUB_AREA
        FROM
            areas a
        WHERE
            a.ROOT_AREA = 1 CONNECT BY PRIOR id = parent
    )
    ,
    area_center AS
    (
        SELECT
            /*+ materialize */
            DISTINCT scope_type||scope_id s_id,
            scope_type,
            scope_id,
            center_id
        FROM
            (
                SELECT
                    'A'       AS scope_type,
                    id        AS scope_id,
                    ac.CENTER AS center_id
                FROM
                    subareas
                LEFT JOIN
                    area_centers ac
                ON
                    ac.area = subareas.SUB_AREA
                UNION ALL
                SELECT
                    'G'  AS scope_type,
                    0    AS scope_id,
                    c.id AS center_id
                FROM
                    centers c
                UNION ALL
                SELECT
                    'T'  AS scope_type,
                    1    AS scope_id,
                    c.id AS center_id
                FROM
                    centers c
                UNION ALL
                SELECT
                    'C'  AS scope_type,
                    c.id AS scope_id,
                    c.id AS center_id
                FROM
                    centers c)
    )
SELECT
    a.id,
    a.NAME AS "Activity Name",
    c.id,
    c.shortname as "Center name",
    DECODE(MAX(
        CASE
            WHEN ac.center_id IS NOT NULL
            THEN 1
            ELSE 0
        END), 0, 'No',1, 'Yes') AS "Activity scope availability",
    DECODE(a.ACTIVITY_TYPE,1,'General',2,'Class',3,'Resource booking',4,'Staff booking',5,'Meeting'
    ,6,'Staff availability',7,'Resource availability',8,'ChildCare',9,'Course program',10,'Task',
    'Undefined')       AS "Activity type",
    ag.NAME            AS "Activity group",
    brg.NAME           AS "Resource group",
    a.MAX_PARTICIPANTS AS "Max participants",
    a.MAX_WAITING_LIST_PARTICIPANTS
FROM
    activity a
CROSS JOIN
    centers c
LEFT JOIN
    area_center ac
ON
    AVAILABILITY||',' LIKE'%'||ac.s_id||',%'
AND c.id = ac.center_id
LEFT JOIN
    FW.ACTIVITY_GROUP ag
ON
    ag.id = a.ACTIVITY_GROUP_ID
LEFT JOIN
    FW.ACTIVITY_RESOURCE_CONFIGS arc
ON
    arc.ACTIVITY_ID = a.ID
LEFT JOIN
    FW.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = arc.BOOKING_RESOURCE_GROUP_ID
WHERE
    a.state = 'ACTIVE'
AND a.availability IS NOT NULL
GROUP BY
    a.id,
    a.name,
    a.scope_type,
    a.scope_id,
    a.AVAILABILITY,
    c.id,
    c.shortname,
    a.ACTIVITY_TYPE,
    ag.NAME,
    brg.NAME ,
    a.MAX_PARTICIPANTS,
    a.MAX_WAITING_LIST_PARTICIPANTS