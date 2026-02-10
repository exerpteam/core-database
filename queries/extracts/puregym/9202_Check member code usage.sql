-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.NAME AS CENTER,
    p.FULLNAME,
    p.CENTER || 'p' || p.ID AS Pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    longToDate(inv.TRANS_TIME)   used_time,
    prg.NAME                     campaign_name,
    longToDate(cc.CREATION_TIME) codes_created,
    longToDate(prg.STARTTIME)    campaign_start_time,
    prod.NAME,
    invl.TOTAL_AMOUNT,
    invl.QUANTITY,
    prg.NAME AS "Campaign",
    cc.CODE
FROM
    INVOICES inv
JOIN
    PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN
    INVOICELINES invl
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    PRODUCTS prod
ON
    invl.PRODUCTID = prod.ID
    AND invl.PRODUCTCENTER = prod.CENTER
JOIN
    PRIVILEGE_USAGES pu
ON
    pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.PRIVILEGE_TYPE = 'PRODUCT'
    AND pu.TARGET_CENTER = invl.CENTER
    AND pu.TARGET_ID = invl.ID
    AND pu.TARGET_SUBID = invl.SUBID
JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
    AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = cc.CAMPAIGN_ID
LEFT JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
WHERE
    (p.CENTER,p.id) in(:MEMBER_IDS)