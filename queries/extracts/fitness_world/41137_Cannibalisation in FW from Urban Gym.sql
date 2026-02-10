-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2905
WITH
    v_UG_Club AS
    (
        SELECT
            c.*
        FROM
            AREA_CENTERS ac
        JOIN
            centers c
        ON
            c.id = ac.center
        JOIN
            (
                SELECT
                    a.id                 AS area_id,
                    a.name               AS area_name,
                    connect_by_root a.id AS area_root_id,
                    level                AS area_node_level
                FROM
                    AREAS a START WITH a.name = 'UG' CONNECT BY PRIOR a.id = a.parent )area_level
        ON
            area_level.area_id = ac.area
    )
SELECT DISTINCT
    ug_per.fullname,
    ug_per.ssn,
    ug_per.center || 'p' || ug_per.id         AS "UG Person Id",
    ug_prod.name                              AS "UG Subscription Name",
    ug_club.shortname                         AS "UG Home Club Name",
    TRUNC(ug_sub.start_date)                  AS "UG Subscription Start Date",
    non_ug_per.center || 'p' || non_ug_per.id AS "FW Person Id",
    non_ug_prod.name                          AS "FW Subscription Name",
    non_ug_club.shortname                     AS "FW Home Club Name",
    TRUNC(non_ug_sub.end_date)                AS "FW Subscription Stop Date"
FROM
    v_UG_Club ug_club
JOIN
    persons ug_per
ON
    ug_club.id = ug_per.center
JOIN
    subscriptions ug_sub
ON
    ug_sub.owner_center = ug_per.center
    AND ug_sub.owner_id = ug_per.id
JOIN
    products ug_prod
ON
    ug_prod.center = ug_sub.subscriptiontype_center
    AND ug_prod.id = ug_sub.subscriptiontype_id
JOIN
    persons non_ug_per
ON
    non_ug_per.center != ug_club.id
JOIN
    centers non_ug_club
ON
    non_ug_club.id = non_ug_per.center
JOIN
    subscriptions non_ug_sub
ON
    non_ug_sub.owner_center = non_ug_per.center
    AND non_ug_sub.owner_id = non_ug_per.id
JOIN
    products non_ug_prod
ON
    non_ug_prod.center = non_ug_sub.subscriptiontype_center
    AND non_ug_prod.id = non_ug_sub.subscriptiontype_id
WHERE
    ug_per.status IN (1,3)
    AND ug_per.ssn = non_ug_per.ssn
    AND TRUNC(ug_sub.start_date) BETWEEN $$Fromdate$$ AND $$ToDate$$
    AND TRUNC(ug_sub.start_date) - TRUNC(non_ug_sub.end_date) BETWEEN 0 AND $$Numberofdays$$    	