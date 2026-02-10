-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct * FROM (
	SELECT
	prod.center AS club_id,
	c.shortname AS center_name,
	prod.name AS product_name,
	mpr.id AS master_product_id,
	prod.price AS override_scope_price,
	CASE st.st_type
		WHEN 0 THEN 'cash'
		WHEN 1 THEN 'EFT'
		ELSE 'UNDEFINED'
		END AS deduction,
	r.rolename AS required_role,	
	prod.show_on_web AS show_on_web,
	prod.needs_privilege AS purchase_require_privilege,
	st.rank AS rank_sub,
	pac.name AS account_configuration,
	sales_acc.external_id AS sales_account,
	mpr.use_contract_template AS contract_template,
	FIRST_VALUE(t.description) OVER (PARTITION BY mpr.DEFINITION_KEY ORDER BY mpr.SCOPE_TYPE desc) contratto,
	STRING_AGG(DISTINCT ps.name, ' ; ') AS privilege_sets
FROM
	subscriptiontypes st
JOIN
	products prod 
 ON 
	prod.center = st.center 
 AND 
	prod.id = st.id 
 AND 
	prod.blocked = 0
JOIN
	masterproductregister mpr
 ON
	mpr.globalid = prod.globalid
JOIN
	centers c
 ON 
	c.id = prod.center 
 AND 
	c.country = 'IT'
LEFT JOIN
     PRODUCTS prod2
 ON
     prod2.CENTER = prod.CENTER
AND 
	prod2.GLOBALID = 'CREATION_' || prod.GLOBALID
LEFT JOIN 
	roles r 
 ON
	r.id = prod2.requiredrole
LEFT JOIN
	privilege_grants pgr
 ON
	pgr.granter_id = mpr.id
 AND
	pgr.granter_service = 'GlobalSubscription'
 AND 
	pgr.valid_to is null
LEFT JOIN 
	privilege_sets ps
 ON
	ps.id = pgr.privilege_set
JOIN 
	product_account_configurations pac 
 ON
	pac.id = prod.product_account_config_id
LEFT JOIN
	accounts sales_acc
 ON
	sales_acc.globalid = pac.sales_account_globalid
 AND
	sales_acc.center = prod.center
LEFT JOIN
	templates t
 ON 
	mpr.contract_template_id = t.id 
GROUP BY 
	prod.center, c.shortname, prod.name, r.rolename, prod.price, st.st_type, prod.show_on_web, 
	prod.needs_privilege, st.rank, pac.name,sales_acc.external_id, 
	mpr.use_contract_template, t.description, mpr.DEFINITION_KEY, mpr.SCOPE_TYPE,mpr.id
)
order by 3, 2  


	