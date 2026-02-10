-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center||'p'||p.id          AS MemberID,
    NVL (results.CentersCount,0) AS CentersCount
FROM
    persons p
LEFT JOIN
    (
        SELECT DISTINCT
            p.center,
            p.id,
            COUNT(*) AS CentersCount
        FROM
            persons p
        JOIN
            (
                SELECT DISTINCT
                    ci.PERSON_CENTER,
                    ci.PERSON_ID,
                    ci.CHECKIN_CENTER
                FROM
                    PUREGYM.CHECKINS ci
                GROUP BY
                    ci.PERSON_CENTER,
                    ci.PERSON_ID,
                    ci.CHECKIN_CENTER ) ci
        ON
            ci.PERSON_CENTER = p.center
            AND ci.PERSON_ID = p.ID
        GROUP BY
            p.center,
            p.id) results
ON
    p.CENTER = results.center
    AND p.id=results.id
WHERE
p.CENTER in(:scope) and
p.PERSONTYPE<>2
and p.STATUS in (1,3)