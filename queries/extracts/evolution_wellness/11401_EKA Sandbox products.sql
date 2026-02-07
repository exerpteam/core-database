SELECT
    pr.globalid,
    pr.name          AS "Product Name",
    inc_acc.globalid AS "Sales Account Global ID",
    inc_acc.name     AS "Sales Account Name",
inc_acc.external_id     AS "Sales Account ID",
    exp_acc.globalid AS "Expense Account Global ID",
    exp_acc.name     AS "Expense Account Name",
exp_acc.external_id     AS "Expense Account ID",
    ref_acc.globalid AS "Refund Account Global ID",
    ref_acc.name     AS "Refund Account Name",
ref_acc.external_id     AS "Refund Account ID",
    COUNT(*)         products_count
FROM
    products pr
LEFT JOIN
    evolutionwellness.product_account_configurations pac
ON
    pac.id = pr.product_account_config_id
LEFT JOIN
    evolutionwellness.accounts inc_acc
ON
    inc_acc.center = pr.center
AND inc_acc.globalid = pac.sales_account_globalid
LEFT JOIN
    evolutionwellness.accounts exp_acc
ON
    exp_acc.center = pr.center
AND exp_acc.globalid = pac.expenses_account_globalid
LEFT JOIN
    evolutionwellness.accounts ref_acc
ON
    ref_acc.center = pr.center
AND ref_acc.globalid = pac.refund_account_globalid
WHERE
pr.ptype in (1,2,4,8,9,10,13)
and   pr.center IN ($$scope$$)
GROUP BY
    pr.globalid,
    pr.name ,
    inc_acc.globalid ,
    inc_acc.name ,
inc_acc.external_id,
    exp_acc.globalid ,
    exp_acc.name ,
exp_acc.external_id,
    ref_acc.globalid ,
    ref_acc.name,
ref_acc.external_id