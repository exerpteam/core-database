-- The extract is extracted from Exerp on 2026-02-08
-- Used to see if a "delbetalning" membership is sold without an friskvårds fee.
 select
 /*PP.CENTER || 'p' || PP.ID as MemberID,
 pp.external_id MemberExternalID,
 --longtodatec(I.TRANS_TIME,C.INVOICELINE_CENTER) Sold_Date,
 TO_DATE('01011970', 'DDMMYYYY') + I.TRANS_TIME/(24*3600*1000) + 1/24 as SalesDate,
 P.NAME as PRODUCT,
 P.PRICE as PRICE,
 E.CENTER || 'emp' || E.ID as SalespersonId,
  CE.NAME as SalespersonCenter,
 CI.NAME as SalesCenter,
 PE.FIRSTNAME || ' ' || PE.LASTNAME as SalespersonName*/
    pp.center||'p'||pp.id "Member ID",
     pp.fullname "Member Name",
     sub.center||'ss'||sub.id "Subcription ID",
     p.name "Subscription Name",
   longtodate(I.TRANS_TIME) as  "Subscription Sales Date",
     p.price "Subscription Price" ,
     sub.start_date "Subscription Start Date" ,
     sub.end_date "Subscription Stop Date" ,
      CE.NAME as SalespersonCenter,
 CI.NAME as SalesCenter,
 PE.FIRSTNAME || ' ' || PE.LASTNAME as SalespersonName,
     r.RELATIVECENTER||'p'||r.RELATIVEID "Connected Company",
  ps.NAME Priviligeset
 from INVOICES I
 join INVOICELINES IL on I.CENTER=IL.CENTER and I.ID=IL.ID
 --join INVOICELINES IL on I.SPONSOR_INVOICE_CENTER=IL.CENTER and I.SPONSOR_INVOICE_ID=IL.ID
 join PRODUCTS P on IL.PRODUCTCENTER=P.CENTER and IL.PRODUCTID=P.ID JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pgl.product_center = p.center AND pgl.product_id = p.id JOIN product_group prg ON prg.id = pgl.product_group_id
 join EMPLOYEES E on I.EMPLOYEE_CENTER=E.CENTER and I.EMPLOYEE_ID=E.ID
 join PERSONS PE on E.PERSONCENTER=PE.CENTER and E.PERSONID=PE.ID
 join CENTERS CE on PE.CENTER=CE.ID
 join subscriptions sub on IL.CENTER=sub.INVOICELINE_CENTER and IL.ID=sub.INVOICELINE_ID and IL.SUBID=sub.INVOICELINE_SUBID
 join PERSONS PP on sub.OWNER_CENTER=PP.CENTER and sub.OWNER_ID=PP.ID
 join CENTERS CP on PP.CENTER=CP.ID
 join CENTERS CI on I.CENTER=CI.ID
 join relatives r ON r.CENTER = sub.owner_center AND r.id = sub.owner_ID AND r.RTYPE IN (3)/*Company agreement*/  AND r.STATUS<3
 join companyagreements ca ON ca.CENTER = r.RELATIVECENTER AND ca.ID = r.RELATIVEID AND ca.SUBID = r.RELATIVESUBID
 JOIN privilege_grants pg ON  pg.GRANTER_CENTER = ca.CENTER AND pg.GRANTER_ID = ca.ID AND pg.GRANTER_SUBID = ca.SUBID  AND pg.GRANTER_SERVICE = 'CompanyAgreement'
 --and   pg.VALID_FROM < dateToLong(TO_CHAR(CAST(CURRENT_DATE+1 AS DATE), 'YYYY-MM-dd HH24:MI'))
     /*AND (
         pg.VALID_TO >=dateToLong(TO_CHAR(CAST(CURRENT_DATE+1 AS DATE), 'YYYY-MM-dd HH24:MI'))
         OR pg.VALID_TO IS NULL)*/
 --JOIN product_privileges ppv ON ppv.PRIVILEGE_SET = pg.PRIVILEGE_SET
    /* AND pp.VALID_FROM < dateToLong(TO_CHAR(CAST(CURRENT_DATE+1 AS DATE), 'YYYY-MM-dd HH24:MI'))
     AND (
         pp.VALID_TO >= dateToLong(TO_CHAR(CAST(CURRENT_DATE+1 AS DATE), 'YYYY-MM-dd HH24:MI'))
         OR pp.VALID_TO IS NULL)*/
    -- AND ppv.REF_GLOBALID = p.GLOBALID
 JOIN  PRIVILEGE_SETS ps ON   PG.PRIVILEGE_SET = ps.ID
 where
  P.PTYPE in (10 ,5) --Subscription, Subscription creation
 --and pg.id in (80,16402) --PT
  and sub.INVOICELINE_CENTER in ($$Invoiced_center$$)
 and ps.PRIVILEGE_SET_GROUPS_ID in (124484) --'Corporate sales, Sweden'
 and I.TRANS_TIME >= $$From_date$$
 and I.TRANS_TIME <= $$To_date$$
  -- and pp.center= 603 and pp.id =41001
   and ca.name like '%delbet%'
 --and ps.name not like '%Sponsor:%'
