WITH params AS MATERIALIZED
(
        SELECT
                dateToLongC(TO_CHAR(TO_DATE(:FromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS from_date,
                dateToLongC(TO_CHAR(TO_DATE(:ToDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 AS to_date,
                c.id AS center_id
        FROM centers c
        WHERE
                c.id IN (:Scope)
)
,
clip_usage_mat AS
(
        SELECT
                cc.center,
                cc.id,
                cc.subid,
                cc.invoiceline_center,
                cc.invoiceline_id,
                cc.invoiceline_subid,
                cc.owner_center,
                cc.owner_id,
                cc.clips_initial,
                cc.clips_left,
                cc.valid_until,
                cc.cancellation_time AS cancellation_date,
                inv.trans_time AS purchase_date,
                -SUM(ccu.clips) AS used_clips
        FROM chelseapiers.clipcards cc
        JOIN params par
                ON par.center_id = cc.center
        JOIN chelseapiers.invoices inv
                ON cc.invoiceline_center = inv.center
                AND cc.invoiceline_id = inv.id
        LEFT JOIN chelseapiers.card_clip_usages ccu
                ON ccu.card_center = cc.center
                AND ccu.card_id = cc.id
                AND ccu.card_subid = cc.subid
                AND ccu.state = 'ACTIVE'
        WHERE
                inv.trans_time between par.from_date AND par.to_date
        GROUP BY
                cc.center,
                cc.id,
                cc.subid,
                cc.invoiceline_center,
                cc.invoiceline_id,
                cc.invoiceline_subid,
                cc.owner_center,
                cc.owner_id,
                cc.clips_initial,
                cc.valid_until,
                inv.trans_time,
                inv.center
)
SELECT
    cc.center                                        AS "Center",
    cent.name                                        AS "Center Name",
    cc.center || 'cc' || cc.id || 'id' || cc.subid   AS "Clipcard",
    p.fullname                                       AS "Person Name",
    p.center || 'p' || p.id                          AS "Person ID",
    p.external_id                                    AS "Person External ID",
    CASE
        WHEN p.STATUS = 0 THEN 'LEAD'
        WHEN p.STATUS = 1 THEN 'ACTIVE'
        WHEN p.STATUS = 2 THEN 'INACTIVE'
        WHEN p.STATUS = 3 THEN 'FREEZE'
        WHEN p.STATUS = 4 THEN 'TRANSFERRED'
        WHEN p.STATUS = 5 THEN 'DUPLICATE'
        WHEN p.STATUS = 6 THEN 'PROSPECT'
        WHEN p.STATUS = 7 THEN 'DELETED'
        WHEN p.STATUS = 8 THEN 'ANONYMIZED'
        WHEN p.STATUS = 9 THEN 'CONTACT'
        ELSE 'Undefined'
    END                                              AS "Person Status",
    pgn.name                                         AS "Product Group",
    pr.name                                          AS "Product",
    TO_CHAR(longtodateC(INV.trans_time,INV.center),'MM/DD/YYYY') AS "Sales Date",
    CAST(ROUND(((il.total_amount + COALESCE(il2.total_amount, 0)) / (COALESCE(ilvatl.rate, 0) + 1)),2) as numeric)
                                                                 AS "Amount Excluding VAT",
    CAST(ROUND((il.total_amount + COALESCE(il2.total_amount, 0)),2) as numeric)   AS "Amount Including VAT",
    cc.clips_initial                                             AS "Original Clips",
    COALESCE(used_clips, 0)                                       AS "Used Clips",
    (cc.clips_initial - COALESCE(used_clips, 0))                  AS "Remaining Clips",
    CAST(ROUND((COALESCE(used_clips, 0) * (((il.total_amount + COALESCE(il2.total_amount, 0)) / (COALESCE
    (ilvatl.rate, 0) + 1)) / cc.clips_initial)),2) as numeric)     AS "Used Amount",
   
    CAST(ROUND(LEAST(((cc.CLIPS_INITIAL - COALESCE(used_clips, 0)) * (((il.total_amount + COALESCE
    (il2.total_amount, 0)) / (COALESCE(ilvatl.rate, 0) + 1)) / cc.clips_initial)), (
    (il.total_amount + COALESCE(il2.total_amount, 0)) / (COALESCE(ilvatl.rate, 0) + 1))),2) as numeric) AS "Remaining Amount",
    TO_CHAR(longtodateC(cc.valid_until,cc.center),'MM/DD/YYYY')  AS "Expiration Date",
    sale_acc.external_id                                   AS "Sales Account G/L",
    defrev_acc.external_id                               AS "Remaining Revenue Account G/L"
    ,TO_CHAR(longtodatec(last_clip_used.time, last_clip_used.center),'MM/DD/YYYY HH24:MI') AS "Last Used Time"
    ,TO_CHAR(longtodatec(cc.cancellation_date, cc.center),'MM/DD/YYYY HH24:MI') AS "Cancellation Time"
    ,TO_CHAR(longtodatec(cc.purchase_date, cc.center),'MM/DD/YYYY HH24:MI') AS "Purchase Time"

FROM clip_usage_mat cc
JOIN chelseapiers.centers cent
        ON cent.id = cc.center
JOIN chelseapiers.persons p
        ON cc.owner_center = p.center
        AND cc.owner_id = p.id    
JOIN chelseapiers.invoice_lines_mt il
        ON cc.invoiceline_center = il.center
        AND cc.invoiceline_id = il.id
        AND cc.invoiceline_subid = il.subid
JOIN chelseapiers.invoices inv
        ON il.center = inv.center
        AND il.id = inv.id
JOIN chelseapiers.products pr
        ON il.productcenter = pr.center
        AND il.productid = pr.id
LEFT JOIN chelseapiers.invoicelines_vat_at_link ilvatl
        ON ilvatl.invoiceline_center = il.center
        AND ilvatl.invoiceline_id = il.id
        AND ilvatl.invoiceline_subid = il.subid
INNER JOIN chelseapiers.product_group pgn
        ON PR.primary_product_group_id = pgn.id
LEFT JOIN chelseapiers.product_account_configurations pac
        ON pr.product_account_config_id = pac.id
LEFT JOIN chelseapiers.invoice_lines_mt il2
        ON il2.center = INV.sponsor_invoice_center
        AND il2.id = INV.sponsor_invoice_id
        AND il2.subid = il.sponsor_invoice_subid
LEFT JOIN chelseapiers.accounts sale_acc
        ON sale_acc.globalid = pac.sales_account_globalid
        AND il.center = sale_acc.center
LEFT JOIN chelseapiers.accounts defrev_acc
        ON defrev_acc.globalid = pac.defer_rev_account_globalid
        AND il.center = defrev_acc.center
LEFT JOIN 
(
        SELECT
                cc.center,
                cc.id,
                cc.subid,
                ccu.time,
                rank() over (partition BY ccu.card_center, ccu.card_id, ccu.card_subid ORDER BY ccu.time DESC) AS rnk
        FROM clipcards cc
        JOIN chelseapiers.card_clip_usages ccu
               ON cc.center = ccu.card_center
               AND cc.id = ccu.card_id 
               AND cc.subid = ccu.card_subid
        WHERE   
                ccu.state NOT IN ('CANCELLED')
) last_clip_used 
        ON last_clip_used.rnk = 1
        AND last_clip_used.center = cc.center
        AND last_clip_used.id = cc.id
        AND last_clip_used.subid = cc.subid
