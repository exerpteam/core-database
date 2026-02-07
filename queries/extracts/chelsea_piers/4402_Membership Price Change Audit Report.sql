WITH
    old_price AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    sp.price                         AS oldprice,
                    s.center||'ss'||s.id             AS subscriptionid,
                    s.owner_center||'p'|| s.owner_id AS memberid,
                    sp.from_date                     AS effect_date,
                    p.name                           AS product_name_old,
                    row_number() over (partition BY sp.subscription_center, sp.subscription_id
                    ORDER BY sp.from_date)                                                  AS rn,
                    COUNT(*) over (partition BY sp.subscription_center, sp.subscription_id) AS
                    maxrn
                FROM
                    subscription_price sp
                JOIN
                    subscriptions s
                ON
                    s.center = sp.subscription_center
                AND s.id = sp.subscription_id
                JOIN
                    products p
                ON
                    s.center = p.center
                AND s.subscriptiontype_id = p.id
                WHERE
                    cancelled IS false
                AND approved IS true
                AND sp.type IN ('NORMAL',
                                'SCHEDULED')
                GROUP BY
                    sp.price,
                    s.center||'ss'||s.id ,
                    s.owner_center||'p'|| s.owner_id,
                    sp.from_date,
                    p.name ,
                    sp.subscription_center,
                    sp.subscription_id )x
        WHERE
            x.rn = maxrn -1
    )
    ,
    new_price AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    sp.price                         AS newprice,
                    s.center||'ss'||s.id             AS subscriptionid,
                    s.owner_center||'p'|| s.owner_id AS memberid,
                    sp.from_date                     AS effect_date,
                    p.name                           AS product_name_new,
                    row_number() over (partition BY sp.subscription_center, sp.subscription_id
                    ORDER BY sp.from_date)                                                  AS rn,
                    COUNT(*) over (partition BY sp.subscription_center, sp.subscription_id) AS
                    maxrn
                FROM
                    subscription_price sp
                JOIN
                    subscriptions s
                ON
                    s.center = sp.subscription_center
                AND s.id = sp.subscription_id
                JOIN
                    products p
                ON
                    s.center = p.center
                AND s.subscriptiontype_id = p.id
                WHERE
                    cancelled IS false
                AND approved IS true
                AND sp.type IN ('NORMAL',
                                'SCHEDULED')
                GROUP BY
                    sp.price,
                    s.center||'ss'||s.id ,
                    s.owner_center||'p'|| s.owner_id,
                    sp.from_date,
                    p.name ,
                    sp.subscription_center,
                    sp.subscription_id )x
        WHERE
            x.rn = maxrn
        AND maxrn != 1
    )
    
    
SELECT
    op.memberid,
    op.subscriptionid,
    op.product_name_old,
    op.oldprice    AS old_price,
    np.newprice    AS new_price,
    np.effect_date AS effect_date
FROM
    old_price op
JOIN
    new_price np
ON
    np.subscriptionid = op.subscriptionid
AND np.memberid = op.memberid