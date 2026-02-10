-- The extract is extracted from Exerp on 2026-02-08
-- ES-27674
To find instances when clips have not been correctly deducted
SELECT
    clipcard,
    clip_sum,
    valid_from,
    oc ||'p'|| oi as person_id
FROM
    (
        WITH
            params AS
            (
                SELECT
                    c.center,
                    c.id,
                    c.subid,
                    ABS(SUM(cu.clips)) AS clip_sum
                FROM
                    goodlife.card_clip_usages cu
                JOIN
                    clipcards c
                ON
                    cu.card_center = c.center
                AND cu.card_id = c.id
                AND cu.card_subid = c.subid
                WHERE
                    cu.state = 'ACTIVE'
                AND cu.type IN (
                                'SANCTION',
                                'PRIVILEGE',
                                'ADJUSTMENT',
                                'BUYOUT')
                GROUP BY
                    c.center,
                    c.id,
                    c.subid
            )
        SELECT
            c.center||'cc'||c.id||'cc'||c.subid AS clipcard,
            c.clips_left,
            c.clips_initial,
            longtodateC(c.valid_from,990) as valid_from,
            c.owner_center as oc,
            c.owner_id as oi,
            clip_sum
        FROM
            clipcards c
        JOIN
            params
        ON
            params.center = c.center
        AND params.id = c.id
        AND params.subid = c.subid ) AS clips
WHERE
    clip_sum = clips_initial
AND clips_left > 0