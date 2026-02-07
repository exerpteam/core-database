WITH params AS MATERIALIZED
(
        SELECT
                DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 months') AS fromDate,
                DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) - interval '1 days' toDate,
                CAST(dateToLongC(TO_CHAR(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 months'),'YYYY-MM-DD'),c.id) AS BIGINT) AS fromDateLong,
                CAST(dateToLongC(TO_CHAR(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')),'YYYY-MM-DD'),c.id)-1 AS BIGINT) AS toDateLong,
                c.id AS center_id,
                c.name as center_name
        FROM 
                vivagym.centers c
        WHERE
                c.country = 'PT'   
                AND c.id IN (:Scope)   
)
SELECT
        'Reclaims mes actual' AS TransactionGroup,
        t3.payer_center || 'p' || t3.payer_id,
        t3.center,
        t3.id,
        t3.subid,
        t3.text,
        t3.center_id,
        t3.center_name,
        t3.art_amount - t3.total_amount AS total_amount
FROM
(
        SELECT
                t2.payer_center,
                t2.payer_id,
                t2.center,
                t2.id,
                t2.subid,
                t2.text,
                t2.center_id,
                t2.center_name,
                t2.art_amount,
                SUM(t2.new_amount) AS total_amount
        FROM
        (
                SELECT
                        t1.*,
                        (CASE
                                WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NULL THEN t1.amount
                                WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NOT NULL THEN 0
                                WHEN t1.new_entry_time IS NULL THEN 0
                        END) AS new_amount
                FROM
                (
                        SELECT
                                i.payer_center,
                                i.payer_id,
                                art.center,
                                art.id,
                                art.subid,
                                art.text,
                                -art.amount AS art_amount,
                                par.center_id,
                                par.center_name,
                                (CASE
                                        WHEN artm.entry_time <= par.toDateLong THEN artm.entry_time
                                        WHEN artm.entry_time > par.toDateLong THEN NULL
                                END) AS new_entry_time,
                                (CASE 
                                        WHEN artm.cancelled_time <= par.toDateLong THEN artm.cancelled_time
                                        WHEN artm.cancelled_time > par.toDateLong THEN NULL
                                END) AS new_cancelled_time,
                                artm.amount
                        FROM vivagym.ar_trans art
                        JOIN params par ON art.center = par.center_id
                        JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                        LEFT JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid
                        WHERE 
                                i.entry_time >= par.fromDateLong
                                AND i.entry_time < par.toDateLong
                ) t1
        ) t2
        GROUP BY
                t2.payer_center,
                t2.payer_id,
                t2.center,
                t2.id,
                t2.subid,
                t2.text,
                t2.center_id,
                t2.center_name,
                t2.art_amount
) t3
WHERE
        t3.art_amount != t3.total_amount
UNION ALL
SELECT
        r3.*
FROM
(
        SELECT
                'Reclaims meses anteriores' AS TransactionGroup,
                t3.payer_center || 'p' || t3.payer_id,
                t3.center,
                t3.id,
                t3.subid,
                t3.text,
                t3.center_id,
                t3.center_name,
                -(CASE 
                        WHEN t3.total_amount > 0 THEN 0
                        ELSE t3.total_amount
                END) AS total_reclaims
        FROM
        (
                SELECT
                        t2.payer_center,
                        t2.payer_id,
                        t2.center,
                        t2.id,
                        t2.subid,
                        t2.text,
                        t2.center_id,
                        t2.center_name,
                        SUM(t2.new_amount) AS total_amount
                FROM
                (
                        SELECT
                                t1.*,
                                (CASE
                                        WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NULL THEN t1.amount
                                        WHEN t1.new_entry_time IS NULL AND t1.new_cancelled_time IS NOT NULL THEN -t1.amount
                                        ELSE 0
                                END) AS new_amount
                        FROM
                        (
                                SELECT
                                        i.payer_center,
                                        i.payer_id,
                                        art.center,
                                        art.id,
                                        art.subid,
                                        art.text,
                                        par.center_id,
                                        par.center_name,
                                        longtodatec(artm.entry_time, art.center),
                                        longtodatec(artm.cancelled_time, art.center),
                                        (CASE
                                                WHEN artm.entry_time between par.fromDateLong AND par.toDateLong THEN artm.entry_time
                                                ELSE NULL
                                        END) AS new_entry_time,
                                        (CASE 
                                                WHEN artm.cancelled_time between par.fromDateLong AND par.toDateLong THEN artm.cancelled_time
                                                ELSE NULL
                                        END) AS new_cancelled_time,
                                        artm.amount
                                FROM vivagym.ar_trans art
                                JOIN params par ON art.center = par.center_id
                                JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                                JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid
                                WHERE 
                                        i.entry_time < par.fromDateLong
                                        AND EXISTS
                                        (
                                                SELECT 1
                                                FROM art_match artm2 
                                                WHERE
                                                        artm2.art_paid_center = art.center 
                                                        AND artm2.art_paid_id = art.id 
                                                        AND artm2.art_paid_subid = art.subid 
                                                        AND artm2.cancelled_time between par.fromDateLong AND par.toDateLong 
                                        )
                        ) t1
                ) t2
                GROUP BY
                        t2.payer_center,
                        t2.payer_id,
                        t2.center,
                        t2.id,
                        t2.subid,
                        t2.text,
                        t2.center_id,
                        t2.center_name
        ) t3
) r3
WHERE
        r3.total_reclaims <> 0
UNION ALL
SELECT
        r4.*
FROM
(
        SELECT
                'Recoveries meses anteriores' AS TransactionGroup,
                t3.payer_center || 'p' || t3.payer_id,
                t3.center,
                t3.id,
                t3.subid,
                t3.text,
                t3.center_id,
                t3.center_name,
                (CASE 
                        WHEN t3.total_amount < 0 THEN 0
                        ELSE t3.total_amount
                END) AS total_recoveries
        FROM
        (
                SELECT
                        t2.payer_center,
                        t2.payer_id,
                        t2.center,
                        t2.id,
                        t2.subid,
                        t2.text,
                        t2.center_id,
                        t2.center_name,
                        SUM(t2.new_amount) AS total_amount
                FROM
                (
                        SELECT
                                t1.*,
                                (CASE
                                        WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NULL THEN t1.amount
                                        WHEN t1.new_entry_time IS NULL AND t1.new_cancelled_time IS NOT NULL THEN -t1.amount
                                        ELSE 0
                                END) AS new_amount
                        FROM
                        (
                                SELECT
                                        i.payer_center,
                                        i.payer_id,
                                        art.center,
                                        art.id,
                                        art.subid,
                                        art.text,
                                        par.center_id,
                                        par.center_name,
                                        longtodatec(artm.entry_time, art.center),
                                        longtodatec(artm.cancelled_time, art.center),
                                        (CASE
                                                WHEN 
                                                        artm.entry_time between par.fromDateLong AND par.toDateLong 
                                                        AND art2.entry_time > par.fromDateLong 
                                                                THEN artm.entry_time
                                                ELSE NULL
                                        END) AS new_entry_time,
                                        (CASE 
                                                WHEN artm.cancelled_time between par.fromDateLong AND par.toDateLong THEN artm.cancelled_time
                                                ELSE NULL
                                        END) AS new_cancelled_time,
                                        artm.amount,
                                        longtodatec(art2.entry_time, art2.center) AS art2_entrytime
                                FROM vivagym.ar_trans art
                                JOIN params par ON art.center = par.center_id
                                JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                                JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid             
                                JOIN vivagym.ar_trans art2 ON artm.art_paying_center = art2.center AND artm.art_paying_id = art2.id AND artm.art_paying_subid = art2.subid          
                                WHERE 
                                        i.entry_time < par.fromDateLong
                                        AND EXISTS
                                        (
                                                SELECT 1
                                                FROM art_match artm2 
                                                WHERE
                                                        artm2.art_paid_center = art.center 
                                                        AND artm2.art_paid_id = art.id 
                                                        AND artm2.art_paid_subid = art.subid 
                                                        AND artm2.entry_time between par.fromDateLong AND par.toDateLong 
                                        )
                        ) t1
                ) t2
                GROUP BY
                        t2.payer_center,
                        t2.payer_id,
                        t2.center,
                        t2.id,
                        t2.subid,
                        t2.text,
                        t2.center_id,
                        t2.center_name
        ) t3
) r4
WHERE
        r4.total_recoveries <> 0