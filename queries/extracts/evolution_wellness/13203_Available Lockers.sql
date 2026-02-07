WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id                                       AS CenterID
        FROM
            centers c
    )
SELECT
    t2.center_id AS "Center ID",
    t2.name      AS "Center Name",
    t2.locker_id AS "Locker ID",
    CASE
        WHEN t2.gender_room = 'M'
        THEN 'Male'
        WHEN t2.gender_room = 'F'
        THEN 'Female'
    END AS "Room",
    t2.locker_size AS "Size"
FROM
    (
        SELECT
            t.center_id,
            c.name,
            UNNEST(regexp_split_to_array(t.locker_id, ',')) AS locker_id,
            CASE
                WHEN t.locker_type IN ('LockerLargeFemale', 'LockerSmallFemale')
                THEN 'F'
                WHEN t.locker_type IN ('LockerSmallMale', 'LockerLargeMale')
                THEN 'M'
            END AS gender_room,
            CASE
                WHEN t.locker_type IN ('LockerLargeFemale', 'LockerLargeMale')
                THEN 'Medium'
                WHEN t.locker_type IN ('LockerSmallMale', 'LockerSmallFemale')
                THEN 'Small'
                END AS locker_size
        FROM
            (
                SELECT
                    cea.center_id                                          AS center_id,
                    cea.name                                               AS locker_type,
                    CAST(convert_from(cea.mime_value, 'UTF-8') AS VARCHAR) AS locker_id
                FROM
                    center_ext_attrs cea
                WHERE
                    cea.name IN (:gender)
                 ) t
        JOIN
            centers c
        ON
            c.id = t.center_id
            WHERE
            c.id IN (:centers)
        GROUP BY
            t.center_id,
            c.name,
            t.locker_id,
            t.locker_type) t2
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_M'
        WHERE
            pea.name = 'LargeLockerID'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Medium'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate) )
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_M__1'
        WHERE
            pea.name = 'LargeLockerID2'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Medium'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate))
AND NOT EXISTS
    (
        SELECT
            pea.txtvalue,
            sa.*
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_M__2'
        WHERE
            pea.name = 'LargeLockerID3'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Medium'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate))
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_S'
        WHERE
            pea.name = 'SmallLockerID'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Small'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate) )
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_S__1'
        WHERE
            pea.name = 'SmallLockerID2'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Small'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate))
AND NOT EXISTS
    (
        SELECT
            pea.txtvalue,
            sa.*
        FROM
            person_ext_attrs pea
        JOIN
            persons p
        ON
            p.center = pea.personcenter
        AND p.id = pea.personid
        JOIN
            params
        ON
            params.centerID = p.center
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid = 'MEMBERSHIP_LK_S__2'
        WHERE
            pea.name = 'SmallLockerID3'
        AND t2.gender_room = p.sex
        AND pea.txtvalue = t2.locker_id
        AND t2.locker_size = 'Small'
        AND sa.center_id = t2.center_id
        AND sa.cancelled = false
        AND sa.start_date <= params.currentDate
        AND (
                sa.end_date IS NULL
            OR  sa.end_date >= params.currentDate))
ORDER BY
t2.center_id,
t2.gender_room,
t2.locker_size DESC,
t2.locker_id