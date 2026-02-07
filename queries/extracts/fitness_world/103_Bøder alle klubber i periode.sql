-- This is the version from 2026-02-05
--  
select 
	inv.center klub, 
	count(*) antal, 
	sum("TOTAL_AMOUNT") total
from 
	fw.INVOICELINES invLine
join fw.INVOICES inv 
	on 
	inv.CENTER = invLine.CENTER 
	and inv.ID = invLine.ID
join fw.PRODUCTS prod 
	on 
	invLine.PRODUCTCENTER = prod.center 
	and invLine.PRODUCTID = prod.id
where 
    prod.GLOBALID = 'NO_SHOW_FEE'
    and INV.TRANS_TIME>=:From_date
    and INV.TRANS_TIME<:To_date
group by 
	inv.center
order by 
	inv.center