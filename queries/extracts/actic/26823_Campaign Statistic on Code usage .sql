SELECT
    cen.NAME AS CENTER,
    p.FULLNAME,
    p.CENTER || 'p' || p.ID AS Pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    longToDate(inv.TRANS_TIME)                              used_time,
    longToDate(cc.CREATION_TIME)                            codes_created,
    NVL(longToDate(prg.STARTTIME),longtodate(sc.STARTTIME)) campaign_start_time,
    prod.NAME,
    invl.TOTAL_AMOUNT,
    invl.QUANTITY,
    NVL(prg.NAME,sc.NAME) AS "Campaign",
	prg.NAME as "PRG",
	sc.NAME as "SC",
	cc.code
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
LEFT JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.id = cc.CAMPAIGN_ID
    AND cc.CAMPAIGN_TYPE ='STARTUP'
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = cc.CAMPAIGN_ID
    AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
LEFT JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
WHERE
    inv.TRANS_TIME BETWEEN :longDateFrom AND :longDateTo
    AND prod.CENTER IN (:scope)