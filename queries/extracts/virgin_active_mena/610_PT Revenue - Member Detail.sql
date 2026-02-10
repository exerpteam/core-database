-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
     params AS
     (
             SELECT
             /*+ materialize */
             $$FromDate$$ AS FROMDATE,
             $$ToDate$$ + (1000*60*60*24) AS TODATE
     )
 SELECT
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID MEMBER_ID,
     pu.FULLNAME MEMBER_NAME,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID payer_id,
     pp.FULLNAME PAYER_NAME,
     TO_CHAR(longToDate(sales.TRANS_TIME), 'YYYY-MM-DD HH24:MI') transaction_time,
     sales.SALES_TYPE,
     cMember.SHORTNAME HOME_CENTRE,
     CASE
         WHEN cRebook.SHORTNAME IS NOT NULL
         THEN cRebook.SHORTNAME
         ELSE cSales.SHORTNAME
     END PT_CENTRE,
     prod.NAME,
     subs.rec_clipcard_clips,
     sales.PRODUCT_GROUP_NAME,
     sales.PRODUCT_TYPE,
     ROUND( SUM(sales.NET_AMOUNT), 2) revenue_excl_vat,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) vat_included,
     ROUND( SUM(sales.TOTAL_AMOUNT), 2 ) total_amount,
     SUM(sales.QUANTITY) quantity,
     debit.EXTERNAL_ID debit,
     credit.EXTERNAL_ID credit,
         pu.LAST_ACTIVE_START_DATE
 FROM
     (
select 
    il.center,
    il.id,
    il.subid        as sub_id,
    'INVOICE'::text as sales_type,
    il.text,
    il.person_center,
    il.person_id,
    i.employee_center,
    i.employee_id,
    i.entry_time,
    i.trans_time,
    i.cashregister_center,
    i.cashregister_id,
    i.paysessionid,
    i.payer_center,
    i.payer_id,
    prod.center as product_center,
    prod.id     as product_id,
    prod.name   as product_name,
    case prod.ptype
        when 1 
        then 'RETAIL'::text
        when 2 
        then 'SERVICE'::text
        when 4 
        then 'CLIPCARD'::text
        when 5 
        then 'JOINING_FEE'::text
        when 6 
        then 'TRANSFER_FEE'::text
        when 7 
        then 'FREEZE_PERIOD'::text
        when 8 
        then 'GIFTCARD'::text
        when 9 
        then 'FREE_GIFTCARD'::text
        when 10 
        then 'SUBS_PERIOD'::text
        when 12 
        then 'SUBS_PRORATA'::text
        when 13 
        then 'ADDON'::text
        when 14 
        then 'ACCESS'::text
        else null::    text
    end     as product_type,
    pg.name as product_group_name,
    il.quantity,
    round(il.total_amount - il.total_amount * (1::numeric - 1::numeric / (1::numeric + il.rate)), 2 
    )                                                                              as net_amount,
    round(il.total_amount * (1::numeric - 1::numeric / (1::numeric + il.rate)), 2) as vat_amount,
    round(il.total_amount, 2)                                                      as total_amount,
    il.account_trans_center,
    il.account_trans_id,
    il.account_trans_subid,
    il.rebooking_acc_trans_center,
    il.rebooking_acc_trans_id,
    il.rebooking_acc_trans_subid,
    il.rebooking_to_center,
    i.sponsor_invoice_center,
    i.sponsor_invoice_id,
    il.sponsor_invoice_subid
from 
    (
    select 
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
    invoice_lines_mt line
    ) il
    join 
        invoices i on il.center = i.center and il.id = i.id
    join 
        products prod on prod.center = il.productcenter and prod.id = il.productid
    left join 
        product_group pg on pg.id = prod.primary_product_group_id
 
union all
 
select 
    cl.center,
    cl.id,
    cl.subid            as sub_id,
    'CREDIT_NOTE'::text as sales_type,
    cl.text,
    cl.person_center,
    cl.person_id,
    c.employee_center,
    c.employee_id,
    c.entry_time,
    c.trans_time,
    c.cashregister_center,
    c.cashregister_id,
    c.paysessionid,
    c.payer_center,
    c.payer_id,
    prod.center as product_center,
    prod.id     as product_id,
    prod.name   as product_name,
    case prod.ptype
        when 1 
        then 'RETAIL'::text
        when 2 
        then 'SERVICE'::text
        when 4 
        then 'CLIPCARD'::text
        when 5 
        then 'JOINING_FEE'::text
        when 6 
        then 'TRANSFER_FEE'::text
        when 7 
        then 'FREEZE_PERIOD'::text
        when 8 
        then 'GIFTCARD'::text
        when 9 
        then 'FREE_GIFTCARD'::text
        when 10 
        then 'SUBS_PERIOD'::text
        when 12 
        then 'SUBS_PRORATA'::text
        when 13 
        then 'ADDON'::text
        when 14 
        then 'ACCESS'::text
        else null::    text
    end           as product_type,
    pg.name       as product_group_name,
    - cl.quantity as quantity,
    - round(cl.total_amount - round(cl.total_amount * (1::numeric - 1::numeric / (1::numeric + 
    cl.rate)), 2), 2)                                                                as net_amount,
    - round(cl.total_amount * (1::numeric - 1::numeric / (1::numeric + cl.rate)), 2) as vat_amount,
    - round(cl.total_amount, 2)                                                      as 
    total_amount,
    cl.account_trans_center,
    cl.account_trans_id,
    cl.account_trans_subid,
    cl.rebooking_acc_trans_center,
    cl.rebooking_acc_trans_id,
    cl.rebooking_acc_trans_subid,
    cl.rebooking_to_center,
    null::integer as sponsor_invoice_center,
    null::integer as sponsor_invoice_id,
    null::integer as sponsor_invoice_subid
from 
    credit_notes c
    join 
        (
        select 
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
    credit_note_lines_mt line 
        ) cl on cl.center = c.center and cl.id = c.id
    join 
        products prod on prod.center = cl.productcenter and prod.id = cl.productid
    left join 
        product_group pg on pg.id = prod.primary_product_group_id
) sales
 CROSS JOIN
     PARAMS
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = sales.PRODUCT_CENTER
     AND prod.ID = sales.PRODUCT_ID
 JOIN
     CENTERS cMember
 ON
     cMember.ID = sales.PERSON_CENTER
 JOIN
     CENTERS cSales
 ON
     cSales.ID = sales.ACCOUNT_TRANS_CENTER
 JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = sales.ACCOUNT_TRANS_CENTER
     AND act.ID = sales.ACCOUNT_TRANS_ID
     AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
 JOIN
     ACCOUNTS debit
 ON
     debit.CENTER = act.DEBIT_ACCOUNTCENTER
     AND debit.ID = act.DEBIT_ACCOUNTID
 JOIN
     ACCOUNTS credit
 ON
     credit.CENTER = act.CREDIT_ACCOUNTCENTER
     AND credit.ID = act.CREDIT_ACCOUNTID
 LEFT JOIN
     CENTERS cRebook
 ON
     cRebook.ID = sales.REBOOKING_TO_CENTER
 LEFT JOIN
     PERSONS pp
 ON
     pp.CENTER = sales.PAYER_CENTER
     AND pp.id = sales.PAYER_ID
 LEFT JOIN
     PERSONS pu
 ON
     pu.CENTER = sales.PERSON_CENTER
     AND pu.id = sales.PERSON_ID
LEFT JOIN
            SPP_INVOICELINES_LINK spil
        ON
            spil.INVOICELINE_CENTER = sales.CENTER
            AND spil.INVOICELINE_ID = sales.ID
            AND spil.INVOICELINE_SUBID = sales.SUB_ID
            AND sales.SALES_TYPE = 'INVOICE'
        LEFT JOIN
            SUBSCRIPTIONS subs
        ON
            subs.CENTER = spil.PERIOD_CENTER
            AND subs.ID = spil.PERIOD_ID
            and subs.rec_clipcard_clips is not null

 WHERE
     sales.TRANS_TIME >= PARAMS.FROMDATE
     AND sales.TRANS_TIME < PARAMS.TODATE
     AND ( (
             sales.REBOOKING_TO_CENTER IS NULL
             AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
         OR (
             sales.REBOOKING_TO_CENTER IS NOT NULL
             AND sales.REBOOKING_TO_CENTER IN ($$scope$$)))
     AND (
         debit.EXTERNAL_ID IN ('12000100')
         OR credit.EXTERNAL_ID IN ('12000100') )
 GROUP BY
 pu.LAST_ACTIVE_START_DATE,
     cMember.SHORTNAME ,
     cRebook.SHORTNAME,
     cSales.SHORTNAME ,
     prod.NAME ,
     pp.FULLNAME,
     pu.FULLNAME,
     sales.PRODUCT_TYPE,
     sales.PRODUCT_GROUP_NAME,
     sales.SALES_TYPE,
     sales.PAYER_CENTER || 'p' || sales.PAYER_ID ,
     sales.PERSON_CENTER || 'p' || sales.PERSON_ID ,
     longToDate(sales.TRANS_TIME),
     debit.EXTERNAL_ID ,
     credit.EXTERNAL_ID,
     subs.rec_clipcard_clips 