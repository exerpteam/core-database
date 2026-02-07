 -- Parameters: scope(SCOPE)
 SELECT DISTINCT
     CAST(c.center AS VARCHAR)          center,
     CAST(c.id AS VARCHAR)              id,
     CAST(c.subid AS VARCHAR)           subid,
     CAST(c.owner_center AS VARCHAR)    owner_center,
     CAST(c.owner_id AS VARCHAR)        owner_id,
     c.clips_left,
     c.clips_initial,
         CASE cen.COUNTRY WHEN 'SE' THEN CAST(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+coalesce(invl.RATE,0)),2) AS VARCHAR) WHEN 'FI' THEN CAST(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+coalesce(invl.RATE,0)),2) AS VARCHAR) ELSE CAST((invl.TOTAL_AMOUNT / invl.QUANTITY)  AS VARCHAR)
      END price_per_clip_card,
     CASE cen.COUNTRY WHEN 'SE' THEN CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+coalesce(invl.RATE,0)),2) AS VARCHAR) WHEN 'FI' THEN CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+coalesce(invl.RATE,0)),2) AS VARCHAR) ELSE CAST((invls.TOTAL_AMOUNT /
     invls.QUANTITY) AS VARCHAR) END price_per_clip_card_spons,
     CASE invls.PERSON_CENTER || 'p' || invls.PERSON_ID WHEN 'p' THEN NULL ELSE invls.PERSON_CENTER || 'p' || invls.PERSON_ID END                                                                                          pid_spons,
     LongToDate(c.valid_until)                                                                                                                                                                     valid_until,
     p.name,
     p.ptype,
     CASE  WHEN crt.INSTALLMENT_PLAN_ID IS NULL THEN 'No' ELSE 'Yes' END AS "Installment Plan",
     CASE  WHEN insp.id IS NULL THEN '' ELSE insp.person_center ||'p'||insp.person_id END AS "Installment Plan on Person",
     insp.INSTALLEMENTS_COUNT                        AS "Total Installments",
     COALESCE(insp.INSTALLEMENTS_COUNT, 0) - COALESCE(ar_per.ar_trans_count,0) AS "Total Inst. paid",
     COALESCE(ar_per.ar_trans_count,0)                                         AS "Total Inst. unpaid",
     CASE CASE  WHEN crt.INSTALLMENT_PLAN_ID IS NULL THEN 'No' ELSE 'Yes' END
          WHEN 'No' THEN
              0
          WHEN 'Yes' THEN
              ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY),2) - COALESCE(ABS(ar_per.ar_trans_amount), 0)
     END AS "Total Inst. paid amount",
     COALESCE(ABS(ar_per.ar_trans_amount), 0)                     AS "Total Inst. unpaid amount"
 FROM
     CLIPCARDS c
 JOIN
     products p
 ON
     p.center = c.center
     AND p.id = c.id
 LEFT JOIN
     CARD_CLIP_USAGES ccu
 ON
     c.CENTER = ccu.CARD_CENTER
     AND c.id = ccu.CARD_id
     AND c.SUBID = ccu.CARD_SUBID
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
    invoice_lines_mt line) as invl
 ON
     invl.CENTER = c.INVOICELINE_CENTER
     AND invl.ID = c.INVOICELINE_ID
     AND invl.SUBID = c.INVOICELINE_SUBID
 LEFT JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.ID = invl.ID
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
    invoice_lines_mt line) as invls
 ON
     invls.CENTER = inv.SPONSOR_INVOICE_CENTER
     AND invls.ID = inv.SPONSOR_INVOICE_ID
     AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
 LEFT JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     inv.PAYSESSIONID = crt.PAYSESSIONID
     AND crt.amount != 0
 LEFT JOIN
     INSTALLMENT_PLANS insp
 ON
     insp.ID = crt.INSTALLMENT_PLAN_ID
 LEFT JOIN
     CENTERS cen
 ON
     cen.id = inv.CENTER
 LEFT JOIN
     (
         SELECT
             art.installment_plan_id,
             COUNT(*)                                AS ar_trans_count,
             SUM(art.UNSETTLED_AMOUNT)               AS ar_trans_amount
         FROM
             account_receivables ar
         LEFT JOIN
             ar_trans art
         ON
             art.center = ar.center
             AND art.id = ar.id
             AND art.amount < 0
             and art.status != 'CLOSED'
             AND art.UNSETTLED_AMOUNT < 0
             AND art.installment_plan_id IS NOT NULL
         WHERE
             ar.ar_type = 6
         GROUP BY
             art.installment_plan_id) ar_per
 ON
     ar_per.installment_plan_id = insp.id
 WHERE
     C.OWNER_CENTER IN ($$scope$$)
     AND ( c.clips_left > 0 or  (COALESCE(ar_per.ar_trans_count,0) >0) )
     and c.cancelled =0
     AND (ccu.TYPE <> 'TRANSFER' or ccu.TYPE is null)
