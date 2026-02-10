-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
     params AS
     (
         SELECT
             /*+ materialize */
            CAST(datetolongC(TO_CHAR(DATE_TRUNC('month', (TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))), 'YYYY-MM-DD'), c.id) AS BIGINT) AS fromdate,
            c.id AS centerid
            FROM
            centers c
         
     )
SELECT
    --p.center,
    --p.id,
params.fromdate,
    p.center ||'p'|| p.id AS "PERSONKEY",
    cl.clips_left         AS remaining_clips,
    --cl.center             AS cl_center,
    --cl.id                 AS cl_id,
    --cl.subid              AS cl_subid,
    longtodate(cl.valid_from) AS clipcard_start,
    longtodate(cl.valid_until) AS clipcard_end
FROM
    clipcards cl
JOIN
    persons p
ON
    p.center = cl.owner_center
AND p.id = cl.owner_id
JOIN
params
ON
params.centerid = p.center
JOIN
    products pr
ON
    pr.center = cl.center
AND pr.id = cl.id
AND pr.globalid = 'FRIEND_ACCESS'
WHERE
 --   p.center IN (:center)
 cl.finished = false
AND cl.cancelled = false
AND cl.blocked = false
AND cl.valid_from < params.fromdate
AND EXISTS
    (
        SELECT
            1
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products prod
        ON
            prod.center = st.center
        AND prod.id = st.id
        JOIN
            product_and_product_group_link prgr
        ON
            prgr.product_center = prod.center
        AND prgr.product_id = prod.id
        AND prgr.product_group_id = 2601
        WHERE
            s.owner_center = cl.owner_center
        AND s.owner_id = cl.owner_id
        AND s.state IN (2,4))
ORDER BY
    owner_center,
    owner_id