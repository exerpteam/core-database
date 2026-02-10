-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    aa.a as Class_min,
    AVG(
        CASE
            WHEN par >= aa.a
            THEN mem
            ELSE NULL
        END) AS avg_more_or_Equal,
    AVG(
        CASE
            WHEN par < aa.a
            THEN mem
            ELSE NULL
        END) AS avg_less
FROM
    (
        SELECT DISTINCT
            cp.center||'p'|| cp.id                                                                                  AS Member_ID,
            (NVL(cp.LAST_ACTIVE_END_DATE,TRUNC(SYSDATE)) - cp.LAST_ACTIVE_START_DATE) +cp.ACCUMULATED_MEMBERDAYS +1 AS Mem,
            NVL(SUM(par.num),0)                                                                                     AS par
        FROM
            PUREGYM.PERSONS cp
        JOIN
            PUREGYM.PERSONS p
        ON
            p.CURRENT_PERSON_CENTER = cp.CENTER
            AND p.CURRENT_PERSON_ID = cp.id
        LEFT JOIN
            (
                SELECT
                    par.PARTICIPANT_CENTER ,
                    par.PARTICIPANT_ID,
                    COUNT(*) AS num
                FROM
                    PUREGYM.PARTICIPATIONS par
                JOIN
                    PUREGYM.BOOKINGS bo
                ON
                    bo.center = par.BOOKING_CENTER
                    AND bo.id = par.BOOKING_ID
                JOIN
                    PUREGYM.ACTIVITY ac
                ON
                    ac.ID = bo.ACTIVITY
                WHERE
                    par.STATE = 'PARTICIPATION'
                    AND ac.id !=206group BY par.PARTICIPANT_CENTER ,
                    par.PARTICIPANT_ID) par
        ON
            par.PARTICIPANT_CENTER = p.center
            AND par.PARTICIPANT_ID = p.id
        WHERE
            p.CURRENT_PERSON_CENTER IN ($$scope$$)
        GROUP BY
            cp.center||'p'|| cp.id ,
            (NVL(cp.LAST_ACTIVE_END_DATE,TRUNC(SYSDATE)) - cp.LAST_ACTIVE_START_DATE) +cp.ACCUMULATED_MEMBERDAYS +1)
CROSS JOIN
    (
        SELECT
            0 + level AS a
        FROM
            dual CONNECT BY LEVEL <= $$Class_min$$) aa
GROUP BY
    aa.a order by aa.a