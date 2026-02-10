-- The extract is extracted from Exerp on 2026-02-08
-- ST-693
SELECT
    centers_used,
    COUNT(centers_used) members
FROM
    (
        SELECT
            PERSON_CENTER,
            PERSON_ID,
            COUNT(CHECKIN_CENTER) centers_used
        FROM
            (
                SELECT
                    c.PERSON_CENTER,
                    c.PERSON_ID,
                    c.CHECKIN_CENTER,
                    COUNT(c.CHECKIN_CENTER) cnt
                FROM
                    checkins c
                WHERE
                    c.PERSON_CENTER IN ($$scope$$)
                    AND c.CHECKIN_TIME BETWEEN $$fromdate$$ AND $$todate$$
                GROUP BY
                    c.PERSON_CENTER,
                    c.PERSON_ID,
                    c.CHECKIN_CENTER )
        GROUP BY
            PERSON_CENTER,
            PERSON_ID
         )
GROUP BY
    centers_used