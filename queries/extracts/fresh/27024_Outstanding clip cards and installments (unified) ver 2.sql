WITH
    params AS MATERIALIZED
    (
        SELECT
            dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days',
            'YYYY-MM-DD'),c.id) AS cutdate,
            c.country,
            c.id
        FROM
            centers c
        WHERE
            c.id IN (:Scope)
    )
SELECT
    t1.*,
    COALESCE(last_usage.target_center, t1.center) AS LAST_USED_CENTER,
    (
        SELECT
            ccu2.DESCRIPTION
        FROM
            CARD_CLIP_USAGES ccu2
        WHERE
            ccu2.CARD_CENTER = t1.center
        AND ccu2.CARD_ID = t1.id
        AND ccu2.CARD_SUBID = t1.subid
        ORDER BY
            ccu2.time DESC,
            ccu2.id DESC limit 1 ) AS LAST_USAGE_DESCRIPTION
FROM
    (
        SELECT DISTINCT
            c.center                    center,
            c.id                        id,
            c.subid                     subid,
            per.center ||'p'||per.id AS memberID,
            per.external_id          AS member_externalID,
            pea_oldid.txtvalue       AS OLD_MEMBERNUMBER,
            c.clips_left,
            c.clips_initial,
            il.QUANTITY quantity,
            CASE par.country
                WHEN 'SE'
                THEN (il.TOTAL_AMOUNT / il.QUANTITY)/(1+COALESCE(ilvat.rate,0))
                WHEN 'FI'
                THEN (il.TOTAL_AMOUNT / il.QUANTITY)/(1+COALESCE(ilvat.RATE,0))
                ELSE (il.TOTAL_AMOUNT / il.QUANTITY)
            END           price_per_clip_card,
            il.NET_AMOUNT net_amount,
            CASE par.country
                WHEN 'SE'
                THEN CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(ilvat.RATE,0)),2)
                    AS text)
                WHEN 'FI'
                THEN CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(ilvat.RATE,0)),2)
                    AS text)
                ELSE CAST((invls.TOTAL_AMOUNT / invls.QUANTITY) AS text)
            END price_per_clip_card_spons,
            CASE invls.PERSON_CENTER || 'p' || invls.PERSON_ID
                WHEN 'p'
                THEN NULL
                ELSE invls.PERSON_CENTER || 'p' || invls.PERSON_ID
            END                                  pid_spons,
            LongToDateC(c.valid_until, c.center) valid_until,
            p.name,
            p.ptype,
            CASE
                WHEN insp.id IS NULL
                THEN 'No'
                ELSE 'Yes'
            END AS "Installment Plan",
            CASE
                WHEN insp.id IS NULL
                THEN ''
                ELSE insp.person_center ||'p'||insp.person_id
            END                                                     AS "Installment Plan on Person",
            insp.INSTALLEMENTS_COUNT                                        AS "Total Installments",
            COALESCE(insp.INSTALLEMENTS_COUNT, 0) - COALESCE(ar_per.ar_trans_count,0) AS
            "Total Inst. paid",
            COALESCE(ar_per.ar_trans_count,0) AS "Total Inst. unpaid",
            CASE
                WHEN
                    CASE
                        WHEN insp.id IS NULL
                        THEN 'No'
                        ELSE 'Yes'
                    END = 'Yes'
                AND il.TOTAL_AMOUNT> 0
                THEN ROUND(((il.TOTAL_AMOUNT - COALESCE(ABS(ar_per.ar_trans_amount), 0))/
                    il.QUANTITY), 2)
                ELSE 0
            END AS "Total Inst. paid amount",
            CASE
                WHEN
                    CASE
                        WHEN insp.id IS NULL
                        THEN 'No'
                        ELSE 'Yes'
                    END = 'Yes'
                AND il.TOTAL_AMOUNT> 0
                THEN COALESCE(ABS(ar_per.ar_trans_amount)/il.QUANTITY, 0)
                ELSE 0
            END AS "Total Inst. unpaid amount"
        FROM
            clipcards c
        JOIN
            params par
        ON
            c.owner_center = par.id
        AND c.valid_until > par.cutdate
        JOIN
            persons per
        ON
            per.center = c.owner_center
        AND per.id = c.owner_id
        JOIN
            products p
        ON
            p.center = c.center
        AND p.id = c.id
        JOIN
            invoice_lines_mt il
        ON
            il.center = c.invoiceline_center
        AND il.id = c.invoiceline_id
        AND il.subid = c.invoiceline_subid
        LEFT JOIN
            invoicelines_vat_at_link ilvat
        ON
            il.center = ilvat.invoiceline_center
        AND ilvat.invoiceline_id = il.id
        AND ilvat.invoiceline_subid = il.subid
        LEFT JOIN
            invoices i
        ON
            i.center = il.center
        AND i.id = il.id
        LEFT JOIN
            invoice_lines_mt invls
        ON
            invls.center = i.sponsor_invoice_center
        AND invls.id = i.sponsor_invoice_id
        AND invls.subid = il.sponsor_invoice_subid
        LEFT JOIN
            installment_plans insp
        ON
            insp.ID = il.installment_plan_id
        LEFT JOIN
            card_clip_usages ccu
        ON
            c.CENTER = ccu.card_center
        AND c.id = ccu.card_id
        AND c.subid = ccu.card_subid
        LEFT JOIN
            person_ext_attrs pea_oldid
        ON
            pea_oldid.PERSONCENTER = c.owner_center
        AND pea_oldid.PERSONID = c.owner_id
        AND pea_oldid.name = '_eClub_OldSystemPersonId'
        LEFT JOIN
            (
                SELECT
                    art.installment_plan_id,
                    COUNT(*)                  AS ar_trans_count,
                    SUM(art.UNSETTLED_AMOUNT) AS ar_trans_amount
                FROM
                    account_receivables ar
                JOIN
                    params par
                ON
                    ar.center = par.id
                JOIN
                    ar_trans art
                ON
                    art.center = ar.center
                AND art.id = ar.id
                WHERE
                    art.amount < 0
                AND art.status != 'CLOSED'
                AND art.UNSETTLED_AMOUNT < 0
                AND art.installment_plan_id IS NOT NULL
                AND ar.ar_type = 6
                GROUP BY
                    art.installment_plan_id ) ar_per
        ON
            ar_per.installment_plan_id = insp.id
        WHERE
            p.globalid NOT IN('PT45START1',
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
                              'PT45INTRO',
                              'BRING_A_FRIEND_CLIPCARD',
                              'BRING_A_FRIEND_LOYALTY_LEVEL3',
                              'CONCEPT_GOLDEN_TICKET',
                              'DK_TRNING_MED_VEN',
                              'DROP_IN_WITHOUT_HANDBACK',
                              'DROP-IN_BATH_FREE',
                              'DROP-IN_BATH_WITH_SPA_FREE',
                              'GX_&_CONCEPT_ACCESS_–_LOYALTY1',
                              'GX_ACCESS_2CLIPS',
                              'GX_ACCESS_4CLIPS',
                              'GX_ACCESS_6CLIPS',
                              'GX_ACCESS_8CLIPS',
                              'HIYOGA_VOUCHER',
                              'LOYALTY_BLUE_BRINGAFRIEND',
                              'LOYALTY_BLUE_GX&CONCEPT',
                              'LOYALTY_GOLD_BRINGAFRIEND',
                              'LOYALTY_GOLD_GX&CONCEPT',
                              'LOYALTY_PLATINUM_BRINGAFRIEND',
                              'LOYALTY_PLATINUM_GX&CONCEPT',
                              'LOYALTY_SILVER_BRINGAFRIEND',
                              'LOYALTY_SILVER_GX&CONCEPT',
                              'PTSTARTNEW',
                              'VOUCHER_CON',
                              'VOUCHER_GX',
                              'LOYALTY_BLUE_BRINGAFRIEND',
                              'LOYALTY_BLUE_GX&CONCEPT',
                              'LOYALTY_GOLD_BRINGAFRIEND',
                              'LOYALTY_GOLD_GX&CONCEPT',
                              'LOYALTY_PLATINUM_BRINGAFRIEND',
                              'LOYALTY_PLATINUM_GX&CONCEPT',
                              'LOYALTY_SILVER_BRINGAFRIEND',
                              'LOYALTY_SILVER_GX&CONCEPT',
                              'CONCEPT_ACCESS_2CLIPS',
                              'CONCEPT_ACCESS_4CLIPS',
                              'CONCEPT_ACCESS_6CLIPS',
                              'CONCEPT_ACCESS_8CLIPS')
        AND p.center NOT IN(570,571,581)
        AND c.cancelled = false
        AND c.valid_until > par.cutdate
        AND (
                ccu.TYPE <> 'TRANSFER'
            OR  ccu.TYPE IS NULL)
        AND (
                c.clips_left > 0
            OR  (
                    il.total_amount> 0
                AND COALESCE(ar_per.ar_trans_count,0) >0 ) ) ) t1
LEFT JOIN
    (
        SELECT
            t.source_center,
            t.source_id,
            t.source_subid,
            t.deduction_key,
            t.target_center
        FROM
            (
                SELECT
                    RANK() over (PARTITION BY SOURCE_CENTER, SOURCE_ID, SOURCE_SUBID ORDER BY
                    USE_TIME DESC) AS myRANK,
                    pu.*
                FROM
                    clipcards c
                JOIN
                    params par
                ON
                    par.id = c.owner_center
                JOIN
                    privilege_usages pu
                ON
                    c.center = pu.source_center
                AND c.id = pu.source_id
                AND c.subid =pu.source_subid
                WHERE
                    pu.state <> 'CANCELLED'
                AND pu.target_service = 'Attend'
                AND c.clips_left > 0
                AND c.valid_until > par.cutdate ) t
        WHERE
            t.MYRANK = 1 ) last_usage
ON
    last_usage.SOURCE_CENTER = t1.CENTER
AND last_usage.SOURCE_ID = t1.ID
AND last_usage.SOURCE_SUBID = t1.SUBID