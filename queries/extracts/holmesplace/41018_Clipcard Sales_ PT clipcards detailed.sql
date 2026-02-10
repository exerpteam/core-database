-- The extract is extracted from Exerp on 2026-02-08
-- With Clipcard ID, clips left, expiry date, if finished (Verdadero), if not finished (Falso)
-- Parameters: FromDate(LONG_DATE),ToDateExclusive(LONG_DATE),Scope(SCOPE)
SELECT
c.shortname
AS CLUB,
    invoice.CENTER || 'inv' || invoice.ID                                                                                                         AS INVOICEID,
    salesPersonCenter.NAME                                                                                                                        AS SALESPERSON_CENTER,
        CASE
        WHEN salesPerson.CENTER IS NOT NULL
        THEN salesPerson.CENTER || 'p' || salesPerson.ID
        ELSE NULL
    END AS SALESPERSON_ID,
    CASE
        WHEN salesPerson.FIRSTNAME IS NOT NULL
        THEN salesPerson.FIRSTNAME || ' ' || salesPerson.LASTNAME
        ELSE NULL
    END                                                               AS SALESPERSON,
    invoiceCenter.NAME                                                                                                                            AS SALES_CENTER,
        TO_DATE('01011970', 'DDMMYYYY') + interval '1 day' * ( invoice.TRANS_TIME/(24*3600*1000) + 1/24) AS SALES_DAY,
    customer.CENTER || 'p' || customer.ID                                                                                                         AS CUSTOMER_ID,
    customer.FIRSTNAME || ' ' || customer.LASTNAME                                                                                                AS CUSTOMER,
	
	
	
	CASE customer.persontype
        WHEN 0 THEN 'Private'
        WHEN 1 THEN 'Student'
        WHEN 2 THEN 'Staff'
        WHEN 3 THEN 'Friend'
        WHEN 4 THEN 'Corporate'
        WHEN 5 THEN 'One-Man Corp'
        WHEN 6 THEN 'Family'
        WHEN 7 THEN 'Senior'
        WHEN 8 THEN 'Guest'
        WHEN 9 THEN 'Child'
        WHEN 10 THEN 'External_Staff'
        ELSE 'Unknown'
    END AS CUSTOMER_TYPE,
	
   CASE customer.status
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'Temporary Inactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS CUSTOMER_STATUS,

	ROUND(((current_date - customer.birthdate)/360),0)                                                                                                 AS age,
    assignStaff.fullname                                                                                                                          AS "Assigned Staff",
    CASE
        WHEN pdrc.center IS NULL
        THEN prod.NAME
        ELSE pdrc.NAME
    END AS CLIPCARDPRODUCT,
    CASE
        WHEN pdrc.center IS NULL
        THEN NULL
        ELSE prod.NAME
    END AS SUBSCRIPTIONPRODUCT,
    CASE
        WHEN prodgrc.id IS NULL
        THEN prodg.NAME
        ELSE prodgrc.NAME
    END AS CLIPCARDPRODUCTGROUP,
    CASE
        WHEN prodgrc.id IS NULL
        THEN NULL
        ELSE prodg.NAME
    END              AS SUBSCRIPTIONPRODUCTGROUP,
    cc.clips_initial AS "Sold Clips",
        invoiceLine.QUANTITY "QUANTITY",
    invoiceLine.PRODUCT_NORMAL_PRICE "PRODUCT_NORMAL_PRICE",
    invoiceLine.TOTAL_AMOUNT "TOTAL_AMOUNT",
	CASE
        WHEN cc.center IS NOT NULL
        THEN cc.center||'cc'||cc.id||'cc'||cc.subid
        ELSE NULL
    END AS "Clipcard ID",
	cc.clips_left AS "ClipsLeft",
	longToDate(cc.valid_until) AS "Expiredate",
	cc.finished AS "Finished"
	

    
FROM
    INVOICES invoice
JOIN
    INVOICELINES invoiceLine
ON
    invoice.CENTER=invoiceLine.CENTER
    AND invoice.ID=invoiceLine.ID
JOIN
    PRODUCTS prod
ON
    invoiceLine.PRODUCTCENTER=prod.CENTER
    AND invoiceLine.PRODUCTID=prod.ID
JOIN
    product_group prodg
ON
    prodg.id = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN
    CENTERS invoiceCenter
ON
    invoice.CENTER=invoiceCenter.ID
JOIN
     HP.centers c
ON
  c.id = invoiceCenter.ID
JOIN
    CLIPCARDS cc
ON
    invoiceLine.CENTER = cc.INVOICELINE_CENTER
    AND invoiceLine.ID = cc.INVOICELINE_ID
    AND invoiceLine.SUBID = cc.INVOICELINE_SUBID
LEFT JOIN
    EMPLOYEES employee
ON
    invoice.EMPLOYEE_CENTER=employee.CENTER
    AND invoice.EMPLOYEE_ID=employee.ID
LEFT JOIN
    PERSONS salesPerson
ON
    employee.PERSONCENTER=salesPerson.CENTER
    AND employee.PERSONID=salesPerson.ID
LEFT JOIN
    CENTERS salesPersonCenter
ON
    salesPerson.CENTER=salesPersonCenter.ID
LEFT JOIN
    persons assignStaff
ON
    assignStaff.center = cc.assigned_staff_center
    AND assignStaff.id = cc.assigned_staff_id
LEFT JOIN
    PERSONS customer
ON
    invoiceLine.person_CENTER=customer.CENTER
    AND invoiceLine.person_ID=customer.ID
LEFT JOIN
    spp_invoicelines_link link
ON
    link.invoiceline_center = invoiceLine.CENTER
    AND link.invoiceline_id = invoiceLine.ID
    AND link.invoiceline_subid = invoiceLine.subid
LEFT JOIN
    subscriptionperiodparts spp
ON
    link.period_center = spp.center
    AND link.period_id = spp.id
    AND link.period_subid = spp.subid
LEFT JOIN
    subscriptions s
ON
    spp.center = s.center
    AND spp.id = s.id
LEFT JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND st.st_type = 2
LEFT JOIN
    products pdrc
ON
    pdrc.center = st.rec_clipcard_product_center
    AND pdrc.id = st.rec_clipcard_product_id
LEFT JOIN
    product_group prodgrc
ON
    prodgrc.id = pdrc.PRIMARY_PRODUCT_GROUP_ID
WHERE
    invoice.CENTER IN (:Scope)
    AND invoice.TRANS_TIME>= :FromDate
    AND invoice.TRANS_TIME<:ToDateExclusive
    AND (
        prodg.name IN ('PT Clipcards','GYM Income','Starter Packs/Bundles')
        OR prodgrc.name IN ('PT Clipcards','GYM Income','Starter Packs/Bundles'))