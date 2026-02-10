-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    s.center                                                       AS "Sales Center",
	longtodateC(s.trans_time, s.center)                    AS "Sales Date",
    s.center ||'inv' || s.id                                       AS "Invoice Td",
    s.text                                                         AS "Sales Product",
    s.PRODUCT_GROUP_NAME                                           as "Product Group",
   s.QUANTITY                                                      as "Quantity",     
NVL(s.NET_AMOUNT, s.total_amount)                               as "NON VAT Amount",
   s.total_amount                                             AS "Total Sales Amount",
   s.PAYER_CENTER ||'p' || s.PAYER_ID                                  as "Payer ID",   
 -- NVL2(invp.center, invp.center || 'p' || invp.id, NULL)         AS "Sales Person Id",
    -- invp.external_id                                               AS "Sales ExternalId",
    invp.fullname                                                  AS "Sales Employee Name",
    NVL2(invemp.center, invemp.center || 'emp' || invemp.id, NULL) AS "Sales Employee Id",
    -- NVL2(p.center, p.center || 'p' || p.id, NULL)                  AS "Sold on Behalf Of PID",
    -- p.external_id                                                  AS "Sold on Behalf Of ExternalId",
    p.fullname                                                     AS "Sold on Behalf Of Name",
    NVL2(emp.center, emp.center|| 'emp' || emp.id, NULL)           AS "Sold on Behalf Of Employee Id"

FROM
    SALES_VW S
LEFT JOIN
    invoice_sales_employee ise
ON
    s.center = ise.invoice_center
AND s.id = ise.invoice_id
LEFT JOIN
    employees emp
ON
    emp.center = ise.sales_employee_center
AND emp.id = ise.sales_employee_id
LEFT JOIN
    persons p
ON
    p.center = emp.personcenter
AND p.id = emp.personid
LEFT JOIN
    employees invemp
ON
    invemp.center = s.employee_center
AND invemp.id = s.employee_id
LEFT JOIN
    persons invp
ON
    invp.center = invemp.personcenter
AND invp.id = invemp.personid
WHERE
    S.CENTER IN ($$Scope$$)
AND S.ENTRY_TIME BETWEEN $$FromDate$$ AND $$ToDate$$
AND S.SALES_TYPE = 'INVOICE'
AND s.product_group_name IN ('H&B','H&B Treatments', 'H&B Retail')