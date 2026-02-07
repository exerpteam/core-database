SELECT
    p.center || 'p' || p.id AS "Person ID",
    p.external_id           AS "External ID",
    p.fullname              AS "Full Name",
    pag.ref                 AS "Reference",
    pag.bank_account_holder AS "Payment Agreement Holder",
    CASE s.state
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "Subscription Status",
    CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                        AS "Payment Agreement Status",
    pr.xfr_info                                AS "Reason",
    longtodatec(pag.creation_time, pag.center) AS "PA Created",
    s.start_date                               AS "Membership Start Date",
    s.billed_until_date                        AS "Membership Billed Until Date",
    s.end_date                                 AS "Membership End Date",
    ar.balance                                 AS "Balance",
    ccc.startdate                              AS "Debt Start Date",
    ccc.amount                                 AS "Debt Amount",
    ch.name                                    AS "Clearing House Name",
    pr.rejected_reason_code                    AS "Reject Reason Code",
    CASE pr.request_type
        WHEN 1
        THEN 'Payment'
        WHEN 6
        THEN 'Representation'
        ELSE 'UNKNOWN'
    END AS "Payment Request Type"
FROM
    payment_requests pr
JOIN
    payment_agreements pag
ON
    pr.CENTER = pag.center
AND pr.id = pag.id
AND pr.AGR_SUBID = pag.subid
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pag.CLEARINGHOUSE
JOIN
    account_receivables ar
ON
    ar.CENTER = pr.CENTER
AND ar.id = pr.ID
AND ar.AR_TYPE = 4
JOIN
    persons p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.id = ar.CUSTOMERID
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4,8)
JOIN
    cashcollectioncases ccc
ON
    ccc.personcenter = p.center
AND ccc.personid = p.id
AND ccc.missingpayment = 1
AND ccc.closed = 0
AND ccc.amount is not null
WHERE
p.center IN (:Scope)
AND 
p.persontype NOT IN (2)    
AND ar.balance < 0
AND pr.STATE NOT IN (1,2,3,4,8,12,18)
AND ( (
            pr.request_type = 1
        AND pr.req_date-1 <  CAST(DATE_TRUNC('day', now()- INTERVAL '8' DAY) AS DATE) and pr.req_date >  CAST(DATE_TRUNC('day', now()- INTERVAL '12' DAY) AS DATE)
        AND pr.xfr_info IN ('Acquirer Fraud',
                            'Blocked Card',
                            'FRAUD',
                            'FRAUD-CANCELLED',
                            'Issuer Suspected Fraud',
                            'Not supported',
                            'Restricted Card',
                            'Revocation Of Auth',
                            'Expired Card',
                            'Invalid Card Number',
                            'Issuer Suspected Fraud'))
   OR  (
           -- pr.STATE IN (6,7) --representations, rejected, by bank or debtor
         pr.request_type = 6
        AND pr.req_date-1 <  CAST(DATE_TRUNC('day', now()- INTERVAL '5' DAY) AS DATE) and pr.req_date >  CAST(DATE_TRUNC('day', now()- INTERVAL '8' DAY) AS DATE)
        and pag.state in (4)
        AND pr.xfr_info IN ('Declined Non Generic',
                            'Not enough balance',
                            'Withdrawal amount exceeded',
                            'Refused',
                            'Acquirer Error',
                            'Expired Card',
                            'Issuer Unavailable',
                            'Pin tries exceeded',
                            'Withdrawal count exceeded',
                            'Transaction Not Permitted',
                            'Invalid Card Number',
                            'Blocked Card',
                            'Revocation Of Auth',
                            'Issuer Suspected Fraud',
                                    'Issuer Unavailable',
                                     'Pin tries exceeded',
                                    'Transaction Not Permitted',
                                     'Acquirer Error'))
    OR  (
          --  pr.STATE NOT IN (6,7)
        pr.request_type = 6
        and pag.state not in (4)
        AND pr.req_date-1 <  CAST(DATE_TRUNC('day', now()- INTERVAL '1' DAY) AS DATE) and pr.req_date >  CAST(DATE_TRUNC('day', now()- INTERVAL '5' DAY) AS DATE)
        AND pr.xfr_info IN ('Declined Non Generic',
                            'Not enough balance',
                            'Withdrawal amount exceeded',
                            'Refused',
                            'Acquirer Error',
                            'Expired Card',
                            'Issuer Unavailable',
                            'Pin tries exceeded',
                            'Withdrawal count exceeded',
                            'Transaction Not Permitted',
                            'Invalid Card Number',
                            'Issuer Suspected Fraud')) )