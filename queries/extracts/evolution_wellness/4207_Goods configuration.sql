-- The extract is extracted from Exerp on 2026-02-08
--  
WITH pmp_xml AS (
SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM masterproductregister m
)
SELECT
        DISTINCT
                t1.*
FROM
(
        SELECT 
                prod.CENTER,
                c.NAME "center name",
                prod.GLOBALID "Global Name",
                prod.NAME "Product Name",
                pac.NAME "Account Configuration",
                sales_acc.EXTERNAL_ID as "Sales Account",
                r.ROLENAME "Required Role",
                prod.NEEDS_PRIVILEGE "Purchase Require Privilege",
                prod.SHOW_IN_SALE,
                prod.SHOW_ON_WEB,
                mpr.CACHED_PRODUCTPRICE "Top Level Price",
                prod.PRICE "Club Price",
                pg.NAME "sub primary Product Group",
                vat.global_id AS "GST",
				prod.external_id AS "External ID"
        FROM
                PRODUCTS prod
        JOIN
                CENTERS c
                ON c.id = prod.CENTER
        JOIN
                PRODUCT_GROUP pg
                ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        JOIN
                PRODUCT_ACCOUNT_CONFIGURATIONS pac
                ON pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
        LEFT JOIN
                ACCOUNTS sales_acc
                ON sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
                AND sales_acc.CENTER = prod.CENTER
        LEFT JOIN
                account_vat_type_group vat
                ON vat.id = sales_acc.account_vat_type_group_id        
        JOIN
                MASTERPRODUCTREGISTER mpr
                ON mpr.GLOBALID = prod.GLOBALID
        LEFT JOIN
                pmp_xml
                ON mpr.id = pmp_xml.id          
        LEFT JOIN
                ROLES r
                ON r.ID = prod.REQUIREDROLE
        LEFT JOIN
                ADD_ON_PRODUCT_DEFINITION apd
                ON apd.ID = mpr.ID
        LEFT JOIN
                ADD_ON_TO_PRODUCT_GROUP_LINK aopglink
                ON aopglink.ADD_ON_PRODUCT_DEFINITION_ID = apd.ID
        LEFT JOIN
                PRODUCT_GROUP addReqPG
                ON addReqPG.ID = aopglink.PRODUCT_GROUP_ID
        LEFT JOIN
                MASTERPRODUCTREGISTER aoFreezeMPR
                ON aoFreezeMPR.ID = apd.FREEZE_FEE_PRODUCT_ID
        LEFT JOIN
                PRODUCTS aoFreezePROD
                ON aoFreezePROD.CENTER = prod.CENTER
                AND aoFreezePROD.GLOBALID = aoFreezeMPR.GLOBALID
        LEFT JOIN
                SUBSCRIPTION_ADDON_PRODUCT sap
                ON sap.ADDON_PRODUCT_ID = apd.ID
        LEFT JOIN
                MASTERPRODUCTREGISTER aoSubProd
                ON aoSubProd.ID = sap.SUBSCRIPTION_PRODUCT_ID
        LEFT JOIN
                PRIVILEGE_GRANTS pgr
                ON pgr.GRANTER_ID = mpr.ID
                AND pgr.GRANTER_SERVICE = 'Addon'
        LEFT JOIN
                PRIVILEGE_SETS ps
                ON ps.ID = pgr.PRIVILEGE_SET
        LEFT JOIN
                ENTITYIDENTIFIERS e1
                ON mpr.GLOBALID = e1.REF_GLOBALID
                AND e1.SCOPE_TYPE = mpr.SCOPE_TYPE
                AND e1.SCOPE_ID = mpr.SCOPE_ID
                AND e1.IDMETHOD = 1
                AND e1.REF_TYPE = 4
        LEFT JOIN
                subscriptiontypes st
                ON st.center = prod.center
                AND st.id = prod.id
        LEFT JOIN
                privilege_grants prs
                ON prs.granter_id = mpr.id
                AND (prs.granter_service = 'GlobalSubscription' or prs.granter_service = 'GlobalCard')
		AND prs.valid_to is null
        LEFT JOIN
                PRIVILEGE_SETS pss
                ON pss.ID = prs.PRIVILEGE_SET        
        WHERE
                mpr.ID = mpr.DEFINITION_KEY
                AND prod.PTYPE in (1)
                AND prod.CENTER != 1
				AND prod.blocked IS FALSE
) t1