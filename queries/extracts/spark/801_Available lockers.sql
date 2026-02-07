SELECT
t2.center_id AS "Center ID",
"Center Name",
t2.locker_id AS "Locker ID"
FROM
(
SELECT
    t.center_id,
    c.name                                          AS "Center Name",
    UNNEST(regexp_split_to_array(t.locker_id, ',')) AS locker_id
FROM
    (
        SELECT
            cea.center_id                                          AS center_id,
            CAST(convert_from(cea.mime_value, 'UTF-8') AS VARCHAR) AS locker_id
        FROM
            center_ext_attrs cea
        WHERE
            cea.name = 'lockers' ) t
JOIN
    centers c
ON
    c.id = t.center_id
WHERE
    c.id IN (:centers)
GROUP BY
    t.center_id,
    c.name,
    t.locker_id
) t2
WHERE
NOT EXISTS
(SELECT
1
FROM
person_ext_attrs pea
WHERE
pea.personcenter = t2.center_id
AND pea.name = 'lockerID'
AND pea.txtvalue = t2.locker_id
)