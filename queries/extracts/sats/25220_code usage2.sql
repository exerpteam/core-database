SELECT
    cen.Name AS CENTER,
    prg.NAME    campaign_name,
    cc.CODE,
    priset.NAME AS PrivilegeSetName,
    COUNT(cc.CODE) uses
FROM
    SATS.INVOICES inv
JOIN
    SATS.PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN
    SATS.INVOICELINES invl
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    SATS.PRODUCTS prod
ON
    invl.PRODUCTID = prod.ID
    AND invl.PRODUCTCENTER = prod.CENTER
JOIN
    SATS.PRIVILEGE_USAGES pu
ON
    pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.PRIVILEGE_TYPE = 'PRODUCT'
    AND pu.TARGET_CENTER = invl.CENTER
    AND pu.TARGET_ID = invl.ID
    AND pu.TARGET_SUBID = invl.SUBID
JOIN
    SATS.CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
    AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
JOIN
    SATS.PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = cc.CAMPAIGN_ID
LEFT JOIN
    CENTERS cen
ON
    cen. ID = P.CENTER
    
LEFT JOIN SATS.PRIVILEGE_GRANTS pgra
        on pgra.ID = pu.GRANT_ID
       

LEFT JOIN SATS.PRIVILEGE_SETS priset
        on priset.ID = pgra.PRIVILEGE_SET
    
WHERE
    inv.TRANS_TIME BETWEEN :from_date AND :to_date
    AND prg.PLUGIN_CODES_NAME = :pluginCodeName
    AND prod.CENTER IN (:scope)
GROUP BY
    cen.Name,
    prg.NAME,
    cc.CODE,
    priset.NAME