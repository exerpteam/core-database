select 
	per.center ||'p'|| per.id AS MEMBER_NO,
	prod.name AS PRODUCT,
	TO_CHAR(longtodate(i.entry_time), 'dd.MM.yyyy') SALES_DATE
from products prod 
join invoicelines il on
	prod.center = il.productcenter
	and prod.id = il.productid
join invoices i on
	il.center = i.center
	AND il.id = i.id
join persons per on
	il.person_center = per.center
	and il.person_id = per.id
where 
	per.center = 783 
	and prod.globalid = 'ADMIN_FEE'
	and i.entry_time >= :FromDate 
	and i.entry_time < :ToDate + (1000*60*60*24)