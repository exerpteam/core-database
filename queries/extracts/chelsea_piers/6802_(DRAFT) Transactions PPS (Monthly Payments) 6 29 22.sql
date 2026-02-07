WITH
    params AS materialized
    (
        SELECT
            c.id                                 AS center,
	    CAST($$from_date$$ AS DATE) AS FROM_DATE,
            CAST($$to_date$$ AS DATE)+1 AS TO_DATE
        FROM
            centers c
    )
SELECT 
    pr.center          AS "Center",
    pr.full_reference  AS "Exerp Reference",
    pr.clearinghouse_payment_ref  AS "PPS Reference",
    CASE WHEN REQUEST_TYPE = 1 THEN 'Payment' WHEN REQUEST_TYPE = 2 THEN 'Debt Collection' WHEN REQUEST_TYPE = 3 THEN 'Reversal' 
         WHEN REQUEST_TYPE = 4 THEN 'Reminder' WHEN REQUEST_TYPE = 5 THEN 'Refund' WHEN REQUEST_TYPE = 6 THEN 'Representation' 
         WHEN REQUEST_TYPE = 7 THEN 'Legacy' WHEN REQUEST_TYPE = 8 THEN 'Zero' WHEN REQUEST_TYPE = 9 THEN 'Service Charge' ELSE 'Undefined' END AS "Request Type",
    CASE WHEN pr.STATE = 1 THEN 'New' WHEN pr.STATE = 2 THEN 'Sent' WHEN pr.STATE = 3 THEN 'Done' WHEN pr.STATE = 4 THEN 'Done, manual' WHEN pr.STATE = 5 THEN 'Rejected, clearinghouse' 
         WHEN pr.STATE = 6 THEN 'Rejected, bank' WHEN pr.STATE = 7 THEN 'Rejected, debtor' WHEN pr.STATE = 8 THEN 'Cancelled' WHEN pr.STATE = 10 THEN 'Reversed, new' 
         WHEN pr.STATE = 11 THEN 'Reversed , sent' WHEN pr.STATE = 12 THEN 'Failed, not creditor' WHEN pr.STATE = 13 THEN 'Reversed, rejected' WHEN pr.STATE = 14 THEN 'Reversed, confirmed' 
         WHEN pr.STATE = 17 THEN 'Failed, payment revoked' WHEN pr.STATE = 18 THEN 'Done Partial' WHEN pr.STATE = 19 THEN 'Failed, Unsupported' WHEN pr.STATE = 20 THEN 'Require approval' 
         WHEN pr.STATE = 21 THEN 'Fail, debt case exists' WHEN pr.STATE = 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS "Request State",
    to_char(pr.due_date,'MM/DD/YYYY')  AS "Due Date",
    to_char(longtodateC(pr.entry_time, pr.center),'MM/DD/YYYY HH24:MI')  AS "Entry Time",
    pr.req_amount   AS "Amount",
    pr.creditor_id AS "Creditor ID",
    pr.uuid    AS "UUID",
    pr.xfr_info  AS "Status",
    ar.customercenter||'p'||ar.customerid AS "Payer"
FROM
    PAYMENT_REQUESTS pr
JOIN
    PARAMS
ON 
    params.center =  pr.center
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
AND ar.id = pr.id
AND ar.AR_TYPE = 4    
WHERE
    pr.clearinghouse_id <> 201 -- exclude invoices
    AND pr.CENTER in ($$Scope$$) 
    AND pr.due_date >= params.FROM_DATE 
    AND pr.due_date < params.TO_DATE 
    AND pr.state IN (3,4)  -- Done and Manual
