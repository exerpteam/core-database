-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    t1.center,
    t1.id,
    t1.center || 'p' || t1.id AS "PERSONKEY"
FROM
    (
        WITH
            PARAMS AS MATERIALIZED
            (
                SELECT
                    extract(DAY FROM TO_DATE(GETCENTERTIME(c.id), 'YYYY-MM-DD HH24:MI')) AS edate,
                    c.id                                                                 AS
                    center_id
                FROM
                    centers c
            )
        SELECT DISTINCT
            p.center,
            p.id
        FROM
            persons p
        JOIN
            subscriptions ss
        ON
            ss.owner_center = p.center
        AND ss.owner_id = p.id
        JOIN
            params
        ON
            params.center_id = ss.center
        JOIN
            products pr
        ON
            ss.subscriptiontype_center = pr.center
        AND ss.subscriptiontype_id = pr.id
        JOIN
            product_and_product_group_link pgl
        ON
            pr.center = pgl.product_center
        AND pr.id = pgl.product_id
        WHERE
            ss.state = 2
        AND ss.sub_state != 9
        AND pgl.product_group_id = 601
        --AND params.edate = 1
        --AND p.center IN (:center) 
        )t1