WITH
    params AS
    (
        SELECT
            c.id AS CENTERID,
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            centers c
        
    )
SELECT
c.owner_center ||'p'||c.owner_id AS memberid,
    per.external_id,
STRING_AGG(CAST(c.center||'cc'||c.id||'cc'||c.subid AS TEXT),'; ') AS clipIDs,
    count(*)
    --c.center||'cc'||c.id||'cc'||c.subid AS CLIPID,
    --c.clips_left||'/'||c.clips_initial  AS clipsusage,
    --ccu.description                     AS usage_description,
    --c.finished--,
--    longtodateC(c.valid_until,c.center) as current_valid_until
FROM
    clipcards c
JOIN
    params
ON
    centerid = c.center
JOIN
    persons per
ON
    c.owner_center = per.center
AND c.owner_id = per.id
JOIN
    invoice_lines_mt ilm
ON
    c.invoiceline_center=ilm.center
AND c.invoiceline_id = ilm.id
AND c.invoiceline_subid = ilm.subid
JOIN
    invoices i
ON
    i.center = ilm.center
AND i.id = ilm.id
JOIN
    products p
ON
    p.center = ilm.productcenter
AND p.id = ilm.productid
AND p.globalid = $$product_globalID$$
LEFT JOIN
    lifetime.card_clip_usages ccu
ON
    c.center = ccu.card_center
AND c.id = ccu.card_id
AND c.subid = ccu.card_subid
WHERE
    valid_from BETWEEN FROM_DATE AND TO_DATE
AND i.employee_center =13
AND i.employee_id =2

group by
    --c.valid_from,
    --c.center,c.id,c.subid,
    c.owner_center,c.owner_id,
   -- ccu.description,
    --ccu.description
    per.external_id
    having count(*) >1