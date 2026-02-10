-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dates AS
    (
        SELECT
            TRUNC(exerpsysdate()) -rownum AS campaign_date
        FROM

            persons
        WHERE
            rownum <= (to_number(to_char(sysdate, 'J')))-(to_number(to_char(DATE '2019-01-01', 'J')))
    ),
	prodgroup AS
	(
		SELECT DISTINCT
			prod.GLOBALID,
			pp_prodgroup.REF_ID,
			prod.NAME
	 	FROM
			PRODUCT_PRIVILEGES pp_prodgroup
	 	JOIN 
			PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
	 	ON
	  		pp_prodgroup.REF_ID = ppgl.PRODUCT_GROUP_ID
	 	AND pp_prodgroup.REF_TYPE = 'PRODUCT_GROUP'
	 	JOIN 
			PRODUCTS prod
	 	ON 
			prod.CENTER = ppgl.PRODUCT_CENTER
			AND prod.ID = ppgl.PRODUCT_ID
			AND prod.PTYPE in (10, 5)
	)

SELECT DISTINCT
	dat.campaign_date,
	prg.NAME CampaignName,
	--longtodate(prg.STARTTIME) CampaignStart,
	--longtodate(prg.ENDTIME) CampaignEnd,
	--prg.WEB_TEXT,
	prg.AVAILABLE_SCOPES Availability,
	prg.PLUGIN_CODES_NAME PromoCodeType,
	pp.PRICE_MODIFICATION_NAME PriceChangeType,
	pp.PRICE_MODIFICATION_AMOUNT Amount,
	pp.REF_TYPE,
	pr.PTYPE,
	--prod.GLOBALID ProductGlobalID,
CASE
	WHEN pp.REF_TYPE = 'GLOBAL_PRODUCT'
	THEN pr.NAME
	ELSE prodgroup.NAME
	END AS "ProductName"
FROM
	PRIVILEGE_RECEIVER_GROUPS prg

JOIN 
	PRIVILEGE_GRANTS pg
ON 
	pg.GRANTER_ID = prg.ID

JOIN 
	PRODUCT_PRIVILEGES pp
ON 
	pp.PRIVILEGE_SET = pg.PRIVILEGE_SET

LEFT JOIN
	PRODUCTS pr
ON	
	pp.REF_GLOBALID = pr.GLOBALID
	AND pr.PTYPE in (10, 5)
	AND pp.REF_TYPE = 'GLOBAL_PRODUCT'

LEFT JOIN
	prodgroup
ON
	pp.REF_ID = prodgroup.REF_ID

JOIN 
	dates dat
ON 
	to_number(to_char(dat.campaign_date, 'J')) >= to_number(to_char(longtodate(prg.STARTTIME), 'J'))
AND to_number(to_char(dat.campaign_date, 'J')) <= to_number(to_char(longtodate(prg.ENDTIME), 'J'))

WHERE 
	prg.RGTYPE = 'CAMPAIGN'
AND prg.STARTTIME BETWEEN :FROMDATE AND :TODATE
AND pg.GRANTER_SERVICE IN ('ReceiverGroup')