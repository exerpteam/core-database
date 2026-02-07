-- This is the version from 2026-02-05
--  
WITH params AS MATERIALIZED
(
        SELECT
                TO_DATE(:fromDate,'YYYY-MM-DD') AS fromDate,
                TO_DATE(:toDate,'YYYY-MM-DD') AS toDate,
                dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDateLong,
                dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id) AS toDateLong,
                c.id AS centerId
        FROM fw.centers c
        WHERE
                c.id IN (:Scope)
),
eligible_persons AS
(
        SELECT
                DISTINCT
                s1.personCenter,
                s1.personId
        FROM
        (
                
                SELECT
                        r2.*,
                        r2.req_amount + r2.reminderfees AS Total,
                        ccc.center || 'ccol' || ccc.id AS cashcollectionid,
                        ccc.currentstep,
                        ccc.start_datetime,
                        rank() over (partition by ccc.personcenter,ccc.personid ORDER BY ccc.start_datetime DESC) AS ranking
                FROM
                (
                        SELECT
                                SUM(COALESCE(-art.amount,0)) AS reminderfees,
                                r1.center,
                                r1.id,
                                r1.subid,
                                r1.personCenter||'p'|| r1.personId, 
                                r1.personCenter,
                                r1.personId,
                                r1.personStatus,
                                r1.ref,
                                r1.due_date,
                                r1.req_date,
                                r1.req_amount,
                                r1.open_amount,
                                r1.payment_request_state
                        FROM
                        (
                                SELECT
                                        prs.center,
                                        prs.id,
                                        prs.subid,
                                        p.center AS personCenter,
                                        p.id AS personId,
                                        p.status AS personStatus,
                                        prs.ref,
                                        pr.due_date,
                                        pr.req_date,
                                        pr.req_amount,
                                        prs.open_amount,
                                        CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state
                                FROM fw.payment_request_specifications prs
                                JOIN params par
                                        ON par.centerId = prs.center
                                JOIN fw.payment_requests pr
                                        ON prs.center = pr.inv_coll_center AND prs.id = pr.inv_coll_id AND prs.subid = pr.inv_coll_subid
                                JOIN fw.account_receivables ar
                                        ON pr.center = ar.center AND pr.id = ar.id
                                JOIN fw.persons p
                                        ON ar.customercenter = p.center AND ar.customerid = p.id
                                WHERE
                                        pr.due_date >= par.fromDate
                                        AND pr.due_date <= par.toDate
                        ) r1
                        LEFT JOIN fw.ar_trans art
                                ON art.payreq_spec_center = r1.center
                                AND art.payreq_spec_id = r1.id 
                                AND art.payreq_spec_subid = r1.subid
                                AND art.text = 'Payment Reminder'
                                AND art.amount < 0
                        GROUP BY
                                r1.center,
                                r1.id,
                                r1.subid,
                                r1.personCenter,
                                r1.personId,
                                r1.personStatus,
                                r1.ref,
                                r1.due_date,
                                r1.req_date,
                                r1.req_amount,
                                r1.open_amount,
                                r1.payment_request_state
                ) r2
                JOIN params par 
                        ON r2.personCenter = par.centerId
                JOIN fw.cashcollectioncases ccc 
                        ON ccc.personcenter = r2.personCenter 
                        AND ccc.personid = r2.personId 
                        AND ccc.missingpayment = 1
                        AND ccc.start_datetime < par.toDateLong
                        AND (ccc.closed_datetime IS NULL OR ccc.closed_datetime > par.fromDateLong) 
                        AND ccc.currentstep_type NOT IN (-1)
        ) s1
        WHERE
                s1.ranking = 1
)
SELECT 
        ep.*,
        ar.ar_type,
        longtodatec(art.entry_time,ar.center) AS paymeny_date,
        art.text,
        art.amount,
        art.info
FROM eligible_persons ep
JOIN fw.account_receivables ar ON ep.personCenter = ar.customercenter AND ep.personId = ar.customerid
JOIN params par ON par.centerId = ar.center
JOIN fw.ar_trans art ON ar.center = art.center AND ar.id = art.id
WHERE
        art.amount > 0
        AND ar.ar_type NOT IN (1)
        AND art.entry_time between par.fromDateLong AND par.toDateLong
        AND art.text IN
                (
                        'API Register remaining money from payment request',
                        'Indbetaling til konto',
                        'Manuel registrering af betaling: Payment open request'
                )