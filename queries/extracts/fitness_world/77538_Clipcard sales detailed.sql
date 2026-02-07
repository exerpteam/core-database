-- This is the version from 2026-02-05
--  
select 
	I.Center, 
	CI.NAME as SALES_CENTER, 
	longtodateC(i.trans_time, i.center) as SALES_DAY,
	P.NAME as PRODUCT, 
	p.globalid as globalid,
	P.PRICE as PRICE,
	e.external_id as Staff_ID,
	pe.External_id AS Emp_ExternalID,
	PP.CENTER || 'p' || PP.ID AS CUSTOMER_ID,
	pp.External_id AS Member_ExternalID

from 
	 INVOICES I 
join INVOICELINES IL on I.CENTER=IL.CENTER and I.ID=IL.ID 
join PRODUCTS P on IL.PRODUCTCENTER=P.CENTER and IL.PRODUCTID=P.ID 
join EMPLOYEES E on I.EMPLOYEE_CENTER=E.CENTER and I.EMPLOYEE_ID=E.ID
join PERSONS PE on E.PERSONCENTER=PE.CENTER and E.PERSONID=PE.ID
join CENTERS CE on PE.CENTER=CE.ID
join CLIPCARDS C on IL.CENTER=C.INVOICELINE_CENTER and IL.ID=C.INVOICELINE_ID and IL.SUBID=C.INVOICELINE_SUBID
join PERSONS PP on C.OWNER_CENTER=PP.CENTER and C.OWNER_ID=PP.ID
join CENTERS CP on PP.CENTER=CP.ID
join CENTERS CI on I.CENTER=CI.ID
where 
	--P.NAME LIKE 'Nørreport'
--p.id = 96159
I.TRANS_TIME>= :From_date
and I.TRANS_TIME< :To_date_exclusive
and I.Center in (:scope)
--and P.price > 500