-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2136
https://clublead.atlassian.net/browse/EC-6474
WITH
    params AS Materialized
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(($$from_date$$)::DATE,'YYYY-MM-DD' ) || ' 00:00',100) AS BIGINT)
            FROMDATE,
            CAST(dateToLongC(TO_CHAR(($$to_date$$)::DATE,'YYYY-MM-DD' ) || ' 00:00',100) AS BIGINT)
            AS TODATE
    )
    ,
    staff_members AS materialized
    (
        SELECT
            CENTER,
            ID,
            FULLNAME
        FROM
            PERSONS p
        WHERE
            p.PERSONTYPE = 2
        AND p.CENTER IN ($$scope$$)
    )
    ,
    sv AS
    (
        SELECT
            i.sponsor_invoice_center,
            i.sponsor_invoice_id,
            il.sponsor_invoice_subid,
            il.center,
            il.subid AS sub_id,
            il.id,
            'INVOICE' AS sales_type,
            il.text,
            il.quantity,
            ROUND(il.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + il.rate)), 2) AS
            vat_amount,
            ROUND(il.total_amount - il.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC +
            il.rate)), 2)             AS net_amount,
            ROUND(il.total_amount, 2) AS total_amount,
            i.employee_center,
            i.employee_id,
            i.trans_time,
            i.payer_center,
            i.payer_id,
            sm.fullname,
            sm.center AS personcenter,
            sm.id     AS personid,
            prod.COST_PRICE,
            prod.name   AS product_name,
            prod.ptype  AS product_type,
            pgmain.NAME AS product_group_name
        FROM
            params,
            staff_members sm
        JOIN
            (select 
    center,
    id,
    subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    text,
    product_cost,
    product_normal_price,
    total_amount,
    sales_type,
    remove_from_inventory,
    reason,
    sponsor_invoice_subid,
    person_center,
    person_id,
    installment_plan_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    sales_commission,
    sales_units,
    period_commission,
    net_amount, ( 
        select 
            l.account_trans_center
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_center, ( 
        select 
            l.account_trans_subid
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_subid, ( 
        select 
            l.account_trans_id
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_id, ( 
        select 
            l.rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as rate, ( 
        select 
            l.orig_rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as orig_rate
from 
    invoice_lines_mt line ) as il
        ON
            il.person_center = sm.center
        AND il.person_id = sm.id
        JOIN
            invoices i
        ON
            i.center = il.center
        AND i.id = il.id
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = il.PRODUCTCENTER
        AND link.PRODUCT_ID = il.PRODUCTID
        JOIN
            PRODUCTS PROD
        ON
            PROD.ID = il.PRODUCTID
        AND PROD.CENTER = il.PRODUCTCENTER
        JOIN
            PRODUCT_GROUP pgu
        ON
            link.PRODUCT_GROUP_ID = pgu.ID
        LEFT JOIN
            product_group pgmain
        ON
            pgmain.id = prod.primary_product_group_id
        WHERE
            i.TRANS_TIME BETWEEN params.FROMDATE AND params.TODATE
        AND UPPER(pgu.NAME) = UPPER($$product_group$$)
        UNION ALL
        SELECT
            NULL,
            NULL,
            NULL,
            cl.center,
            cl.subid AS sub_id,
            cl.id,
            'CREDIT_NOTE'::text AS sales_type,
            cl.text,
            -cl.quantity AS quantity,
            -ROUND(cl.total_amount - ROUND(cl.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC
            + cl.rate)), 2), 2)                                                       AS net_amount,
            -ROUND(cl.total_amount * (1::NUMERIC - 1::NUMERIC / (1::NUMERIC + cl.rate)), 2) AS
                                          vat_amount,
            -ROUND(cl.total_amount, 2) AS total_amount,
            c.employee_center,
            c.employee_id,
            c.trans_time,
            c.payer_center,
            c.payer_id,
            sm.fullname,
            sm.center AS personcenter,
            sm.id     AS personid,
            prod.COST_PRICE,
            prod.name    AS product_name,
            prod.ptype AS product_type,
            pgmain.NAME  AS product_group_name
        FROM
            params,
            staff_members sm
        JOIN
            (select 
    center,
    id,
    subid,
    invoiceline_center,
    invoiceline_id,
    invoiceline_subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    text,
    credit_type,
    canceltype,
    total_amount,
    product_cost,
    reason,
    person_center,
    person_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    installment_plan_id,
    sales_commission,
    sales_units,
    period_commission,
    net_amount, ( 
        select 
            l.account_trans_center
        from 
            credit_note_line_vat_at_link l
        where 
            l.credit_note_line_center = line.center 
            and l.credit_note_line_id = line.id 
            and l.credit_note_line_subid = line.subid) 
    as vat_acc_trans_center, ( 
        select 
            l.account_trans_subid
        from 
            credit_note_line_vat_at_link l
        where 
            l.credit_note_line_center = line.center 
            and l.credit_note_line_id = line.id 
            and l.credit_note_line_subid = line.subid) 
    as vat_acc_trans_subid, ( 
        select 
            l.account_trans_id
        from 
            credit_note_line_vat_at_link l
        where 
            l.credit_note_line_center = line.center 
            and l.credit_note_line_id = line.id 
            and l.credit_note_line_subid = line.subid) 
    as vat_acc_trans_id, ( 
        select 
            l.rate
        from 
            credit_note_line_vat_at_link l
        where 
            l.credit_note_line_center = line.center 
            and l.credit_note_line_id = line.id 
            and l.credit_note_line_subid = line.subid) 
    as rate, ( 
        select 
            l.orig_rate
        from 
            credit_note_line_vat_at_link l
        where 
            l.credit_note_line_center = line.center 
            and l.credit_note_line_id = line.id 
            and l.credit_note_line_subid = line.subid) 
    as orig_rate
from 
    credit_note_lines_mt line ) as cl
        ON
            cl.person_center = sm.center
        AND cl.person_id = sm.id
        JOIN
            credit_notes c
        ON
            cl.center = c.center
        AND cl.id = c.id
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = cl.PRODUCTCENTER
        AND link.PRODUCT_ID = cl.PRODUCTID
        JOIN
            PRODUCTS PROD
        ON
            PROD.ID = cl.PRODUCTID
        AND PROD.CENTER = cl.PRODUCTCENTER
        JOIN
            PRODUCT_GROUP pgu
        ON
            link.PRODUCT_GROUP_ID = pgu.ID
        LEFT JOIN
            product_group pgmain
        ON
            pgmain.id = prod.primary_product_group_id
        WHERE
            c.TRANS_TIME BETWEEN params.FROMDATE AND params.TODATE
        AND UPPER(pgu.NAME) = UPPER($$product_group$$)
    )
SELECT
    sv.CENTER ,
    C.NAME ,
    sv.ID ,
    sv.SUB_ID ,
    sv.SALES_TYPE ,
    sv.TEXT ,
    sv.EMPLOYEE_CENTER || 'emp' || sv.EMPLOYEE_ID SALES_EMPLOYEE_EMP ,
    pemp.FULLNAME                                 SALES_EMPLOYEE_NAME ,
    longToDateC(sv.TRANS_TIME,sv.CENTER)          TRANS_TIME ,
    sv.PAYER_CENTER || 'p' || sv.PAYER_ID         CUSTOMER_PID ,
    sv.FULLNAME                                   CUSTOMER_NAME ,
    sv.PRODUCT_NAME ,
    CASE sv.product_type
        WHEN 1
        THEN 'RETAIL'::text
        WHEN 2
        THEN 'SERVICE'::text
        WHEN 4
        THEN 'CLIPCARD'::text
        WHEN 5
        THEN 'JOINING_FEE'::text
        WHEN 6
        THEN 'TRANSFER_FEE'::text
        WHEN 7
        THEN 'FREEZE_PERIOD'::text
        WHEN 8
        THEN 'GIFTCARD'::text
        WHEN 9
        THEN 'FREE_GIFTCARD'::text
        WHEN 10
        THEN 'SUBS_PERIOD'::text
        WHEN 12
        THEN 'SUBS_PRORATA'::text
        WHEN 13
        THEN 'ADDON'::text
        WHEN 14
        THEN 'ACCESS'::text
        ELSE NULL::text
    END AS product_type,
    sv.COST_PRICE ,
    sv.PRODUCT_GROUP_NAME ,
    sv.QUANTITY ,
    sv.NET_AMOUNT ,
    sv.VAT_AMOUNT ,
    sv.TOTAL_AMOUNT / sv.QUANTITY                               PAID_AMOUNT ,
    invl.PRODUCT_NORMAL_PRICE                                   LIST_PRICE ,
    invl.PRODUCT_NORMAL_PRICE - (sv.TOTAL_AMOUNT / sv.QUANTITY) DISCOUNT ,
    sinvl.TOTAL_AMOUNT                                          SPONSORSHIP_AMOUNT ,
    pg.GRANTER_SERVICE ,
    ps.NAME                privilege_set ,
    prg.NAME               RECEIVER_GROUP_NAME ,
    ca.NAME                COMPANY_AGREEMENT_NAME ,
    mpr.CACHED_PRODUCTNAME SUBSCRIPTION_NAME ,
    sc.NAME                STARTUP_CAMPAIGN_NAME
FROM
    sv
JOIN
    CENTERS C
ON
    sv.CENTER = C.ID
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = sv.EMPLOYEE_CENTER
AND emp.id = sv.EMPLOYEE_ID
JOIN
    PERSONS pemp
ON
    pemp.CENTER = emp.PERSONCENTER
AND pemp.id = emp.PERSONID
LEFT JOIN
    (select 
    center,
    id,
    subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    text,
    product_cost,
    product_normal_price,
    total_amount,
    sales_type,
    remove_from_inventory,
    reason,
    sponsor_invoice_subid,
    person_center,
    person_id,
    installment_plan_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    sales_commission,
    sales_units,
    period_commission,
    net_amount, ( 
        select 
            l.account_trans_center
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_center, ( 
        select 
            l.account_trans_subid
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_subid, ( 
        select 
            l.account_trans_id
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_id, ( 
        select 
            l.rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as rate, ( 
        select 
            l.orig_rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as orig_rate
from 
    invoice_lines_mt line ) as invl
ON
    invl.CENTER = sv.CENTER
AND invl.ID = sv.ID
AND invl.SUBID = sv.SUB_ID
AND sv.SALES_TYPE = 'INVOICE'
LEFT JOIN
    (select 
    center,
    id,
    subid,
    productcenter,
    productid,
    account_trans_center,
    account_trans_id,
    account_trans_subid,
    quantity,
    text,
    product_cost,
    product_normal_price,
    total_amount,
    sales_type,
    remove_from_inventory,
    reason,
    sponsor_invoice_subid,
    person_center,
    person_id,
    installment_plan_id,
    rebooking_acc_trans_center,
    rebooking_acc_trans_id,
    rebooking_acc_trans_subid,
    rebooking_to_center,
    sales_commission,
    sales_units,
    period_commission,
    net_amount, ( 
        select 
            l.account_trans_center
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_center, ( 
        select 
            l.account_trans_subid
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_subid, ( 
        select 
            l.account_trans_id
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as vat_acc_trans_id, ( 
        select 
            l.rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as rate, ( 
        select 
            l.orig_rate
        from 
            invoicelines_vat_at_link l
        where 
            l.invoiceline_center = line.center 
            and l.invoiceline_id = line.id 
            and l.invoiceline_subid = line.subid) 
    as orig_rate
from 
    invoice_lines_mt line) as sinvl
ON
    sinvl.CENTER = sv.SPONSOR_INVOICE_CENTER
AND sinvl.ID = sv.SPONSOR_INVOICE_ID
AND sinvl.SUBID = sv.SPONSOR_INVOICE_SUBID
AND sv.SALES_TYPE = 'INVOICE'
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    sv.SALES_TYPE = 'INVOICE'
AND pu.TARGET_CENTER = sv.CENTER
AND pu.TARGET_ID = sv.ID
AND pu.TARGET_SUBID = sv.SUB_ID
AND pu.TARGET_SERVICE = 'InvoiceLine'
LEFT JOIN
    PRODUCT_PRIVILEGES pp
ON
    pp.ID = pu.PRIVILEGE_ID
AND pu.PRIVILEGE_TYPE = 'PRODUCT'
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
LEFT JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pp.PRIVILEGE_SET
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
AND pg.GRANTER_SERVICE = 'ReceiverGroup'
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = pg.GRANTER_CENTER
AND ca.ID = pg.GRANTER_ID
AND ca.SUBID = pg.GRANTER_SUBID
AND pg.GRANTER_SERVICE = 'CompanyAgreement'
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = pg.GRANTER_ID
AND pg.GRANTER_SERVICE = 'GlobalSubscription'
LEFT JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.id = pg.GRANTER_ID
AND pg.GRANTER_SERVICE = 'StartupCampaign'
ORDER BY
    sv.TRANS_TIME DESC ,
    sv.personcenter ,
    sv.personid