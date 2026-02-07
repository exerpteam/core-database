WITH
    params AS
    (
        SELECT
            /*+ materialize */
            exerpro.datetolong(to_char(to_date('2016-01-11', 'YYYY-MM-DD'), 'YYYY-MM-DD HH24:MI')) + (1000*60*60*24) AS TODATE
        FROM
            dual
    )
SELECT DISTINCT
    TO_CHAR(c.center)          center,
    TO_CHAR(c.id)              id,
    TO_CHAR(c.subid)           subid,
    TO_CHAR(c.owner_center)    owner_center,
    TO_CHAR(c.owner_id)        owner_id,
    pea_oldid.txtvalue      AS OLD_MEMBERNUMBER,
    c.clips_initial -   NVL(clip_usage.clip_used,0) clips_left,
    c.clips_initial,
    DECODE(cen.COUNTRY,'SE',TO_CHAR(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/1.06,2)),'FI',TO_CHAR(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/1.1,2)),TO_CHAR((invl.TOTAL_AMOUNT / invl.QUANTITY)))       price_per_clip_card,
    DECODE(cen.COUNTRY,'SE',TO_CHAR(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/1.06,2)),'FI',TO_CHAR(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/1.1,2)),TO_CHAR((invls.TOTAL_AMOUNT / invls.QUANTITY))) price_per_clip_card_spons,
    DECODE(invls.PERSON_CENTER || 'p' || invls.PERSON_ID,'p',NULL,invls.PERSON_CENTER || 'p' || invls.PERSON_ID)                                                                                          pid_spons,
    exerpro.LongToDate(c.valid_until)                                                                                                                                                                     valid_until,
    p.name,
    p.ptype,
    DECODE(crt.INSTALLMENT_PLAN_ID,NULL,'No','Yes') AS "Installment Plan",
    insp.INSTALLEMENTS_COUNT                        AS "Total Installments",
    NVL(insp.INSTALLEMENTS_COUNT, 0) - (NVL(ar_per.ar_trans_count,0)+NVL(pay_per.pr_count,0)) AS "Total Inst. paid",
    NVL(ar_per.ar_trans_count,0) +NVL(pay_per.pr_count,0)                                         AS "Total Inst. unpaid",
    CASE DECODE(crt.INSTALLMENT_PLAN_ID,NULL,'No','Yes')   
         WHEN 'No' THEN
             0
         WHEN 'Yes' THEN      
             ROUND(((invl.TOTAL_AMOUNT - NVL(ABS(ar_per.ar_trans_amount), 0) + NVL(ABS(pay_per.pr_amount), 0))/invl.QUANTITY), 2)
    END AS "Total Inst. paid amount",
    NVL((ABS(ar_per.ar_trans_amount) + NVL(ABS(pay_per.pr_amount), 0))/invl.QUANTITY, 0)                     AS "Total Inst. unpaid amount"	
FROM
    SATS.CLIPCARDS c
CROSS JOIN
    params    
JOIN
    SATS.products p
ON
    p.center = c.center
    AND p.id = c.id
    AND p.GLOBALID NOT IN('PT45START1',
                          'PT45START2',
                          'SATSYOU1',
                          'SATSYOU_2',
                          'SATSYOU_3',
                          'MASSAGE_60_1_CLIP',
                          'MASSAGE_10_CLIP_60_MIN',
                          'MASSAGE_5_CLIP_60_MIN',
                          'MASSAGE_60_6_CLIP',
                          'MASSAGE_60_3_CLIP',
                          'REHAB_1_CLIP',
                          'REHAB_KLIPP_1_0KR',
                          'REHAB_POST_REHAB_10_CLIPS',
                          'REHAB_15_CLIP',
                          'REHAB_20_CLIPS',
                          'REHAB_KIG_3_CLIPS',
                          'REHAB_FOOT_6_CLIPS',
                          'REHAB_BACK_8_CLIPS',
                          'PT30INTRO',
                          'PT45INTRO')
    AND p.center NOT IN(572,571,581)
LEFT JOIN
    SATS.PERSON_EXT_ATTRS pea_oldid
ON
    pea_oldid.PERSONCENTER = c.owner_center
    AND pea_oldid.PERSONID = c.owner_id
    AND pea_oldid.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    SATS.INVOICELINES invl
ON
    invl.CENTER = c.INVOICELINE_CENTER
    AND invl.ID = c.INVOICELINE_ID
    AND invl.SUBID = c.INVOICELINE_SUBID
LEFT JOIN
    SATS.INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN
    SATS.INVOICELINES invls
ON
    invls.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND invls.ID = inv.SPONSOR_INVOICE_ID
    AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
LEFT JOIN
    SATS.CASHREGISTERTRANSACTIONS crt
ON
    inv.PAYSESSIONID = crt.PAYSESSIONID
    AND crt.amount != 0
LEFT JOIN
    INSTALLMENT_PLANS insp
ON
    insp.ID = crt.INSTALLMENT_PLAN_ID
LEFT JOIN
    SATS.CENTERS cen
ON
    cen.id = inv.CENTER
LEFT JOIN
    (
        SELECT
            cu.card_center,
            cu.card_id,
            cu.card_subid,
            ABS(SUM(cu.clips)) AS clip_used
        FROM
            sats.card_clip_usages cu
        CROSS JOIN
        params             
         WHERE
            cu.time < params.TODATE
        GROUP BY
            cu.card_center,
            cu.card_id,
            cu.card_subid ) clip_usage
ON
    clip_usage.card_center = c.center
    AND clip_usage.card_id = c.id
    AND clip_usage.card_subid = c.subid    
LEFT JOIN
    (
        SELECT
            art.installment_plan_id,
            COUNT(*)                                AS ar_trans_count,
            SUM(art.UNSETTLED_AMOUNT)               AS ar_trans_amount
        FROM
            sats.account_receivables ar
        CROSS JOIN
            params             
        LEFT JOIN
            sats.ar_trans art
        ON
            art.center = ar.center
            AND art.id = ar.id
            AND art.amount < 0
            and art.status != 'CLOSED'
            AND art.UNSETTLED_AMOUNT < 0
            AND art.installment_plan_id IS NOT NULL
        WHERE
            ar.ar_type = 6
            and art.entry_time < params.TODATE            
        GROUP BY
            art.installment_plan_id) ar_per
ON
    ar_per.installment_plan_id = insp.id
LEFT JOIN
    (
        SELECT
            art.installment_plan_id,
            COUNT(*)                                AS pr_count,
            SUM(art.UNSETTLED_AMOUNT)               AS pr_amount
        FROM
            sats.account_receivables ar
        CROSS JOIN
            params             
        LEFT JOIN
            sats.ar_trans art
        ON
            art.center = ar.center
            AND art.id = ar.id
            AND art.amount < 0
            and art.status != 'CLOSED'
            AND art.UNSETTLED_AMOUNT < 0
            AND art.installment_plan_id IS NOT NULL
        WHERE
            ar.ar_type = 4
            and art.entry_time >= params.TODATE            
        GROUP BY
            art.installment_plan_id) pay_per
ON
    pay_per.installment_plan_id = insp.id    
WHERE
    C.OWNER_CENTER IN ($$scope$$)
    AND ( (c.clips_initial -   NVL(clip_usage.clip_used,0) > 0) or (NVL(ar_per.ar_trans_count,0) >0) )
    and inv.trans_time < params.TODATE    
    and c.cancelled =0
    
