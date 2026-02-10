-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dates AS
    (
        SELECT
            generate_series(current_date - 1, '2024-01-01', '-1 day') AS campaign_date
    )

SELECT DISTINCT
dat.campaign_date,
sc.NAME CampaignName,
longtodate(sc.STARTTIME) CampaignStart,
longtodate(sc.ENDTIME) CampaignEnd,
sc.WEB_TEXT,
sc.AVAILABLE_SCOPES Availability,
sc.PLUGIN_CODES_NAME PromoCodeType,
pp.PRICE_MODIFICATION_NAME PriceChangeType,
pp.PRICE_MODIFICATION_AMOUNT Amount,
--pp.REF_TYPE,
--pr.GLOBALID ProductGlobalID,
pr.NAME ProductName
FROM
STARTUP_CAMPAIGN sc
JOIN PRIVILEGE_GRANTS pg
ON pg.GRANTER_ID = sc.ID
JOIN PRODUCT_PRIVILEGES pp
ON pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
		JOIN PRODUCTS pr
ON
		pp.REF_GLOBALID = pr.GLOBALID
		AND pr.PTYPE in (10, 5)
		AND pp.REF_TYPE = 'GLOBAL_PRODUCT'
JOIN dates dat
ON to_char(dat.campaign_date, 'J')::numeric >= to_char(longtodate(sc.STARTTIME), 'J')::numeric
AND to_char(dat.campaign_date, 'J')::numeric <= to_char(longtodate(sc.ENDTIME), 'J')::numeric
WHERE 
	sc.STARTTIME >= :FROMDATE
AND	sc.ENDTIME <= :TODATE
AND pg.GRANTER_SERVICE IN ('StartupCampaign')
AND pr.CENTER in (:scope)

UNION ALL

SELECT DISTINCT
dat.campaign_date,
sc.NAME CampaignName,
longtodate(sc.STARTTIME) CampaignStart,
longtodate(sc.ENDTIME) CampaignEnd,
sc.WEB_TEXT,
sc.AVAILABLE_SCOPES Availability,
sc.PLUGIN_CODES_NAME PromoCodeType,
pp.PRICE_MODIFICATION_NAME PriceChangeType,
pp.PRICE_MODIFICATION_AMOUNT Amount,
--pp.REF_TYPE,
--prod.GLOBALID ProductGlobalID,
prod.NAME ProductName
FROM
STARTUP_CAMPAIGN sc
JOIN PRIVILEGE_GRANTS pg
ON pg.GRANTER_ID = sc.ID
JOIN PRODUCT_PRIVILEGES pp
ON pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON 
		ppgl.PRODUCT_GROUP_ID = pp.REF_ID
		AND pp.REF_TYPE = 'PRODUCT_GROUP'
		JOIN PRODUCTS prod
		ON prod.CENTER = ppgl.PRODUCT_CENTER
		AND prod.ID = ppgl.PRODUCT_ID
		AND prod.PTYPE in (10, 5)
JOIN dates dat
ON to_char(dat.campaign_date, 'J')::numeric >= to_char(longtodate(sc.STARTTIME), 'J')::numeric
AND to_char(dat.campaign_date, 'J')::numeric <= to_char(longtodate(sc.ENDTIME), 'J')::numeric
WHERE
	sc.STARTTIME >= :FROMDATE
AND	sc.ENDTIME <= :TODATE
--AND pg.GRANTER_SERVICE IN ('StartupCampaign')
AND prod.CENTER in (:scope)
