-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	i.CENTER ||' - '|| c.NAME AS Center,
	pr.NAME AS "Produkt navn",
	it.TYPE,
	TO_CHAR(longtodate(it.ENTRY_TIME), 'dd-MM-YYYY HH24:MI') AS "Entry time",
	it.QUANTITY AS Antal,
	it.BALANCE_QUANTITY AS "Lager beholdning",
	it.COMENT AS Produktkommentar,
	it.EMPLOYEE_CENTER ||'emp'|| it.EMPLOYEE_ID ||' - '|| staff.FULLNAME AS Ansat
FROM
	INVENTORY_TRANS it

JOIN
	INVENTORY i
ON
	it.INVENTORY = i.ID

JOIN
	PRODUCTS pr
ON
	it.PRODUCT_CENTER = pr.CENTER
AND	it.PRODUCT_ID = pr.ID

JOIN
	CENTERS c
ON
	i.CENTER = c.ID

JOIN
	EMPLOYEES emp
ON it.EMPLOYEE_CENTER = emp.CENTER
AND it.EMPLOYEE_ID = emp.ID

JOIN
	PERSONS staff
ON
	emp.PERSONCENTER = staff.CENTER
AND	emp.PERSONID = staff.ID

WHERE
	i.CENTER in (:SCOPE)
AND	it.ENTRY_TIME BETWEEN :FROMDATE AND :TODATE

ORDER BY
i.CENTER ||' - '|| c.NAME,
it.ENTRY_TIME
