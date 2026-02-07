 WITH
     params AS
     (
      SELECT
                 /*+ materialize */
             CASE
                 WHEN (COUNT(*) over (partition BY pr.GLOBALID)) > 1
                 THEN 1
                 ELSE 0
             END AS override, pr.GLOBALID AS GLOBALID
        FROM
             products pr
        JOIN
             product_group pg ON pr.primary_product_group_id = pg.id
       WHERE
             pr.ptype = 1 --Goods
         AND pr.blocked = 0 --not blocked
    GROUP BY
             pg.name, pr.GLOBALID
     )
 SELECT
     pr.name AS product_name, pg.name AS product_group_name,
 --, c.country as override_country_scope
     case c.country when 'DK' then 'Denmark' when 'FI' then 'Finland' when 'NO' then 'Norway' when 'SE' then 'Sweden' else 'Other' end as override_country_name
 FROM
     products pr
 JOIN
     params ON params.GLOBALID = pr.GLOBALID
 JOIN
     product_group pg ON pr.primary_product_group_id = pg.id
 JOIN
     centers c ON pr.center = c.id
 WHERE
     override = 1
 GROUP BY
     pr.name, pg.name, c.country
 ORDER BY
     pr.name ASC
