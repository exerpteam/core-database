SELECT
    clipcard,
    clip_sum,
    clips_initial,
    clips_initial - clip_sum AS actual_clips_left,
    clips_left,
    valid_from,
    oc ||'p'|| oi AS person_id,
    finished
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
                    card_clip_usages cu
                JOIN
                    clipcards c
                ON
                    cu.card_center = c.center
                AND cu.card_id = c.id
                AND cu.card_subid = c.subid
                WHERE
                    cu.state = 'ACTIVE'
                AND cu.type IN ( 'SANCTION',
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
            c.center,
            c.id,
            c.subid,
            c.clips_left,
            c.clips_initial,
            longtodateC(c.valid_from,100) AS valid_from,
            c.owner_center                AS oc,
            c.owner_id                    AS oi,
            c.finished,
            c.last_modified,
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
    clips_initial - clip_sum <> clips_left
AND finished = false
    ;
    
    
   