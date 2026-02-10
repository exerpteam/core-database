-- The extract is extracted from Exerp on 2026-02-08
-- Companies with or without an agreement or members. Includes Suppliers are filtered out
select
    com.lastname as company_name,     

--count(distinct(p.center||'p'||p.id)) as customer_count--
  com.center||'p'||com.id as company_id,
    com.center as Comany_center,
	sup.external_id AS "SupplierExId",
	sup.active
	
FROM
	PERSONS com
LEFT JOIN
	supplier sup
ON com.center||'p'||com.id = sup.center||'p'||sup.id

WHERE
    com.sex = 'C'
	and com.status NOT IN (7,8)
	and sup.external_id IS NULL
    and com.center in (:scope)
group by
    com.lastname,
    com.center,
    com.id,
	sup.center,
	sup.active,
	sup.id,
	sup.external_id
ORDER BY
	com.lastname,
	com.center

    