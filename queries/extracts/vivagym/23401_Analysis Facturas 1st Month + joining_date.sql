-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                DATETOLONGc(TO_CHAR(to_date(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromDate,
                to_date(:fromDate,'YYYY-MM-DD') as fromDateReq,
                to_date(:toDate,'YYYY-MM-DD') as toDateReq,
                DATETOLONGc(TO_CHAR(to_date(:fromDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 as toDate,
                DATETOLONGc(TO_CHAR(to_date(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 as endofMonth,
                c.id
        FROM vivagym.centers c
        WHERE
                c.id IN (:Scope)
                AND 
                c.country = 'ES'
),
area_scopes AS MATERIALIZED
(
        SELECT
                a.name AS areaname,
                ac.center AS centerid
        FROM vivagym.areas a
        JOIN vivagym.area_centers ac ON a.id = ac.area
        WHERE
                a.parent = 131
),
list_pr_rep_next_month AS
(
        SELECT
                ar.customercenter,
                ar.customerid,
                ar.customercenter || 'p' || ar.customerid/*,
                CASE rep.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state,
                pr.req_date,
                rep.xfr_info,
                rep.req_date,
                rep.xfr_date*/
        FROM vivagym.account_receivables ar
        JOIN params par ON ar.center = par.id
        JOIN vivagym.payment_requests pr
                ON pr.center = ar.center AND pr.id = ar.id
        JOIN vivagym.payment_requests rep
                ON pr.inv_coll_center = rep.inv_coll_center AND pr.inv_coll_id = rep.inv_coll_id AND pr.inv_coll_subid = rep.inv_coll_subid AND rep.request_type = 6 AND rep.state NOT IN (8) AND rep.req_date >= par.fromDateReq
        WHERE
                pr.req_date < par.fromDateReq
                AND pr.request_type = 1
),
list_facturas_current_month AS
(
SELECT
        --112inv272495
        t2.*,
        t2.amount + t2.total_amount AS addons_amount
        
FROM
        (
                SELECT
                        t1.entryDate,
                        t1.personid,
                        t1.customercenter,
                        t1.customerid,
                        t1.external_id,
                        t1.text,
                        t1.name,
                        t1.globalid,
                        t1.amount,
                        string_agg(t1.spptype,';') AS period_type,
                        sum(t1.total_amount) AS total_amount,
                        t1.invoice_id,
                        t1.center,
                        t1.id,
                        t1.subid
                FROM
                (
                        SELECT
                                date_trunc('day',longtodatec(art.entry_time, art.center)) AS entryDate,
                                ar.customercenter || 'p' || ar.customerid AS personId,
                                ar.customercenter,
                                ar.customerid,
                                p.external_id,
                                --p.fullname,
                                art.text,
                                pr.name,
                                pr.globalid,
                                art.amount,
                                (CASE 
                                        WHEN spp.spp_type = 7 THEN 'CONDITIONAL_FREEZE'
                                        WHEN spp.spp_type = 2 THEN 'UNCONDITIONAL_FREEZE'
                                        WHEN spp.spp_type = 1 THEN 'NORMAL'
                                        WHEN spp.spp_type = 3 THEN 'FREE'
                                        ELSE 'UNKNOWN'
                                END) AS spptype,
                                il.total_amount,
                                i.center || 'inv' || i.id AS invoice_id,
                                art.center,
                                art.id,
                                art.subid
                        FROM vivagym.ar_trans art
                        JOIN PARAMS par ON par.id = art.center
                        JOIN vivagym.account_receivables ar ON art.center = ar.center AND art.id = ar.id AND ar.ar_type = 4
                        JOIN vivagym.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
                        JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                        JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
                        JOIN vivagym.products pr ON il.productcenter = pr.center AND il.productid = pr.id
                        JOIN vivagym.spp_invoicelines_link spl ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
                        JOIN vivagym.subscriptionperiodparts spp ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
                        -- 4172
                        WHERE
                                art.ref_type = 'INVOICE'
                                AND art.text like ('%(Renovación automática)')
                                AND art.entry_time between par.fromDate and par.toDate
                                AND pr.ptype NOT IN (13)
                                AND pr.globalid NOT IN ('STAFF_HEADOFFICE_GLOBAL','STAFF_GLOBAL_PRIVILEGES','STAFF_LOCAL_PRIVILEGES')
                ) t1
                GROUP BY
                        t1.entryDate,
                        t1.personid,
                        t1.customercenter,
                        t1.customerid,
                        t1.external_id,
                        t1.text,
                        t1.name,
                        t1.globalid,
                        t1.amount,
                        t1.invoice_id,
                        t1.center,
                        t1.id,
                        t1.subid
        ) t2
),
payment_request_summary AS
(
        SELECT
                t2.*
        FROM
        (
                SELECT
                        t1.customercenter,
                        t1.customerid,
                        ch.name AS ch_name,
                        CASE prp.request_type WHEN 1 THEN 'Payment' WHEN 2 THEN 'Debt Collection' WHEN 3 THEN 'Reversal' WHEN 4 THEN 'Reminder' WHEN 5 THEN 'Refund' WHEN 6 THEN 'Representation' WHEN 7 THEN 'Legacy' WHEN 8 THEN 'Zero' WHEN 9 THEN 'Service Charge' ELSE NULL END AS REQUEST_TYPE_payment,
                        CASE prp.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE NULL END AS payment_request_state_payment,
                        prp.xfr_info AS xfr_info_payment,
                        prp.req_Date AS req_date_payment,
                        CASE prr.request_type WHEN 1 THEN 'Payment' WHEN 2 THEN 'Debt Collection' WHEN 3 THEN 'Reversal' WHEN 4 THEN 'Reminder' WHEN 5 THEN 'Refund' WHEN 6 THEN 'Representation' WHEN 7 THEN 'Legacy' WHEN 8 THEN 'Zero' WHEN 9 THEN 'Service Charge' ELSE null END AS REQUEST_TYPE_rep,
                        CASE prr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE NULL END AS payment_request_state_rep,
                        prr.xfr_info AS xfr_info_rep,
                        prr.req_date AS req_date_rep,
                        rank () OVER (PARTITION BY  t1.customercenter, t1.customerid ORDER BY prr.req_date DESC) AS ranking2
                FROM
                (
                        SELECT
                                ar.customercenter,
                                ar.customerid,
                                prs.center,
                                prs.id,
                                prs.subid,
                                par.fromDateReq,
                                par.toDateReq,
                                rank () OVER (PARTITION BY  ar.customercenter, ar.customerid ORDER BY prs.entry_time DESC) AS ranking
                        FROM vivagym.payment_request_specifications prs
                        JOIN vivagym.account_receivables ar ON prs.center = ar.center AND prs.id = ar.id
                        JOIN params par ON prs.center = par.id
                        WHERE
                                prs.issued_date between par.fromDate AND par.endofMonth
                                AND prs.cancelled = false
                ) t1
                JOIN vivagym.payment_requests prp ON prp.inv_coll_center = t1.center AND prp.inv_coll_id = t1.id AND prp.inv_coll_subid = t1.subid AND prp.request_type NOT IN (6)
                JOIN vivagym.clearinghouses ch ON prp.clearinghouse_id = ch.id
                LEFT JOIN vivagym.payment_requests prr ON prr.inv_coll_center = t1.center AND prr.inv_coll_id = t1.id AND prr.inv_coll_subid = t1.subid AND prr.request_type IN (6) AND prr.req_date between t1.fromDateReq AND t1.toDateReq
                WHERE
                        ranking = 1
        ) t2
        WHERE
                t2.ranking2 = 1
)
,
    last_subscription_date AS
    (   
        SELECT 
            center, 
            owner_id as ownerid, 
            start_date 
        FROM 
            (   
                SELECT
                    s.center,
                    s.owner_id,
                    s.start_date,
                    RANK () OVER (
                              PARTITION BY
                                  s.center,
                                  s.owner_id
                              ORDER BY
                                  s.start_date ASC) AS older_subs
                FROM
                    vivagym.subscriptions s
                WHERE
                    s.end_date IS NULL
            ) sub
        WHERE 
            sub.older_subs = 1
    )
SELECT
        t3.entryDate AS factura_entryDate,
        a.areaname,
        t3.personId,
        t3.external_id,
        t3.text AS factura_text,
        t3.name AS main_product_in_factura,
        t3.globalid AS main_product_globalId,
        t3.amount AS factura_amount,
        t3.total_amount AS subscription_amount,
        t3.addons_amount AS addons_amount,
        t3.total_amount_settled + t3.amount AS open_amount,
        prs.ch_name AS clearinghouse_name,
        prs.request_type_payment AS first_payment_req_type,
        prs.payment_request_state_payment AS first_payment_req_state,
        prs.xfr_info_payment AS first_payment_req_response,
        prs.request_type_rep AS last_payment_req_type,
        prs.payment_request_state_rep AS last_payment_req_state,
        prs.xfr_info_rep AS last_payment_req_response,
        (CASE WHEN lprnm.customercenter IS NOT NULL THEN 'YES' ELSE 'NO' END) AS pay_req_represented_month_after,
        lsd.start_date AS joining_date
FROM
(
        SELECT
                t2.entryDate,
                t2.personid,
                t2.customercenter,
                t2.customerid,
                t2.external_id,
                t2.text,
                t2.name,
                t2.globalid,
                t2.amount,
                t2.invoice_id,
                t2.center,
                t2.id,
                t2.subid,
                t2.addons_amount,
                t2.total_amount,
                SUM(t2.new_amount) AS total_amount_settled
        FROM
        (
                SELECT
                        t1.*,
                        (CASE
                                WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NULL THEN t1.artm_amount
                                WHEN t1.new_entry_time IS NOT NULL AND t1.new_cancelled_time IS NOT NULL THEN 0
                                WHEN t1.new_entry_time IS NULL THEN 0
                        END) AS new_amount
                FROM
                (
                        SELECT
                                lfcm.*,
                                artm.entry_time,
                                artm.cancelled_time,
                                artm.amount AS artm_amount,
                                (CASE
                                        WHEN artm.entry_time <= par.endOfMonth THEN artm.entry_time
                                        WHEN artm.entry_time > par.endOfMonth THEN NULL
                                END) AS new_entry_time,
                                (CASE 
                                        WHEN artm.cancelled_time <= par.endOfMonth THEN artm.cancelled_time
                                        WHEN artm.cancelled_time > par.endOfMonth THEN NULL
                                END) AS new_cancelled_time
                        FROM list_facturas_current_month lfcm
                        JOIN PARAMS par on lfcm.center = par.id
                        LEFT JOIN vivagym.art_match artm ON artm.art_paid_center = lfcm.center AND artm.art_paid_id = lfcm.id AND artm.art_paid_subid = lfcm.subid
                ) t1
        ) t2
        GROUP BY
                t2.entryDate,
                t2.personid,
                t2.customercenter,
                t2.customerid,
                t2.external_id,
                t2.text,
                t2.name,
                t2.addons_amount,
                t2.globalid,
                t2.amount,
                t2.total_amount,
                t2.invoice_id,
                t2.center,
                t2.id,
                t2.subid
) t3
JOIN area_scopes a ON a.centerid = t3.center
LEFT JOIN payment_request_summary prs
        ON prs.customercenter = t3.customercenter AND prs.customerid = t3.customerid
LEFT JOIN list_pr_rep_next_month lprnm
        ON lprnm.customercenter = t3.customercenter AND lprnm.customerid = t3.customerid
LEFT JOIN
    last_subscription_date lsd
ON
    lsd.center = t3.customercenter 
AND lsd.ownerid = t3.customerid