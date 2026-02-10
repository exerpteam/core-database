-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cp2.external_id,
    First_checkin.center,
    longtodate(ch2.checkin_time) AS First_checkin,
    c2.shortname                 AS Checkin_center
FROM
    (
        SELECT
            c.shortname AS center,
            cp.external_id,
            MIN(ch.checkin_time) AS First_checkin
        FROM
            persons cp
        JOIN
            persons p
        ON
            p.current_person_center = cp.center
            AND p.current_person_id = cp.id
        LEFT JOIN
            checkins ch
        ON
            ch.person_center = p.center
            AND ch.person_id = p.id
        JOIN
            centers c
        ON
            c.id = cp.center
        WHERE
            ch.checkin_time BETWEEN $$from_date$$ AND $$to_date$$
            AND cp.external_id IN ($$external_ids$$)
        GROUP BY
            cp.external_id,
            c.shortname) first_checkin
JOIN
    persons cp2
ON
    cp2.external_id = first_checkin.external_id
JOIN
    persons p2
ON
    p2.current_person_center = cp2.center
    AND p2.current_person_id = cp2.id
JOIN
    checkins ch2
ON
    ch2.person_center = p2.center
    AND ch2.person_id = p2.id
    AND ch2.checkin_time = first_checkin.First_checkin
JOIN
    centers c2
ON
    c2.id = ch2.checkin_center
   