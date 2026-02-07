select 
PP.CENTER || 'p' || PP.ID as MemberID, 
pp.external_id MemberExternalID,
--longtodatec(I.TRANS_TIME,C.INVOICELINE_CENTER) Sold_Date, 
TO_DATE('01011970', 'DDMMYYYY') + I.TRANS_TIME/(24*3600*1000) + 1/24 as SalesDate,
P.NAME as PRODUCT, 
P.PRICE as PRICE,
E.CENTER || 'emp' || E.ID as SalespersonId, 
 CE.NAME as SalespersonCenter,
CI.NAME as SalesCenter, 
PE.FIRSTNAME || ' ' || PE.LASTNAME as SalespersonName
from INVOICES I 
join INVOICELINES IL on I.CENTER=IL.CENTER and I.ID=IL.ID 
--join INVOICELINES IL on I.SPONSOR_INVOICE_CENTER=IL.CENTER and I.SPONSOR_INVOICE_ID=IL.ID 
join PRODUCTS P on IL.PRODUCTCENTER=P.CENTER and IL.PRODUCTID=P.ID JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pgl.product_center = p.center AND pgl.product_id = p.id JOIN product_group pg ON pg.id = pgl.product_group_id
join EMPLOYEES E on I.EMPLOYEE_CENTER=E.CENTER and I.EMPLOYEE_ID=E.ID
join PERSONS PE on E.PERSONCENTER=PE.CENTER and E.PERSONID=PE.ID
join CENTERS CE on PE.CENTER=CE.ID
join CLIPCARDS C on IL.CENTER=C.INVOICELINE_CENTER and IL.ID=C.INVOICELINE_ID and IL.SUBID=C.INVOICELINE_SUBID
join PERSONS PP on C.OWNER_CENTER=PP.CENTER and C.OWNER_ID=PP.ID
join CENTERS CP on PP.CENTER=CP.ID
join CENTERS CI on I.CENTER=CI.ID
join relatives r ON r.CENTER = c.owner_center AND r.id = c.owner_ID AND r.RTYPE IN (3)/*Company agreement*/  AND r.STATUS<3
join companyagreements ca ON ca.CENTER = r.RELATIVECENTER AND ca.ID = r.RELATIVEID AND ca.SUBID = r.RELATIVESUBID
JOIN privilege_grants pg ON  pg.GRANTER_CENTER = ca.CENTER AND pg.GRANTER_ID = ca.ID AND pg.GRANTER_SUBID = ca.SUBID  AND pg.GRANTER_SERVICE = 'CompanyAgreement' 
JOIN  PRIVILEGE_SETS ps ON   PG.PRIVILEGE_SET = ps.ID
where

 P.PTYPE=4  --Clipcard
and p.globalid not in ('PTSTARTNEW')
--and pg.id in (80,16402) --PT
and pg.id in (80) --PT
and C.INVOICELINE_CENTER in ($$Invoiced_center$$)
and I.TRANS_TIME >= datetolongC(TO_CHAR($$sales_from_date$$, 'YYYY-MM-DD HH24:MI'), I.center) 
and I.TRANS_TIME <= datetolongC(TO_CHAR($$sales_to_date$$, 'YYYY-MM-DD HH24:MI'),  I.center) + 24*60*60*1000
 and ca.name in ('pt faktura' , 'PT faktura')
