SELECT
    r.relativecenter || 'p' || r.relativeid      AS MemberId,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID    AS PaidBy,
  ar.balance                          AS "payment account balance",
  (ccc.amount*-1) as debtamount,
   case when ccc.cashcollectionservice is not null
   then 'Yes'
   else 'No' end AS "Sent to debt collection agency",

case when ccc.CASHCOLLECTIONSERVICE = 1
then 'ARC'
Else null
end as agency,
ccc.CURRENTSTEP_DATE as datecurrentstep,
ccc.CURRENTSTEP AS currentstep,
CASE ccc.CURRENTSTEP_TYPE WHEN 0 THEN 'MESSAGE' WHEN 1 THEN 'REMINDER' WHEN 2 THEN 'BLOCK' WHEN 3 THEN 'REQUESTANDSTOP' WHEN 4 THEN 'CASHCOLLECTION' WHEN 5 THEN 'CLOSE' WHEN 6 THEN 'WAIT' WHEN 7 THEN 'REQUESTBUYOUTANDSTOP' WHEN 8 THEN 'PUSH' ELSE 'Undefined' END AS STEPTYPE,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS

FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons p
ON
    p.center = ar.customercenter
    and p.id = ar.customerid    	

JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = ar.customercenter
    AND ccc.PERSONID = ar.customerid
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
left JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID    
left JOIN
    relatives r
ON
    r.center = ar.customercenter
    AND r.id = ar.customerid
    AND r.rtype = 12
    AND r.status < 3    
WHERE
    ar.AR_TYPE = 4
    AND p.center IN (:Scope)
   -- AND art.status IN ('OPEN','NEW')
	AND p.sex != 'C'
GROUP BY
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID,
    r.relativecenter || 'p' || r.relativeid ,
    ccc.cashcollectionservice,
    ccc.CURRENTSTEP,
ccc.CASHCOLLECTIONSERVICE,
ccc.CURRENTSTEP_DATE,
p.STATUS,
ccc.amount,
ar.balance,
ccc.CURRENTSTEP_TYPE