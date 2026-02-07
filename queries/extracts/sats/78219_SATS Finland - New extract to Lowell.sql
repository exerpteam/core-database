SELECT
    ccc.personcenter||'p'||ccc.personid MemberID,
    sub.end_date                        "Stop",
    art.info "consolidated invoice",
    ccc.AMOUNT "Total debt",
    art.due_date ,
    art.unsettled_amount "Unsettled Amount ",
    acr1.balance "installment account"
FROM
    ACCOUNT_RECEIVABLES acr
JOIN
    cashcollectioncases ccc
ON
    ccc.personcenter = acr.CUSTOMERCENTER
AND ccc.personid = acr.customerid
AND acr.ar_type=5 --Debt collection account
JOIN
    subscriptions sub
ON
    sub.owner_center=ccc.personcenter
AND sub.owner_id=ccc.personid
JOIN
    centers cen
ON
    cen.id = ccc.personcenter
JOIN
    AR_TRANS art
ON
    art.CENTER = acr.CENTER
AND art.ID = acr.ID
 left JOIN
    ACCOUNT_RECEIVABLES acr1
ON
   acr.customercenter = acr1.customercenter
AND acr.customerid = acr1.customerid
AND acr1.ar_type= 6 --installment plan account
WHERE
    ccc.closed=0 -- Only look for open cash collection cases
AND ccC.MISSINGPAYMENT=1 -- only look for cash collection cases
AND cen.country='FI'
AND sub.end_date BETWEEN SYSDATE AND ADD_MONTHS(SYSDATE, 3)
    and ccc.personcenter in ($$scope$$)
AND art.status= 'NEW' --AND ART.UNSETTLED_AMOUNT <> 0
 and sub.state in (2,4,7,8)--Active,Frozen,Window,Created
and sub.sub_state not in (3,4)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            subscriptions sub1
        WHERE
            sub.owner_center = ccc.personcenter
        AND sub.owner_id= ccc.personid
        AND sub.end_date > ADD_MONTHS(SYSDATE, 3)) -- Do not have subscriptions with future end
    -- date 3 months from today

ORDER BY
    ccc.personcenter||'p'||ccc.personid