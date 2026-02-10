-- The extract is extracted from Exerp on 2026-02-08
-- List all payments to Memberservice debt account.
Initially created to find Benify transactions.
Productgroup is given as argument
/**
* List all payments to Memberservice det account.
* Initially created to find Benify transactions.
* Productgroup is given as argument
* Created: 2021-01-04
* Creator: Henrik Håkanson
*/

SELECT 
	p.CENTER || 'p' || p.ID AS MemberId,
	TO_NUMBER(p.SSN) AS SSN,
	p.FULLNAME AS Name,
	il.TOTAL_AMOUNT AS Kostnad,
	il.TEXT AS Text,
	act.NAME AS Konto,
	products.NAME AS Produkt,
	pg.ID AS ProduktGrupp_Id,
	pg.NAME AS ProductGroup_Namn
FROM INVOICELINES il	
JOIN PRODUCTS products
	ON il.PRODUCTCENTER = products.CENTER
	AND il.PRODUCTID = products.ID
JOIN PRODUCT_GROUP pg
	ON pg.ID = products.PRIMARY_PRODUCT_GROUP_ID
JOIN PERSONS p
	ON il.PERSON_CENTER = p.CENTER
	AND il.PERSON_ID = p.ID
JOIN ACCOUNT_TRANS atr
	ON atr.MAIN_TRANSSUBID = il.ACCOUNT_TRANS_SUBID
	AND atr.MAIN_TRANSCENTER =il.ACCOUNT_TRANS_CENTER
JOIN ACCOUNTS act
	ON act.CENTER = atr.DEBIT_ACCOUNTCENTER
	AND act.ID = atr.DEBIT_ACCOUNTID
WHERE 
	act.GLOBALID='-100'
	AND atr.TRANS_TIME >= :FromDate
	AND atr.TRANS_TIME < :ToDate + 3600*1000*24
	AND p.CENTER IN(:scope)
	AND il.TOTAL_AMOUNT > 0
	AND pg.NAME IN (:productGroupName)