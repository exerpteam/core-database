SELECT
        t1.center,
        t1.id,
        t1."PERSONKEY",
        t1.externalid,
        t1.tocenterid        
FROM
(
        SELECT
            DISTINCT
                p.center,
                p.id,
                p.center || 'p' || p.id AS "PERSONKEY", 
                p.external_id AS externalid,
                s.center AS tocenterid
        FROM
            vivagym.persons p
        JOIN
            vivagym.subscriptions s
        ON
            p.center = s.owner_center
        AND p.id = s.owner_id
        WHERE
            p.center != s.center
            AND s.state IN (2,4,8)
            AND p.center NOT IN (100,700)
            AND p.status NOT IN (4,5,7,8)
            AND NOT EXISTS 
            (
                SELECT
                        1
                FROM vivagym.subscriptions s2
                WHERE
                        p.center = s2.owner_center 
                        AND p.id = s2.owner_id
                        AND s2.center != s.center
                        AND (s2.center, s2.id) NOT IN ((s.center,s.id))
                        AND s2.state IN (2,4,8)
            )
            AND NOT EXISTS
            (
                SELECT
                        1
                FROM vivagym.subscriptions s3
                WHERE
                        s3.owner_center = s.owner_center
                        AND s3.owner_id = s.owner_id
                        AND s3.state IN (8)
                                
            )
) t1