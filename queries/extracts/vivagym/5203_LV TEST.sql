WITH
            params AS
            (
             SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS from_date,
                    datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'),  'YYYY-MM-DD'), c.ID)+ (86400 * 1000)-1 AS to_date,
                    c.ID                      AS CenterID
               FROM
                    CENTERS c
                   )                   
                 

SELECT 
                ccc.center || 'c' || ccc.id AS "CC Id",
        p.center || 'p' || ar.id AS "Member Id",
          
        p.external_id  AS "Member external id",  
        p.fullname AS "Member name",
        (CASE pr.state
                WHEN 1 THEN 'New' 
                WHEN 2 THEN 'Sent' 
                WHEN 3 THEN 'Done' 
                WHEN 4 THEN 'Done, manual' 
                WHEN 5 THEN 'Rejected, clearinghouse' 
                WHEN 6 THEN 'Rejected, bank' 
                WHEN 7 THEN 'Rejected, debtor' 
                WHEN 8 THEN 'Cancelled' 
                WHEN 10 THEN 'Reversed, new' 
                WHEN 11 THEN 'Reversed , sent' 
                WHEN 12 THEN 'Failed, not creditor' 
                WHEN 13 THEN 'Reversed, rejected' 
                WHEN 14 THEN 'Reversed, confirmed' 
                WHEN 17 THEN 'Failed, payment revoked' 
                WHEN 18 THEN 'Done Partial' 
                WHEN 19 THEN 'Failed, Unsupported' 
                WHEN 20 THEN 'Require approval' 
                WHEN 21 THEN 'Fail, debt case exists' 
                WHEN 22 THEN 'Failed, timed out' 
                ELSE 'Undefined' 
        END) AS pr_state,
--        pr.req_amount,
       pr.req_date AS "Request date",
       pr.full_reference,
           
 CASE P.STATUS
             WHEN 0 THEN 'LEAD'
     WHEN 1 THEN 'ACTIVE'
     WHEN 2 THEN 'INACTIVE'
     WHEN 3 THEN 'TEMPORARY INACTIVE' 
    WHEN 4 THEN 'TRANSFERRED' 
    WHEN 5 THEN 'DUPLICATE' 
    WHEN 6 THEN 'PROSPECT' 
    WHEN 7 THEN 'DELETED'
     WHEN 8 THEN 'ANONIMIZED' 
    WHEN 9 THEN 'CONTACT'
     ELSE 'UNKNOWN' END AS "Person status", 
CASE p.persontype 
WHEN 0 THEN 'PRIVATE' 
WHEN 1 THEN 'STUDENT' 
WHEN 2 THEN 'STAFF' 
WHEN 3 THEN 'FRIEND'
WHEN 4 THEN 'CORPORATE' 
WHEN 5 THEN 'ONEMANCORPORATE' 
WHEN 6 THEN 'FAMILY' 
WHEN 7 THEN 'SENIOR' 
WHEN 8 THEN 'GUEST' 
WHEN 9 THEN 'CHILD' 
WHEN 10 THEN 'EXTERNAL_STAFF' 
ELSE 'Undefined' 
END AS "Person type",
TO_CHAR(longtodateC(ccc.start_datetime,ccc.center), 'dd-mm-yyyy') AS "Debt case Start" ,
TO_CHAR(longtodateC(ccc.closed_datetime,ccc.center), 'dd-mm-yyyy') AS "Debt case Stop" ,
CASE WHEN CURRENTSTEP_TYPE = 0 THEN 'MESSAGE' WHEN CURRENTSTEP_TYPE = 1 THEN 'REMINDER' WHEN CURRENTSTEP_TYPE = 2 THEN 'BLOCK' WHEN CURRENTSTEP_TYPE = 3 THEN 'REQUESTANDSTOP' WHEN CURRENTSTEP_TYPE = 4 THEN 'CASHCOLLECTION' WHEN CURRENTSTEP_TYPE = 5 THEN 'CLOSE' WHEN CURRENTSTEP_TYPE = 6 THEN 'WAIT' WHEN CURRENTSTEP_TYPE = 7 THEN 'REQUESTBUYOUTANDSTOP' WHEN CURRENTSTEP_TYPE = 8 THEN 'PUSH' ELSE 'Undefined' END AS "Current debt step",
 (
        CASE
            WHEN ccc.missingpayment = false 
            THEN 'MISSING_AGREEMENT'
            ELSE 'DEBT_CASE'
        END) AS "Case type",
         pr.xfr_info as rejection_details,
        pr.rejected_reason_code,
ccc.currentstep_date AS "Date current step set"
--        pr.due_date,
--        pr.full_reference,
--        (CASE pr.request_type
--                WHEN 1 THEN 'Payment' 
--                WHEN 2 THEN 'Debt Collection' 
--                WHEN 3 THEN 'Reversal' 
--                WHEN 4 THEN 'Reminder' 
--                WHEN 5 THEN 'Refund' 
--                WHEN 6 THEN 'Representation' 
--                WHEN 7 THEN 'Legacy' 
--                WHEN 8 THEN 'Zero' 
--                WHEN 9 THEN 'Service Charge' 
--                ELSE 'Unknown' 
--        END) AS Request_type,
--        pr.reject_fee_invline_center

FROM
        payment_requests pr
JOIN
        params par ON par.centerId = pr.center
JOIN
        centers c ON pr.center = c.id
JOIN 
        clearinghouses ch ON ch.id = pr.clearinghouse_id
JOIN
        payment_agreements pag ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
JOIN
        payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
JOIN
        account_receivables ar ON pac.center = ar.center AND pac.id = ar.id
JOIN
        persons p ON ar.customercenter = p.center AND ar.customerid = p.id
INNER JOIN
cashcollectioncases ccc

ON

p.center = ccc.personcenter
AND
p.id = ccc.personid
AND
       ccc.closed = false

WHERE
ccc.start_datetime BETWEEN par.from_date AND par.to_Date

AND
pr.full_reference IN
(WITH
            params AS
            (
              SELECT
                TO_DATE(:FromDate,'YYYY-MM-DD') AS from_Date,
                TO_DATE(:ToDate,'YYYY-MM-DD') AS to_Date,
                c.id AS centerId
        FROM 
                centers c
     -- WHERE 
        --       c.id = 716
                    
                   )            
 SELECT
 pr.full_reference from
 payment_requests pr
 JOIN
 params par ON par.centerId = pr.center
 WHERE
pr.req_date BETWEEN par.from_date AND par.to_Date
AND
       pr.state NOT IN (1,2,3,4,8)
       )
AND
p.center IN (:SCOPE)
AND
p.persontype NOT IN (1,2,3,5,6,7,8,9,10)


        