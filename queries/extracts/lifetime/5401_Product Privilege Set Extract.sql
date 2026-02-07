SELECT
    
    t1.product_name,
    string_agg(CAST(t1.privilege_set_name AS TEXT), ' ; ') AS privilege,
    t1.center_name,
    t1.sanction

FROM
    (
        SELECT DISTINCT
            c.name   AS center_name,
            p.center AS centerid,
            p.name   AS product_name,
            ps.name  AS privilege_set_name,
            pp.name  AS sanction
        FROM
            lifetime.masterproductregister mpr
        JOIN
            products p
        ON
            mpr.globalid = p.globalid
        LEFT JOIN
            lifetime.privilege_grants pg
        ON
            mpr.id = pg.granter_id AND
            pg.valid_to IS NULL
        LEFT JOIN
            lifetime.privilege_sets ps
        ON
            pg.privilege_set = ps.id
        LEFT JOIN
            lifetime.privilege_punishments pp
        ON
            pg.punishment = pp.id
        JOIN
            centers c
        ON
            p.center = c.id
order by p.name asc, ps.name asc
        )t1
GROUP BY
    t1.center_name,
    t1.product_name,
    t1.sanction
order by t1.product_name asc;