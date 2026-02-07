WITH
    params AS
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS CURRENT_DATE,
            c.id                                       AS center_id
        FROM
            centers c
    )
SELECT
    p.center ||'p'|| p.id AS "PERSONKEY",
    p.external_id         AS "External ID",
    pea.txtvalue          AS "Locker ID"
FROM
    persons p
JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
WHERE
    pea.name = 'lockerID'
AND pea.txtvalue IS NOT NULL
AND p.center IN (:scope)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions s
        JOIN
            params par
        ON
            par.center_id = s.center
        JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            masterproductregister mpr
        ON
            sa.addon_product_id = mpr.id
        AND mpr.globalid IN ('LOCKER_1_MONTH',
                             'LOCKER_12_MONTHS',
                             'LOCKER_3_MONTHS',
                             'LOCKER_6_MONTHS')
        WHERE
            s.owner_center = p.center
        AND s.owner_id = p.id
        AND sa.cancelled = false
        AND sa.start_date >= par.current_date)