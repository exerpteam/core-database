-- This is the version from 2026-02-05
--  
SELECT
    p.center||'p'||p.id as customer,
    p.firstname,
    p.lastname,
    p.ssn,
    SUM(
        CASE
            WHEN ci.checkin_center <> :scope
            THEN 1
            ELSE 0
        END) AS "Visit_other_club"
FROM
    fw.PERSONS p
JOIN fw.CHECKINS ci
ON
    p.center=ci.person_center
AND p.id=ci.person_id
WHERE
    ci.checkin_time BETWEEN :time_from AND :time_to+(24*3600*1000)
    and p.center = :scope
    and p.status in (1,3) -- active, temp. inactive
GROUP BY
    p.center,
    p.id,
    p.firstname,
    p.lastname,
    p.ssn
ORDER BY
    SUM(
        CASE
            WHEN ci.checkin_center <> :scope
            THEN 1
            ELSE 0
        END)
DESC