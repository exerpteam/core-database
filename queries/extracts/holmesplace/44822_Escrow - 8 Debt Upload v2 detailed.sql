SELECT
    p.external_id AS "MemberNumber",
	NULL AS "UserNumber",    
  	NULL AS "ExternalContractId",
	NULL AS "ContractId",
	ar.id AS "ExternalTransactionId",
	longtodateTZ(art.entry_time, 'Europe/Berlin')+3 AS "Date",
	--CASE art.due_date WHEN NULL THEN longtodateTZ(art.entry_time, 'Europe/Berlin') ELSE art.due_date END AS "Date",---
    art.unsettled_amount AS "AmountGross",
	'19%'  AS "VatRate",
	'Migrated Debt' AS "Description",
	'Membership' AS "TransactionType",
	NULL AS "TransactionCategory",
	NULL AS "PeriodStartDate",
	NULL AS "PeriodEndDate",
	art.text AS "Text",
	P.CENTER AS "Club",
	p.CENTER || 'p' || p.ID AS "PersonID",
    p.FIRSTNAME as "Name",
	p.LASTNAME  AS "Lastname",
     p.blacklisted AS "Blocked",
    case p.status
        when 0 then 'lead'
        when 1 then 'active'
        when 2 then 'inactive'
        when 3 then 'temp inactive'
        when 4 then 'transferred'
        when 5 then 'duplicate'
        when 6 then 'prospect'
        when 7 then 'blocked'
        when 8 then 'anonymized'
        when 9 then 'contact'
        else 'undefined'
    end as "MemberStatus",
    CASE
        WHEN cc.amount IS NOT NULL
        THEN cc.amount
        ELSE (sum_unsettled.unsettledamount*-1)
    END                                                                                                                                     AS "OverdueDebt",
    ar.balance                                                                                                                                                  AS "CurrentArBalance",


CASE
        WHEN cc.STARTDATE IS NOT NULL
        THEN cc.STARTDATE
        ELSE closedcc.maxstartdate
    END AS "CollectionStartdate",   

   
    CASE
        WHEN active_agr_ch.id IS NOT NULL
        THEN active_agr_ch.NAME
        ELSE 'MISSING'
    END AS "CurrentAgreementType",
    
    CASE
        WHEN active_agr.center IS NOT NULL
        THEN CASE active_agr.state 
                 WHEN 4 THEN 'OK'
                 WHEN 3 THEN 'OK'
                 WHEN 13 THEN 'OK'
                 WHEN 16 THEN 'OK'
                 WHEN 14 THEN 'INCOMPLETE'
                 ELSE 'INVALID'
              END   
        ELSE 'MISSING'
    END                                    AS "CurrentAgreementState",
    last_file_sentpayment_request.req_date AS "LastRejDate",
    last_file_sentpayment_request.ch_name  AS "LastRejType",
    last_file_sentpayment_request.xfr_info AS "LastRejReason",
    last_payment_request.req_date          AS "LastPRDate",
    CASE
        WHEN last_payment_request.state = 12
        THEN 'Invalid agreement'
        ELSE last_payment_request.ch_name
    END AS "LastPRType"
FROM
    PERSONS p
JOIN
    centers c
ON 
    c.id = p.center	
left JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.center
    AND cc.personid = p.id
    AND cc.CLOSED = 0
    AND cc.MISSINGPAYMENT = 1

JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    ar.customerCENTER = p.CENTER
    AND ar.customerID = p.ID
    AND ar.AR_TYPE = 4
    AND ar.state = 0
JOIN
	ar_trans art
ON  
	ar.center = art.center
	AND ar.id = art.id

left join
( Select
ar2.center,
ar2.id,
sum(art.unsettled_amount) as unsettledamount
from
ACCOUNT_RECEIVABLES ar2
join
 ar_trans  art 
on 
ar2.center = art.center
and
ar2.id = art.id
and
due_date < current_date
group by
ar2.center,
ar2.id ) sum_unsettled
on 
ar.center = sum_unsettled.center
and
ar.id = sum_unsettled.id

left join
( Select
ar3.center,
ar3.id,
max(art3.due_date) as last_due
from
ACCOUNT_RECEIVABLES ar3
join
 ar_trans  art3 
on
ar3.center = art3.center
and
ar3.id = art3.id
and
due_date < current_date
-- and unsettled_amount > 0
group by
ar3.center,
ar3.id ) closestdue
on 
ar.center = closestdue.center
and
ar.id = closestdue.id


left JOIN
(select
cc2.personcenter,
cc2.personid,
max(cc2.startdate) as maxstartdate

from
    CASHCOLLECTIONCASES cc2
where
    cc2.CLOSED = 1
group by
cc2.personcenter,
cc2.personid ) closedcc
on
closedcc.personcenter = p.center
and
closedcc.personid = p.id

LEFT JOIN
    HP.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
    AND pac.id = ar.id
LEFT JOIN
    HP.PAYMENT_AGREEMENTS active_agr
ON
    active_agr.CENTER = pac.ACTIVE_AGR_CENTER
    AND active_agr.ID = pac.ACTIVE_AGR_ID
    AND active_agr.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    HP.CLEARINGHOUSES active_agr_ch
ON
    active_agr.CLEARINGHOUSE = active_agr_ch.ID
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.id,
            pr.state,
            ch.name AS ch_name,
            pr.REQ_DATE,
            pr.XFR_DATE,
            pr.XFR_INFO
        FROM
            HP.PAYMENT_REQUESTS pr
        JOIN
            HP.CLEARINGHOUSES ch
        ON
            pr.CLEARINGHOUSE_ID = ch.id
        WHERE
            pr.REQUEST_TYPE IN (1,6)
            AND pr.state NOT IN (1,2)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.PAYMENT_REQUESTS pr2
                WHERE
                    pr2.center = pr.center
                    AND pr2.id = pr.id
                    AND pr2.request_type IN (1,6)
                    AND pr2.state NOT IN (1,2)
                    AND pr2.subid > pr.subid ) ) last_payment_request
ON
    last_payment_request.center = ar.center
    AND last_payment_request.id = ar.id
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.id,
            pr.state,
            ch.name AS ch_name,
            pr.REQ_DATE,
            pr.XFR_DATE,
            pr.XFR_INFO
        FROM
            HP.PAYMENT_REQUESTS pr
        JOIN
            HP.CLEARINGHOUSES ch
        ON
            pr.CLEARINGHOUSE_ID = ch.id
        WHERE
            pr.REQUEST_TYPE IN (1,6)
            AND pr.state NOT IN (1,2,3,4)
            AND pr.REQ_DELIVERY IS NOT NULL
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.PAYMENT_REQUESTS pr2
                WHERE
                    pr2.center = pr.center
                    AND pr2.id = pr.id
                    AND pr2.request_type IN (1,6)
                    AND pr2.state NOT IN (1,2,3,4)
                    AND pr2.REQ_DELIVERY IS NOT NULL
                    AND pr2.subid > pr.subid ) ) last_file_sentpayment_request
ON
    last_file_sentpayment_request.center = ar.center
    AND last_file_sentpayment_request.id = ar.id
WHERE
    p.center IN (:scope)
    
and art.unsettled_amount < 0
