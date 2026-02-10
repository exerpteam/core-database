-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
	ss.owner_center||'p'||ss.owner_id as customer,
--	member.fullname,
    sa.EMPLOYEE_CREATOR_CENTER||'emp'||sa.EMPLOYEE_CREATOR_ID as salesperson,
--	staff.fullname,
    prod.name as addon_product,
  --  REPLACE('' || prod.PRICE, '.', ',')  AS NORMAL_UNIT_PRICE,
    longtodate(sa.creation_time) as sales_date
From
     fw.SUBSCRIPTION_ADDON sa
join fw.masterproductregister m
    on
    sa.addon_product_id = m.id
join fw.subscription_sales ss
    on 
    sa.subscription_center = ss.subscription_center
    and sa.subscription_id= ss.subscription_id
join fw.products prod
    on
    m.globalid = prod.globalid
JOIN fw.invoicelines invl
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
--JOIN employees e
--ON 	
--	e.CENTER = sa.EMPLOYEE_CREATOR_CENTER
--AND	e.ID = sa.EMPLOYEE_CREATOR_ID

--JOIN PERSONS staff
--ON
--	staff.center = e.PERSONCENTER
--AND	staff.id = e.PERSONID

--JOIN PERSONS member
--ON
--	member.center = ss.owner_center
--AND	member.id = ss.owner_id

WHERE
    ss.owner_center in (:scope)
    and sa.creation_time >=  :sale_from_date 
    and sa.creation_time <= :sale_to_date
	and prod.globalid = 'EXTENDED_BCA__ADGANG_'
  --  AND NOT EXISTS
 --   (
 --       SELECT
 --         *
 --       FROM
 --           fw.CREDIT_NOTE_LINES cnl
 --       WHERE
 --           cnl.INVOICELINE_CENTER = invl.CENTER
 --           AND cnl.INVOICELINE_ID = invl.id
 --           AND cnl.INVOICELINE_SUBID = invl.SUBID
 --   )