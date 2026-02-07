select
 distinct pp.center||'p'||pp.id "Member ID",
    pp.fullname "Member Name",
      p.name "Product sold",
   TO_DATE('01011970', 'DDMMYYYY') + I.TRANS_TIME/(24*3600*1000) + 1/24 as  "Product Sales Date",
    p.price "Product Price" ,
        CE.NAME as SalespersonCenter,
CI.NAME as SalesCenter, 
PE.FIRSTNAME || ' ' || PE.LASTNAME as SalespersonName,
    r.RELATIVECENTER||'p'||r.RELATIVEID "Connected Company"
 ,ps.NAME Priviligeset
from INVOICES I 
join INVOICELINES il   on I.CENTER=IL.CENTER and I.ID=IL.ID 
join PRODUCTS P on IL.PRODUCTCENTER=P.CENTER and IL.PRODUCTID=P.ID JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pgl.product_center = p.center AND pgl.product_id = p.id JOIN product_group pg ON pg.id = pgl.product_group_id
join EMPLOYEES E on I.EMPLOYEE_CENTER=E.CENTER and I.EMPLOYEE_ID=E.ID
join PERSONS PE on E.PERSONCENTER=PE.CENTER and E.PERSONID=PE.ID
join CENTERS CE on PE.CENTER=CE.ID
join PERSONS PP on i.payer_CENTER=PP.CENTER and i.payer_ID=PP.ID
join CENTERS CP on PP.CENTER=CP.ID
join CENTERS CI on I.CENTER=CI.ID
join relatives r ON r.CENTER = pp.center AND r.id = pp.id AND r.RTYPE IN (3)/*Company agreement*/  AND r.STATUS<3
join companyagreements ca ON ca.CENTER = r.RELATIVECENTER AND ca.ID = r.RELATIVEID AND ca.SUBID = r.RELATIVESUBID
JOIN privilege_grants pg ON  pg.GRANTER_CENTER = ca.CENTER AND pg.GRANTER_ID = ca.ID AND pg.GRANTER_SUBID = ca.SUBID  AND pg.GRANTER_SERVICE = 'CompanyAgreement' 
 and   pg.VALID_FROM < dateToLong(TO_CHAR(CAST(CURRENT_DATE+1 AS DATE), 'YYYY-MM-dd HH24:MI'))

JOIN  PRIVILEGE_SETS ps ON   PG.PRIVILEGE_SET = ps.ID
where

 P.PTYPE in (10 ,5,2) --Subscription, Subscription creation, SERVICE
--and pg.id in (80,16402) --PT
 and I.CENTER in ($$center$$) 
and ps.PRIVILEGE_SET_GROUPS_ID in (124484) --'Corporate sales, Sweden'
and I.TRANS_TIME >= $$From_date$$
and I.TRANS_TIME <= $$To_date$$
 -- and pp.center= 603 and pp.id =41001
  and ca.name like '%delbet%'
ORDER BY pp.center||'p'||pp.id