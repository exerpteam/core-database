-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
      c.NAME                                           AS "Club Name" 
    , p.CURRENT_PERSON_CENTER||'p'|| p.CURRENT_PERSON_ID AS "Member Id" 
    , p.FULLNAME                                         AS "Full Name" 
    , TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD') "Deduction Date" 
    , TO_CHAR(longtodateC(prs.ENTRY_TIME, c.id), 'YYYY-MM-DD Hh24:MI:SS') "Log Date" 
    , TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD') "Due Date" 
    , pr.REQ_AMOUNT "Request Amount" 
    , art.AMOUNT "Paid Amount"
    --, art.EMPLOYEECENTER || 'emp' || art.EMPLOYEEID "Marked as paid by employee"
    , pemp.FULLNAME "Marked as paid by name"
    , TO_CHAR(longtodateC(art.TRANS_TIME, c.ID), 'YYYY-MM-DD HH24:MI:SS')     "Marked as paid date"
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
AND ar.CUSTOMERID = p.ID
AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pac.ACTIVE_AGR_CENTER
AND pag.ID = pac.ACTIVE_AGR_ID
AND pag.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = pag.CENTER
AND pr.ID = pag.ID
AND pr.AGR_SUBID = pag.SUBID
AND pr.CLEARINGHOUSE_ID = 401
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pr.INV_COLL_CENTER
AND prs.ID = pr.INV_COLL_ID
AND prs.SUBID = pr.INV_COLL_SUBID
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
AND art.PAYREQ_SPEC_ID = prs.ID
AND art.PAYREQ_SPEC_SUBID = prs.SUBID
AND art.REF_TYPE = 'ACCOUNT_TRANS'
AND art.COLLECTED = 2
JOIN
    EMPLOYEES e
ON
    e.CENTER = art.EMPLOYEECENTER
AND e.ID = art.EMPLOYEEID
JOIN
    persons pemp
ON
    e.PERSONCENTER = pemp.CENTER
AND e.PERSONID = pemp.ID
WHERE
    c.id IN ($$scope$$)
AND pr.DUE_DATE BETWEEN $$FromDate$$ AND $$ToDate$$    
AND pr.REQUEST_TYPE = 1
AND pr.STATE = 4 