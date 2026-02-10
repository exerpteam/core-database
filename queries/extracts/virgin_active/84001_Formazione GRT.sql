-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
  cl.id                                   AS clip_id,
  c.shortname                            AS club_name,
  p.center || 'p' || p.id                AS id_socio,
  p.fullname                             AS full_name,
  prod.name                              AS nome_clipcard,
  TO_TIMESTAMP(cl.valid_from / 1000)     AS data_vendita_clip
  --, TO_TIMESTAMP(cl.valid_until / 1000) AS data_scadenza_clip
FROM 
	clipcards cl 
 JOIN products prod 
 ON cl.id = prod.id
 AND cl.center = prod.center
 JOIN persons p 
  ON p.center = cl.owner_center 
  AND p.id = cl.owner_id
JOIN centers c 
  ON c.id = p.center 
  AND c.country = 'IT'
JOIN product_group pg 
  ON pg.id = prod.primary_product_group_id
 LEFT JOIN product_and_product_group_link pgLink
  ON pgLink.product_center = prod.center
  AND pgLink.product_id = prod.id
LEFT JOIN product_group pgAll
 ON pgAll.id = pgLink.product_group_id
WHERE prod.center IN ($$scope$$)
  AND TO_TIMESTAMP(cl.valid_from / 1000) >= ($$venduta_dal$$)
  AND prod.blocked = 0
  AND prod.ptype = 4
  AND pgAll.id IN ('54003')