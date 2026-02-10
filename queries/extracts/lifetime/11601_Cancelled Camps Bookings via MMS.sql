-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.firstname,
    p.lastname,
    p.center || 'p' || p.id AS PersonKey,
    p.external_id,
    pdts.name,
    pdts.external_id,
    longtodateC(card_clip_usages.last_modified, card_center) AS lastModified_time
FROM
    lifetime.clipcards
JOIN
    card_clip_usages
ON
    clipcards.center = card_clip_usages.card_center
AND clipcards.id = card_clip_usages.card_id
AND clipcards.subid = card_clip_usages.card_subid
JOIN
    lifetime.invoice_lines_mt ilm
ON
    clipcards.invoiceline_center = ilm.center
AND clipcards.invoiceline_id = ilm.id
AND clipcards.invoiceline_subid = ilm.subid
JOIN
    lifetime.persons p
ON
    ilm.person_center = p.center
AND ilm.person_id = p.id
JOIN
    lifetime.product_and_product_group_link ppgl
ON
    ilm.productcenter = ppgl.product_center
AND ilm.productid = ppgl.product_id
JOIN
    lifetime.product_group pg
ON
    ppgl.product_group_id = pg.id
AND pg.id IN (6001,
              6402,
              6403,
              6002,
              6201,
              6401,
              6601,
              6801,
              7001,
              6602)
JOIN
    lifetime.products pdts
ON
    ppgl.product_center = pdts.center
AND ppgl.product_id = pdts.id
WHERE
    -- clipcards.owner_center = 53
    -- AND clipcards.owner_id = 27517
    -- AND (
    --         clipcards.center,clipcards.id,clipcards.subid) IN ((53,19201,3),
    --                                                           (53,9603,3)) AND
    card_clip_usages.type = 'BUYOUT'
AND card_clip_usages.employee_center = 13
AND card_clip_usages.employee_id = 2
AND ilm.text LIKE '%Kids%'