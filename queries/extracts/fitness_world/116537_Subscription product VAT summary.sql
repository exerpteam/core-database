-- This is the version from 2026-02-05
--  
SELECT
    c.name                          AS "Scope"
    , pr.globalid                   AS "Product"
    , pr.name                       AS "Product name"
    ,pac.name                       AS "Account configuration"
    ,pac.sales_account_globalid     AS "Income account"
    , iac.external_id               AS "Income external ID"
    ,ivat.rate*100||'%'             AS "Income account tax rate"
    ,pac.refund_account_globalid    AS "Refund account"
    , rac.external_id               AS "Refund external ID"
    ,rvat.rate*100||'%'             AS "Refund account tax rate"
    ,pac.write_off_account_globalid AS "Write-off account"
    , wac.external_id               AS "Write-off external ID"
    ,wvat.rate*100||'%'             AS "Write-off account tax rate"
    ,pac.defer_rev_account_globalid AS "Deferred revenue sales account"
    , drac.external_id              AS "Deferred revenue sales external ID"
    ,drvat.rate*100||'%'            AS "Deferred revenue sales account tax rate"
    ,pac.defer_lia_account_globalid AS "Deferred revenue liability account"
    , dlac.external_id              AS "Deferred revenue liability external ID"
    ,dlvat.rate*100||'%'            AS "Deferred revenue liability account tax rate"
FROM
    products pr
LEFT JOIN
    product_account_configurations pac
ON
    pac.id = pr.product_account_config_id
LEFT JOIN
    centers c
ON
    c.id = pr.center
    -- Sales accounts
LEFT JOIN
    accounts iac
ON
    iac.globalid = pac.sales_account_globalid
AND iac.center = c.id
LEFT JOIN
    account_vat_type_link iavtl
ON
    iavtl.account_vat_type_group_id = iac.account_vat_type_group_id
LEFT JOIN
    vat_types ivat
ON
    ivat.center = iavtl.vat_type_center
AND ivat.id = iavtl.vat_type_id
    -- Refund accounts
LEFT JOIN
    accounts rac
ON
    rac.globalid = pac.refund_account_globalid
AND rac.center = c.id
LEFT JOIN
    account_vat_type_link ravtl
ON
    ravtl.account_vat_type_group_id = rac.account_vat_type_group_id
LEFT JOIN
    vat_types rvat
ON
    rvat.center = ravtl.vat_type_center
AND rvat.id = ravtl.vat_type_id
    -- Writeoff Account
LEFT JOIN
    accounts wac
ON
    wac.globalid = pac.write_off_account_globalid
AND wac.center = c.id
LEFT JOIN
    account_vat_type_link wavtl
ON
    wavtl.account_vat_type_group_id = wac.account_vat_type_group_id
LEFT JOIN
    vat_types wvat
ON
    wvat.center = wavtl.vat_type_center
AND wvat.id = wavtl.vat_type_id
    -- Deferred revenue sales Account
LEFT JOIN
    accounts drac
ON
    drac.globalid = pac.defer_rev_account_globalid
AND drac.center = c.id
LEFT JOIN
    account_vat_type_link dravtl
ON
    dravtl.account_vat_type_group_id = drac.account_vat_type_group_id
LEFT JOIN
    vat_types drvat
ON
    drvat.center = dravtl.vat_type_center
AND drvat.id = dravtl.vat_type_id
    -- Deferred revenue liability Account
LEFT JOIN
    accounts dlac
ON
    dlac.globalid = pac.defer_lia_account_globalid
AND dlac.center = c.id
LEFT JOIN
    account_vat_type_link dlavtl
ON
    dlavtl.account_vat_type_group_id = dlac.account_vat_type_group_id
LEFT JOIN
    vat_types dlvat
ON
    dlvat.center = dlavtl.vat_type_center
AND dlvat.id = dlavtl.vat_type_id
WHERE
    pr.ptype = 10 
AND pr.center IN ($$scope$$)