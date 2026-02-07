WITH params AS MATERIALIZED
(
        SELECT
                DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS fromDate,
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days' toDate,
                CAST(dateToLongC(TO_CHAR(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')),'YYYY-MM-DD'),c.id) AS BIGINT) AS fromDateLong,
                CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)-1 AS BIGINT) AS toDateLong,
                c.id AS center_id,
                c.name as center_name
        FROM 
                vivagym.centers c
        WHERE
                c.country = 'ES'      
)
SELECT
        'Reclaims mes actual' AS TransactionGroup,
        r1.center_id,
        r1.center_name,
        r1.PersonId,
        r1.external_id,
        r1.text,
        -r1.unsettled_amount AS amount,
        r1.fromDate AS PeriodFrom,
        r1.toDate AS PeriodTo
FROM
(
        SELECT
                distinct
                ar.customercenter || 'p' || ar.customerid AS PersonId,
                cp.external_id,
                art.center,
                art.id,
                art.subid,
                art.center,
                art.id,
                art.subid,
                art.amount,
                art.text,
                art.due_date,
                art.payreq_spec_center,
                art.collected,
                art.status,
                art.unsettled_amount,
                longtodatec(artm.entry_time, artm.art_paid_center) AS entryTime,
                longtodatec(artm.cancelled_time, artm.art_paid_center) AS cancelledTime,
                (CASE 
                        WHEN artm.id IS NULL THEN 0
                        ELSE artm.amount 
                END) AS artm_amount,
                par.center_id,
                par.center_name,
                rank() over (partition by art.center, art.id, art.subid, artm.amount ORDER BY artm.entry_time DESC) ranking,
                par.fromDate,
                par.toDate
        FROM vivagym.ar_trans art
        JOIN params par ON art.center = par.center_id
        JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
        JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
        JOIN vivagym.persons cp ON cp.center = p.current_person_center AND cp.id = p.current_person_id
        JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
        LEFT JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid
        WHERE 
                i.entry_time >= par.fromDateLong
                AND i.entry_time < par.toDateLong
                --AND (artm.id IS NULL OR artm.entry_time < par.toDateLong)
                AND art.unsettled_amount != 0
) r1 
        WHERE r1.ranking = 1
UNION ALL
-- RECOVERIES
SELECT
        'Recoveries meses anteriores' AS TransactionGroup,
        r1.center_id,
        r1.center_name,
        r1.PersonId,
        r1.external_id,
        r1.text,
        r1.artm_amount AS amount,
        r1.fromDate AS PeriodFrom,
        r1.toDate AS PeriodTo
FROM
(
        SELECT
                ar.customercenter || 'p' || ar.customerid AS PersonId,
                cp.external_id,
                longtodatec(i.entry_time, i.center) AS invoiceDate,
                art.center,
                art.id,
                art.subid,
                art.amount,
                art.text,
                art.due_date,
                art.payreq_spec_center,
                art.collected,
                art.status,
                art.unsettled_amount,
                longtodatec(artm.entry_time, artm.art_paid_center) AS entryTime,
                longtodatec(artm.cancelled_time, artm.art_paid_center) AS cancelledTime,
                par.center_id,
                par.center_name,
                artm.amount AS artm_amount,
                par.fromDate,
                par.toDate
                --art2.*
        FROM vivagym.ar_trans art
        JOIN params par ON art.center = par.center_id
        JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
        JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
        JOIN vivagym.persons cp ON cp.center = p.current_person_center AND cp.id = p.current_person_id
        JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
        JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid AND artm.cancelled_time IS NULL
        JOIN vivagym.ar_trans art2 ON artm.art_paying_center = art2.center AND artm.art_paying_id = art2.id AND artm.art_paying_subid = art2.subid
        WHERE 
                i.entry_time < par.fromDateLong
                AND art2.entry_time > par.fromDateLong
                AND art2.entry_time < par.toDateLong
                AND artm.entry_time > par.fromDateLong
                AND artm.entry_time < (par.toDateLong + (8*60*60*1000))
                AND art.unsettled_amount = 0
                AND NOT EXISTS
                (
                        SELECT 1
                        FROM vivagym.art_match artm_re
                        WHERE
                                artm_re.art_paid_center = art.center 
                                AND artm_re.art_paid_id = art.id 
                                AND artm_re.art_paid_subid = art.subid 
                                AND artm_re.cancelled_time > par.fromDateLong
                                AND artm_re.cancelled_time < par.toDateLong
                )
) r1
UNION ALL
--RECLAIMS DE MESES ANTERIORES
SELECT
        'Reclaims meses anteriores' AS TransactionGroup,
        r1.center_id,
        r1.center_name,
        r1.PersonId,
        r1.external_id,
        r1.text,
        r1.artm_amount AS amount,
        r1.fromDate AS PeriodFrom,
        r1.toDate AS PeriodTo
FROM
(
        SELECT
                ar.customercenter || 'p' || ar.customerid AS PersonId,
                cp.external_id,
                longtodatec(i.entry_time, i.center) AS invoiceDate,
                art.center,
                art.id,
                art.subid,
                art.amount,
                art.text,
                art.due_date,
                art.payreq_spec_center,
                art.collected,
                art.status,
                art.unsettled_amount,
                longtodatec(artm.entry_time, artm.art_paid_center) AS entryTime,
                longtodatec(artm.cancelled_time, artm.art_paid_center) AS cancelledTime,
                par.center_id,
                par.center_name,
                (CASE 
                        WHEN artm.id IS NULL THEN 0
                        ELSE artm.amount 
                END) AS artm_amount,
                par.fromDate,
                par.toDate
        FROM vivagym.ar_trans art
        JOIN params par ON art.center = par.center_id
        JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id
        JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
        JOIN vivagym.persons cp ON cp.center = p.current_person_center AND cp.id = p.current_person_id
        JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
        JOIN vivagym.art_match artm ON artm.art_paid_center = art.center AND artm.art_paid_id = art.id AND artm.art_paid_subid = art.subid
        WHERE 
                i.entry_time < par.fromDateLong
                AND artm.cancelled_time > par.fromDateLong
                AND artm.cancelled_time < par.toDateLong
                AND art.status = 'OPEN'
) r1