SELECT
  c.shortname                        AS club_name,
  p.center || 'p' || p.id            AS id_socio,
  p.fullname                         AS full_name,
  prod.name                          AS nome_clipcard,
  TO_TIMESTAMP(cl.valid_from / 1000) AS data_vendita_clip
FROM clipcards cl
JOIN persons  p
  ON p.center = cl.owner_center
 AND p.id     = cl.owner_id
JOIN centers  c
  ON c.id = p.center
 AND c.country = 'IT'
JOIN products prod
  ON prod.id     = cl.id
 AND prod.center = cl.owner_center
WHERE prod.center IN ($$scope$$)
  AND prod.blocked = 0
  AND prod.ptype   = 4
  AND (
       ($$searchType$$ = 'TIMESTAMP' AND TO_TIMESTAMP(cl.valid_from / 1000) >= $$venduta_dal$$)
     OR ($$searchType$$ = 'PRODNAME'  AND prod.name = $$prod_name$$  AND TO_TIMESTAMP(cl.valid_from / 1000) >= $$venduta_dal$$)
     OR ($$searchType$$ = 'FULLNAME'  AND p.fullname = $$full_name$$ AND TO_TIMESTAMP(cl.valid_from / 1000) >= $$venduta_dal$$)
      )
  AND EXISTS (
        SELECT 1
        FROM product_and_product_group_link l
        WHERE l.product_center   = prod.center
          AND l.product_id       = prod.id
          AND l.product_group_id = 54003
  );