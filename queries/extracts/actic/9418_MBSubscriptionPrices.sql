-- The extract is extracted from Exerp on 2026-02-08
--  
/* Subscription Prices */
SELECT
	cen.EXTERNAL_ID AS Cost,
	prod.center AS CenterId,
	cen.shortname AS CenterName,
--	prod.id AS ProductId,
--	DECODE (prod.ptype, 1,'RETAIL', 2,'SERVICE', 4,'CLIPCARD', 5,'JOINING FEE', 8,'GIFTCARD', 10,'SUBSCRIPTION') AS ProductType,
	prod.name AS ProductName,
	current_join.JoiningFee,
	prod.price AS ProductPrice,
	CASE
		WHEN st.BINDINGPERIODCOUNT IS NULL
		THEN st.PERIODCOUNT
		ELSE st.BINDINGPERIODCOUNT
	END AS BindingMonths,	
	CASE  st.ST_TYPE  WHEN 0 THEN 'CASH'  WHEN 1 THEN 'EFT' END AS St_Type,
	prod.globalid,
--	current_pgl.MaxProductGroupId,
	pg.name AS MaxProductGroup,
	current_join.needs_privilege AS NeedsPrivilege,
	current_join.show_on_web AS ShowOnWeb,
	prod.BLOCKED,
	current_join.SHOW_IN_SALE AS ShowInSale,
--	current_join.requiredrole,
	role.rolename AS RequiredRole,
	prod.center||'p'||prod.id AS FullProductID,
	prod.EXTERNAL_ID,
	'https://www.se/bli-medlem/'||prod.center||'p'||prod.id||:url_part||:campaignCode AS QR


FROM
	PRODUCTS prod

/* joining centers table for name and cost center */
JOIN CENTERS cen
ON
	cen.id = prod.center

/* Subscriptiontypes table for type and bindning, use JOIN for only subscriptions */
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID

/* Adds Max productgroup */
LEFT JOIN
    (
        SELECT
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID,
			MAX(pgl.PRODUCT_GROUP_ID) as MaxProductGroupId
        FROM
			PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        GROUP BY
            pgl.PRODUCT_CENTER,
            pgl.PRODUCT_ID
    )
    current_pgl
ON
    current_pgl.PRODUCT_CENTER = st.center
	AND current_pgl.PRODUCT_ID = st.id

/* joining productgroup for pg name */
LEFT JOIN PRODUCT_GROUP pg
ON
	pg.id = current_pgl.MaxProductGroupId
	
/* Links joining fee with subscription */
LEFT JOIN
	(
		SELECT
			join_st.ID,
			join_st.CENTER,
			join_prod.needs_privilege,
			join_prod.show_on_web,
			join_prod.requiredrole,
			join_prod.show_in_sale,
			join_prod.PRICE AS JoiningFee
		FROM
			SUBSCRIPTIONTYPES join_st
		LEFT JOIN products join_prod
		ON
		join_prod.CENTER = join_st.CENTER
		AND join_prod.ID = join_st.PRODUCTNEW_ID
	)
	current_join
ON
	current_join.CENTER = prod.center
	AND current_join.ID = prod.id

/* joining roles for rolename */
LEFT JOIN ROLES role
ON
	role.id = current_join.requiredrole
	
WHERE
--	prod.center < 200
    prod.center in (:ChosenScope)
--	AND prod.ptype = 10
--	AND prod.REQUIREDROLE IS NULL
--	AND prod.needs_privilege = 0
--	AND prod.BLOCKED = 0
--	AND prod.SHOW_IN_SALE = 1
	
ORDER BY prod.center, prod.globalid
