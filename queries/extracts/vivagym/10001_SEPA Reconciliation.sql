-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                d2.fromDate,
                d2.toDate,
                d2.center_id,
                d2.center_name
                
        FROM
        (
                SELECT
                        (CASE
                                WHEN d1.current_day = 1 THEN
                                        d1.firstPreviousMonth
                                ELSE
                                        d1.firstMonth
                        END) AS fromDate,
                        (CASE
                                WHEN d1.current_day = 1 THEN
                                        d1.endPreviousMonth
                                ELSE
                                        d1.endMonth
                        END) AS toDate,
                        d1.center_id,
                        d1.center_name
                FROM    
                (
                        SELECT
                                EXTRACT(DAY FROM TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS current_day,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS firstMonth,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + interval '1 month') - interval '1 day' AS endMonth,
                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day') AS firstPreviousMonth,
                                TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day' AS endPreviousMonth,
                                c.id AS center_id,
                                c.name as center_name
                        FROM 
                                vivagym.centers c
                        WHERE
                                c.country = 'ES'
                ) d1
        ) d2
)
SELECT
        'Payment Requests' AS transaction_group,
        r1.*,
        (CASE r1.request_type_code
                        WHEN 1 THEN 'Payment'
                        WHEN 6 THEN 'Representation'
                        ELSE 'Investigate'
        END) AS request_type,
        rank() over (partition BY r1.inv_coll_center,r1.inv_coll_id,r1.inv_coll_subid ORDER BY r1.req_date DESC) ranking,
        /*
                Payment = Total Amount
                Payment + Rejection Fee = Total Amount + 3€
                Representation  = 0€
                Representation + Rejected = 1€   
        */
        (CASE
                WHEN r1.request_type_code = 1 AND r1.rejection_fee IS NULL THEN r1.req_amount
                WHEN r1.request_type_code = 1 AND r1.rejection_fee IS NOT NULL THEN r1.req_amount + 3
                WHEN r1.request_type_code = 6 AND r1.rejected_reason_code IS NOT NULL THEN 1
                ELSE 0                
        END) AS sales_sepa,    
        /*
                All the PR that was sent for collection (not sent to bank excluded) - All reclaims
        */   
        (CASE
                -- r1.state = 2 SENT is a special case
                WHEN r1.Sent_status = 'Transaction sent to bank' THEN r1.req_amount
                ELSE 0
        END) AS total_banco,
        (CASE
                WHEN r1.request_type_code = 6 AND r1.state = 3 THEN r1.req_amount
                ELSE 0
        END) recoveries,
        (CASE
                WHEN r1.Sent_status = 'Transaction NOT sent to bank' THEN r1.req_amount
                ELSE 0
        END) AS not_sent_to_bank,
        0 as reclaims
FROM
(
        SELECT
                par.fromDate,
                par.toDate,
                pr.center,
                par.center_name,
                ar.customercenter || 'p' || ar.customerid AS person_key, 
                pr.req_amount,
                pr.req_date,
                CAST(NULL AS DATE) AS received_date,
                CAST(NULL AS NUMERIC) AS File_id,
                CAST(NULL AS TEXT) AS File_name,
                pr.rejected_reason_code,
                pr.xfr_amount,
                pr.xfr_date,
                pr.xfr_delivery,
                pr.xfr_info,
                (CASE pr.STATE 
                        WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' 
                        WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' 
                        WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' 
                        WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' 
                        WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' 
                        WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' 
                END) AS payment_request_state,
                pr.state,
                pr.inv_coll_center,
                pr.inv_coll_id,
                pr.inv_coll_subid,
                (CASE
                        WHEN pr.state = 2 THEN 'Transaction sent to bank'
                        WHEN pr.request_type = 1 AND pr.reject_fee_invline_center IS NOT NULL THEN 'Transaction sent to bank'
                        WHEN pr.xfr_date IS NULL THEN 'Transaction NOT sent to bank'
                        ELSE 'Transaction sent to bank'
                END) Sent_status,
                pr.request_type AS request_type_code,
                pr.reject_fee_invline_center AS rejection_fee
        FROM vivagym.payment_requests pr
        JOIN params par
                ON par.center_id = pr.center
        JOIN vivagym.account_receivables ar 
                ON ar.center = pr.center AND ar.id = pr.id
        WHERE
                pr.req_date >= par.fromDate
                AND pr.req_date <= par.toDate
                AND pr.req_amount != 0
                AND pr.clearinghouse_id IN (:ClearinghouseID)
) r1
UNION ALL
SELECT
        'Devoluciones' AS transaction_group,
        r2.*,
        (CASE
                WHEN r2.req_date < r2.fromDate AND r2.ranking = 1 AND r2.request_type_code = 1 THEN 3
                WHEN r2.req_date < r2.fromDate AND r2.ranking = 1 AND r2.request_type_code = 6 THEN 1
                ELSE 0
        END) AS sales_sepa, -- 101p982
        -(r2.req_amount) as total_banco,
        0 as recoveries,
        0 AS not_sent_to_bank,
        (CASE
                WHEN r2.ranking = 1 AND r2.request_type_code = 6 AND r2.rejected_reason_code IS NOT NULL THEN r2.req_amount + 1
                WHEN r2.ranking = 1 AND r2.rejection_fee IS NOT NULL THEN r2.req_amount + 3
                WHEN r2.ranking = 1 AND r2.request_type_code = 1 AND r2.rejection_fee IS NULL THEN r2.req_amount
                ELSE 0
        END) AS reclaims
FROM
(
        SELECT
                r1.*,
                rank() over (partition BY r1.inv_coll_center,r1.inv_coll_id,r1.inv_coll_subid ORDER BY r1.req_date DESC) ranking
        FROM
        (
                SELECT
                        par.fromDate,
                        par.toDate,
                        pr.center,
                        par.center_name,
                        ar.customercenter || 'p' || ar.customerid AS person_key,
                        pr.req_amount,
                        pr.req_date,
                        ci.received_date,
                        ci.id AS File_id,
                        ci.filename AS File_name,
                        pr.rejected_reason_code,
                        pr.xfr_amount,
                        pr.xfr_date,
                        pr.xfr_delivery,
                        pr.xfr_info,
                        (CASE pr.STATE 
                                WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' 
                                WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' 
                                WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' 
                                WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' 
                                WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' 
                                WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' 
                        END) AS payment_request_state,
                        pr.state,
                        pr.inv_coll_center,
                        pr.inv_coll_id,
                        pr.inv_coll_subid,
                        (CASE
                                WHEN pr.xfr_date IS NULL
                                THEN 'Transaction NOT sent to bank'
                                ELSE 'Transaction sent to bank '
                        END) Sent_status,
                        pr.request_type as request_type_code,
                        pr.reject_fee_invline_center AS rejection_fee,
                        (CASE pr.request_type
                                WHEN 1 THEN 'Payment'
                                WHEN 6 THEN 'Representation'
                                ELSE 'Investigate'
                        END) AS request_type
                FROM vivagym.clearing_in ci
                JOIN vivagym.payment_requests pr
                        ON ci.id = pr.xfr_delivery
                JOIN PARAMS par
                        ON par.center_id = pr.center
                JOIN vivagym.account_receivables ar
                        ON ar.center = pr.center
                        AND ar.ID = pr.ID
                WHERE
                        ci.received_date >= par.fromDate
                        AND ci.received_date <= par.toDate
                        --AND pr.state = 4
                        AND pr.clearinghouse_id IN (:ClearinghouseID)
        ) r1 
) r2
       