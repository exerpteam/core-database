-- The extract is extracted from Exerp on 2026-02-08
--  
WITH pmp_xml AS (
SELECT m.id, CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml FROM masterproductregister m
),
priv_sets AS 
(
        SELECT
                t2.granter_id,
                t2.name as list_privset, t2.punishment_name,
                t2.usage_quantity,
                t2.usage_duration_value,
                t2.usage_duration_unit,
                t2.usage_use_at_planning
        FROM
        (
                WITH params AS MATERIALIZED
                (
                        SELECT FLOOR(extract(epoch FROM now())*1000) AS cutDate
                )
                SELECT
                        pg.granter_id,
                        ps.name,
                        pps.name as punishment_name,
                        pg.usage_quantity,
                        pg.usage_duration_value,
                        pg.usage_duration_unit,
                        pg.usage_use_at_planning
                FROM evolutionwellness.privilege_grants pg
                CROSS JOIN params par
                JOIN evolutionwellness.privilege_sets ps ON pg.privilege_set = ps.id
                Left join evolutionwellness.privilege_punishments pps ON pg.punishment = pps.id
                WHERE
                        pg.granter_service = 'GlobalCard'
                        AND
                        (
                                pg.valid_from < par.cutDate
                                AND (pg.valid_to IS NULL OR pg.valid_to > par.cutDate)
                        )
                ORDER BY 2
        ) t2
        GROUP BY
                t2.granter_id, list_privset, punishment_name, t2.usage_quantity, t2.usage_duration_value, t2.usage_duration_unit, t2.usage_use_at_planning
)
SELECT
        DISTINCT
                t1.*
FROM
(
        SELECT DISTINCT
                prod.CENTER,
                c.NAME "center name",
                prod.GLOBALID "Global Name",
                prod.NAME "Product Name",
                pac.NAME "Account Configuration",
                sales_acc.EXTERNAL_ID as "Sales Account",
                prod.NEEDS_PRIVILEGE "Purchase Require Privilege",
                prod.SHOW_IN_SALE,
                prod.SHOW_ON_WEB,
                mpr.CACHED_PRODUCTPRICE "Top Level Price",
                prod.PRICE "Club Price",
                pg.NAME "sub primary Product Group",
                vat.global_id AS "GST",
                ps1.list_privset AS privilege_sets,
                ps1.punishment_name,
                ps1.usage_quantity,
                ps1.usage_duration_value,
                ps1.usage_duration_unit,
                ps1.usage_use_at_planning
        FROM
                PRODUCTS prod
        JOIN
                CENTERS c
                ON c.id = prod.CENTER and c.Country = 'TH'
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
                PRIVILEGE_GRANTS pgr
                ON pgr.GRANTER_ID = mpr.ID
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
        LEFT JOIN priv_sets ps1 
                ON ps1.granter_id = mpr.id      
        WHERE
                mpr.ID = mpr.DEFINITION_KEY
                AND prod.PTYPE in (4)
                AND prod.CENTER != 1
                AND prod.blocked IS FALSE
) t1