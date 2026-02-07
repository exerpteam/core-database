WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id                                       AS centerid
        FROM
            centers c
    )
SELECT
	p.center ||'p'|| p.id AS member_ID,
	p.fullname AS member_name,
    ar.balance AS account_balance,
    ar.debit_max AS max_debit
FROM
persons p
JOIN
account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 1
WHERE
ar.debit_max != 0
AND NOT EXISTS
(SELECT
1
FROM
subscriptions s
JOIN
    subscription_addon sa
ON
    sa.subscription_center = s.center
AND sa.subscription_id = s.id
JOIN
    params
ON
    params.centerid = sa.center_id
JOIN
    masterproductregister mpr
ON
    sa.addon_product_id = mpr.id
WHERE
    sa.cancelled = false
AND (
        sa.end_date IS NULL
    OR  sa.end_date >= params.currentDate)
AND sa.start_date <= params.currentDate
AND mpr.globalid IN ('ALL_IN_ONE_1',
                     'ALL_IN_ONE_12',
                     'ALL_IN_ONE_24',
                     'ALL_IN_ONE_3',
                     'ALL_IN_ONE_6',
                     'NUTRITION_1',
                     'NUTRITION_12',
                     'LIVE_GROUP_FITNESS_24_1',
                     'NUTRITION_3',
                     'NUTRITION_6')
AND s.owner_center = p.center
AND s.owner_id = p.id)