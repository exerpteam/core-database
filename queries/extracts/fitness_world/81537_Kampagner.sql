-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dates AS
    (
        SELECT
            TRUNC(current_date -1) AS campaign_date
        FROM

            persons
        WHERE
            rownum <= (to_number(to_char(sysdate, 'J')))-(to_number(to_char(DATE '2019-01-01', 'J')))
    )

SELECT DISTINCT
dat.campaign_date,
sc.NAME CampaignName,
longtodate(sc.STARTTIME) CampaignStart,
longtodate(sc.ENDTIME) CampaignEnd,
--sc.WEB_TEXT,
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
AND pp.REF_TYPE = 'PRODUCT_GROUP'
JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
ON 
		ppgl.PRODUCT_GROUP_ID = pp.REF_ID
		
		JOIN PRODUCTS prod
		ON prod.CENTER = ppgl.PRODUCT_CENTER
		AND prod.ID = ppgl.PRODUCT_ID
		AND prod.PTYPE in (10, 5)
JOIN dates dat
ON to_number(to_char(dat.campaign_date, 'J')) >= to_number(to_char(longtodate(sc.STARTTIME), 'J'))
AND to_number(to_char(dat.campaign_date, 'J')) <= to_number(to_char(longtodate(sc.ENDTIME), 'J'))
WHERE 
	dat.campaign_date BETWEEN :FROMDATE AND :TODATE
AND pg.GRANTER_SERVICE IN ('StartupCampaign')
AND prod.CENTER in (:scope)