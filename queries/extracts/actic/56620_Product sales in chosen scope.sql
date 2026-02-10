-- The extract is extracted from Exerp on 2026-02-08
-- List sold products by producttype and scope.
Usage: Identify sold products outside cashregister as well.
Creator: Henrik Håkanson
/**
* List sold products by producttype and scope.
* Usage: Identify sold products outside cashregister as well.
* Creator: Henrik Håkanson
*/
SELECT 
	p.CENTER||'p'||p.ID AS MEMBERID,
	p.FULLNAME AS FULLNAME,
	products.NAME AS PRORUCT,
	emp.CENTER||'emp'||emp.ID AS EMPLOYEE_ID,
	emp_person.CENTER||'p'||emp_person.ID AS EMPLOYEE_PERSONID,
	emp_person.FULLNAME AS EMPLOYEE,
	TO_CHAR(LONGTODATE(i.ENTRY_TIME), 'YYYY-MM-DD HH24:MI') AS ENTRY_TIME,
	il.TOTAL_AMOUNT AS SALES_PRICE,
	i.CASHREGISTER_CENTER AS CASHREGISTER_CENTER,
	i.CASHREGISTER_ID AS CASHREGISTER_ID,
	CASE
		WHEN products.PTYPE = 1 THEN 'RETAIL'
		WHEN products.PTYPE = 2 THEN 'SERVICE'
		WHEN products.PTYPE = 4 THEN 'CLIPCARD'
		WHEN products.PTYPE = 5 THEN 'JOINING FEE'
		WHEN products.PTYPE = 8 THEN 'GIFTCARD'
		WHEN products.PTYPE = 10 THEN 'SUBSCRIPTION'
		ELSE 'UNKNOWN'
	END
	AS PRODUCT_TYPE
FROM
	INVOICES i -- receipt with possible multiple lines/product
JOIN INVOICELINES il -- all lines/product in a receipt
	ON il.CENTER = i.CENTER
	AND il.ID = i.ID
JOIN EMPLOYEES emp
	ON i.EMPLOYEE_CENTER=emp.CENTER
	AND i.EMPLOYEE_ID=emp.ID
JOIN PRODUCTS products
	ON il.PRODUCTCENTER = products.CENTER
	AND il.PRODUCTID = products.ID
JOIN PERSONS p
	ON il.PERSON_CENTER = p.CENTER
	AND il.PERSON_ID = p.ID
JOIN PERSONS emp_person
	ON emp.PERSONCENTER=emp_person.CENTER
	AND emp.PERSONID=emp_person.ID
WHERE 
	products.PTYPE IN (:product_type)
	AND TRUNC(i.ENTRY_TIME) > :startDate
	AND TRUNC(i.ENTRY_TIME) <= :endDate + 3600 * 1000 * 24
	AND il.CENTER IN (:center)