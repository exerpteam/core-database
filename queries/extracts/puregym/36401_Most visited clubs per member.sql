WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate,
            ($$EndDate$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
SELECT
    primaryClubId                            AS "Primary Gym Id",
    primaryClubName                          AS "Primary Gym Name",
    MAX(DECODE (RANK, 1, secondaryClubId))   AS "1st Most Visited Gym Id",
    MAX(DECODE (RANK, 1, secondaryClubName)) AS "1st Most Visited Gym Name",
    MAX(DECODE (RANK, 1, Total))             AS "1st Most Visited Gym Count",
    MAX(DECODE (RANK, 2, secondaryClubId))   AS "2st Most Visited Gym Id",
    MAX(DECODE (RANK, 2, secondaryClubName)) AS "2st Most Visited Gym Name",
    MAX(DECODE (RANK, 2, Total))             AS "2st Most Visited Gym Count",
    MAX(DECODE (RANK, 3, secondaryClubId))   AS "3rd Most Visited Gym Id",
    MAX(DECODE (RANK, 3, secondaryClubName)) AS "3rd Most Visited Gym Name",
    MAX(DECODE (RANK, 3, Total))             AS "3rd Most Visited Gym Count"
FROM
    (
        SELECT
            primaryClub.id          AS primaryClubId,
            primaryClub.shortname   AS primaryClubName,
            secondaryClub.id        AS secondaryClubId,
            secondaryClub.shortname AS secondaryClubName,
            Total,
            RANK
        FROM
            (
                SELECT
                    ch.PERSON_CENTER,
                    ch.CHECKIN_CENTER,
                    COUNT(*)                                                           AS Total,
                    rank() over (partition BY ch.PERSON_CENTER ORDER BY COUNT(*) DESC) AS RANK
                FROM
                    CHECKINS ch
                CROSS JOIN
                    params
                WHERE
                    ch.PERSON_CENTER != ch.CHECKIN_CENTER
                    AND ch.PERSON_CENTER IN ($$scope$$)
                    AND ch.checkin_time >= params.FromDate
                    AND ch.checkin_time <= params.ToDate
                GROUP BY
                    ch.PERSON_CENTER,
                    ch.CHECKIN_CENTER )
        JOIN
            centers primaryClub
        ON
            primaryClub.id = PERSON_CENTER
        JOIN
            centers secondaryClub
        ON
            secondaryClub.id = CHECKIN_CENTER
        WHERE
            rank IN (1,2,3) )
GROUP BY
    primaryClubId ,
    primaryClubName