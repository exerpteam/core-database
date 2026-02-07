SELECT
    club_name,
    id_socio,
    full_name,
    nome_clipcard,
    data_vendita_clip,
    data_scadenza_clip,
    data_utilizzo,
    status
FROM (
    SELECT
        c.shortname AS club_name,
        p.center || 'p' || p.id AS id_socio,
        p.fullname AS full_name,
        prod.name AS nome_clipcard,
        TO_TIMESTAMP(cl.valid_from / 1000) AS data_vendita_clip,
        TO_TIMESTAMP(cl.valid_until / 1000) AS data_scadenza_clip,
        TO_TIMESTAMP(ccu.time / 1000) AS data_utilizzo,
        CASE cl.finished 
            WHEN 'FALSE' THEN 'Active'
            WHEN 'TRUE' THEN 'Used'
        END AS status,
        ROW_NUMBER() OVER (
            PARTITION BY 
                c.shortname,
                p.center || 'p' || p.id,
                p.fullname,
                prod.name,
                TO_TIMESTAMP(cl.valid_from / 1000),
                TO_TIMESTAMP(cl.valid_until / 1000)
            ORDER BY 
                TO_TIMESTAMP(ccu.time / 1000) DESC
        ) AS rn
    FROM 
        clipcards cl 
        LEFT JOIN card_clip_usages ccu 
            ON ccu.card_center = cl.center 
            AND ccu.card_id = cl.id 
            AND ccu.card_subid = cl.subid 
            AND cl.finished = TRUE
        JOIN products prod 
            ON cl.id = prod.id
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
    WHERE 
        prod.center IN ($$scope$$)
        AND prod.blocked = 0
        AND prod.ptype = 4
        AND TO_TIMESTAMP(cl.valid_from / 1000) >= ($$venduta_dal$$)
        AND pgAll.id IN ('55001')
) t
WHERE rn = 1;
