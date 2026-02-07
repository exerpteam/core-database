SELECT DISTINCT
    s.center                            AS "Sales Center",
    longtodateC(s.trans_time, s.center) AS "Sales Date",
    CASE
        WHEN S.SALES_TYPE = 'INVOICE'
        THEN s.center ||'inv' || s.id
        WHEN S.SALES_TYPE = 'CREDIT_NOTE'
        THEN s.center ||'cred' || s.id
    END                                                            AS "Invoice Td",
    s.text                                                         AS "Sales Product",
    s.PRODUCT_GROUP_NAME                                           AS "Product Group",
    s.QUANTITY                                                     AS "Quantity",
    NVL(s.NET_AMOUNT, s.total_amount)                              AS "NON VAT Amount",
    s.total_amount                                                 AS "Total Sales Amount",
    s.PAYER_CENTER ||'p' || s.PAYER_ID                             AS "Payer ID",
    invp.fullname                                                  AS "Sales Employee Name",
    NVL2(invemp.center, invemp.center || 'emp' || invemp.id, NULL) AS "Sales Employee Id",
    p.fullname                                                     AS "Sold on Behalf Of Name",
    NVL2(emp.center, emp.center|| 'emp' || emp.id, NULL)           AS "Sold on Behalf Of Employee Id"
FROM
    SALES_VW s
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
    s.CENTER IN ($$Scope$$)
    AND s.ENTRY_TIME BETWEEN $$FromDate$$ AND $$ToDate$$
    AND s.product_group_name IN ('H&B',
                                 'H&B Treatments',
                                 'H&B Retail') 