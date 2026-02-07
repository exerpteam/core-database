WITH params AS MATERIALIZED
(
        SELECT
                d2.fromDate,
                dateToLongC(TO_CHAR(d2.fromDate,'YYYY-MM-DD'), d2.center_id) AS fromDateLong,
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
        'Payment Request current month' AS type,
        par.fromDate,
        par.toDate,
        pr.center,
        par.center_name,
        ar.customercenter || 'p' || ar.customerid AS person_key, 
        (CASE pr.STATE 
                WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' 
                WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' 
                WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' 
                WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' 
                WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' 
                WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' 
        END) AS payment_request_state,
        (CASE pr.request_type
                WHEN 1 THEN 'Payment'
                WHEN 6 THEN 'Representation'
                ELSE 'Investigate'
        END) AS request_type,
        pr.req_date,
        pr.req_amount,
        pr.req_delivery AS fileout,
        (CASE
                WHEN pr.reject_fee_invline_center IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) AS rejection_fee_applied,
        pr.xfr_amount,
        pr.xfr_date,
        pr.xfr_info,
        ch.name AS clearinghouse_name,
        pr.rejected_reason_code
FROM vivagym.payment_requests pr
JOIN params par
        ON par.center_id = pr.center
JOIN vivagym.account_receivables ar 
        ON ar.center = pr.center AND ar.id = pr.id
JOIN vivagym.clearinghouses ch 
        ON pr.clearinghouse_id = ch.id
WHERE
        pr.req_date >= par.fromDate
        AND pr.req_date <= par.toDate
        AND pr.req_amount != 0
        AND pr.clearinghouse_id IN (:ClearinghouseID)
UNION ALL
SELECT
        'Payment Request previous month' AS type,
        par.fromDate,
        par.toDate,
        pr.center,
        par.center_name,
        ar.customercenter || 'p' || ar.customerid AS person_key, 
        (CASE pr.STATE 
                WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' 
                WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' 
                WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' 
                WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' 
                WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' 
                WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' 
        END) AS payment_request_state,
        (CASE pr.request_type
                WHEN 1 THEN 'Payment'
                WHEN 6 THEN 'Representation'
                ELSE 'Investigate'
        END) AS request_type,
        pr.req_date,
        pr.req_amount,
        pr.req_delivery AS fileout,
        (CASE
                WHEN pr.reject_fee_invline_center IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) AS rejection_fee_applied,
        pr.xfr_amount,
        pr.xfr_date,
        pr.xfr_info,
        ch.name AS clearinghouse_name,
        pr.rejected_reason_code
FROM vivagym.clearing_in ci
JOIN vivagym.payment_requests pr
        ON ci.id = pr.xfr_delivery
JOIN PARAMS par
        ON par.center_id = pr.center
JOIN vivagym.account_receivables ar
        ON ar.center = pr.center
        AND ar.ID = pr.ID
JOIN vivagym.clearinghouses ch 
        ON pr.clearinghouse_id = ch.id
WHERE
        ci.received_date >= par.fromDate
        AND ci.received_date <= par.toDate
        --AND pr.state = 4
        AND pr.clearinghouse_id IN (:ClearinghouseID)
        AND pr.rejected_reason_code IS NOT NULL
        AND pr.entry_time < par.fromDateLong
    