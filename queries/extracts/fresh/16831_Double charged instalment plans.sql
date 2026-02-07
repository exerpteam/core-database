SELECT DISTINCT
    ar.CUSTOMERCENTER||'p'|| ar.CUSTOMERID AS memberid,
    --    art.COLLECTED,
    DECODE(prs.state,1, 'New',2,'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6,
    'Rejected, bank',7,'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',
    12,'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17,
    'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20,
    'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out',
    'Not collected in Payment request yet ') AS pr_state,
    --    prs.state,
    longtodate(art.ENTRY_TIME) ENTRYTIME ,
    art.STATUS,
    art.AMOUNT,
    art.UNSETTLED_AMOUNT,
    art.COLLECTED_AMOUNT,
    --    art.EMPLOYEECENTER,
    --    art.EMPLOYEEID,
    art3.text AS correction
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    AR_TRANS art
ON
    ar.center = art.center
AND ar.id = art.id
    --AND art.UNSETTLED_AMOUNT !=0
JOIN
    account_receivables ar2
ON
    ar.CUSTOMERCENTER= ar2.CUSTOMERCENTER
AND ar.CUSTOMERID = ar2.CUSTOMERID
AND ar2.ar_type = 6
JOIN
    ar_trans art2
ON
    ar2.center = art2.center
AND ar2.id = art2.id
JOIN
    INSTALLMENT_PLANS ip
ON
    ar.CUSTOMERCENTER = ip.PERSON_CENTER
AND ar.CUSTOMERID = ip.PERSON_ID
AND art2.INSTALLMENT_PLAN_ID = ip.id
JOIN
    INVOICELINES i
ON
    art.REF_CENTER = i.CENTER
AND art.REF_ID = i.id
LEFT JOIN
    PAYMENT_REQUESTS prs
ON
    prs.INV_COLL_CENTER = art.PAYREQ_SPEC_CENTER
AND prs.INV_COLL_ID = art.PAYREQ_SPEC_ID
AND art.PAYREQ_SPEC_SUBID = prs.INV_COLL_SUBID
    --LEFT JOIN
    --    ART_MATCH arm
    --ON
    --    art.CENTER = arm.ART_PAID_CENTER
    --AND art.id = arm.ART_PAID_ID
    --AND art.SUBID = arm.ART_PAID_SUBID
    --LEFT JOIN
    --    AR_TRANS art3
    --ON
    --    art3.CENTER = arm.ART_PAYING_CENTER
    --AND art3.ID = arm.ART_PAYING_ID
    --AND art3.SUBID = arm.ART_PAYING_SUBID
LEFT JOIN
    AR_TRANS art3
ON
    art3.CENTER = art.CENTER
AND art3.ID = art.id
AND art3.SUBID != art.SUBID
AND art.AMOUNT = -art3.AMOUNT
AND art3.ENTRY_TIME > art.ENTRY_TIME-(1000*60*5)
AND art3.ENTRY_TIME < art.ENTRY_TIME+(1000*60*5)
WHERE
    ar.ar_type = 4
AND i.INSTALLMENT_PLAN_ID = ip.id
AND art.EMPLOYEECENTER = art2.EMPLOYEECENTER
AND art2.EMPLOYEEID = art.EMPLOYEEID
AND ip.AMOUNT = i.TOTAL_AMOUNT
AND art.ENTRY_TIME > 1512501600000
--AND art3.center IS NULL
--AND art.AMOUNT !=-art3.AMOUNT
--    AND ROUND(art2.AMOUNT*ip.INSTALLEMENTS_COUNT) = i.TOTAL_AMOUNT
--    AND ar.CUSTOMERCENTER = 575
--    AND ar2.CUSTOMERID = 35335
--ORDER BY
--    ENTRYTIME DESC
UNION
SELECT DISTINCT
    ar.CUSTOMERCENTER||'p'|| ar.CUSTOMERID AS memberid,
    --    art.COLLECTED,
    DECODE(prs.state,1, 'New',2,'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6,
    'Rejected, bank',7,'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',
    12,'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17,
    'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20,
    'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out',
    'Not collected in Payment request yet ') AS pr_state,
    --    prs.state,
    longtodate(art.ENTRY_TIME) ENTRYTIME ,
    art.STATUS,
    art.AMOUNT,
    art.UNSETTLED_AMOUNT,
    art.COLLECTED_AMOUNT,
    --    art.EMPLOYEECENTER,
    --    art.EMPLOYEEID,
    art3.text AS correction
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    AR_TRANS art
ON
    ar.center = art.center
AND ar.id = art.id
    --AND art.UNSETTLED_AMOUNT !=0
JOIN
    relatives r
ON
    ar.CUSTOMERCENTER = r.CENTER
AND ar.CUSTOMERID = r.id
AND r.RTYPE = 12
JOIN
    account_receivables ar2
ON
    r.RELATIVECENTER= ar2.CUSTOMERCENTER
AND r.RELATIVEID = ar2.CUSTOMERID
AND ar2.ar_type = 6
JOIN
    ar_trans art2
ON
    ar2.center = art2.center
AND ar2.id = art2.id
JOIN
    INSTALLMENT_PLANS ip
ON
    --    ar.CUSTOMERCENTER = ip.PERSON_CENTER
    --AND ar.CUSTOMERID = ip.PERSON_ID
    art2.INSTALLMENT_PLAN_ID = ip.id
JOIN
    INVOICELINES i
ON
    art.REF_CENTER = i.CENTER
AND art.REF_ID = i.id
LEFT JOIN
    PAYMENT_REQUESTS prs
ON
    prs.INV_COLL_CENTER = art.PAYREQ_SPEC_CENTER
AND prs.INV_COLL_ID = art.PAYREQ_SPEC_ID
AND art.PAYREQ_SPEC_SUBID = prs.INV_COLL_SUBID
    --LEFT JOIN
    --    ART_MATCH arm
    --ON
    --    art.CENTER = arm.ART_PAID_CENTER
    --AND art.id = arm.ART_PAID_ID
    --AND art.SUBID = arm.ART_PAID_SUBID
    --LEFT JOIN
    --    AR_TRANS art3
    --ON
    --    art3.CENTER = arm.ART_PAYING_CENTER
    --AND art3.ID = arm.ART_PAYING_ID
    --AND art3.SUBID = arm.ART_PAYING_SUBID
LEFT JOIN
    AR_TRANS art3
ON
    art3.CENTER = art.CENTER
AND art3.ID = art.id
AND art3.SUBID != art.SUBID
AND art.AMOUNT = -art3.AMOUNT
AND art3.ENTRY_TIME > art.ENTRY_TIME-(1000*60*5)
AND art3.ENTRY_TIME < art.ENTRY_TIME+(1000*60*5)
WHERE
    ar.ar_type = 4
AND i.INSTALLMENT_PLAN_ID = ip.id
AND art.EMPLOYEECENTER = art2.EMPLOYEECENTER
AND art2.EMPLOYEEID = art.EMPLOYEEID
AND ip.AMOUNT = i.TOTAL_AMOUNT
AND art.ENTRY_TIME > 1512501600000
    --AND art3.center IS NULL
    --AND art.AMOUNT !=-art3.AMOUNT
    --    AND ROUND(art2.AMOUNT*ip.INSTALLEMENTS_COUNT) = i.TOTAL_AMOUNT
    --    AND ar.CUSTOMERCENTER = 575
    --    AND ar2.CUSTOMERID = 35335
ORDER BY
    ENTRYTIME DESC