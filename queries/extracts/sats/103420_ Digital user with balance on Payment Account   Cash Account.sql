SELECT DISTINCT ON (cp.center, cp.id)
    cp.center || 'p' || cp.id AS "MEMBER_ID",
    CASE ar.AR_TYPE
        WHEN 1 THEN 'CASH'
        WHEN 4 THEN 'PAYMENT'
        WHEN 5 THEN 'DEBT'
        WHEN 6 THEN 'INSTALLMENT'
    END AS "ACCOUNT_TYPE",
    ar.BALANCE AS "DEBT_AMOUNT",
    pr.name AS "Subscription name",
    art.text AS "last transaction",
    longtodate(art.entry_time) "transaction date"
FROM ACCOUNT_RECEIVABLES ar
JOIN PERSONS p 
    ON p.center = ar.CUSTOMERCENTER 
   AND p.id = ar.CUSTOMERID
JOIN PERSONS cp 
    ON cp.center = p.TRANSFERS_CURRENT_PRS_CENTER 
   AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
JOIN SUBSCRIPTIONS s 
    ON s.owner_center = cp.center 
   AND s.owner_id = cp.id 
   AND s.state = 2  
JOIN PRODUCTS pr 
    ON pr.center = s.subscriptiontype_center 
   AND pr.id = s.subscriptiontype_id
JOIN CENTERS c 
    ON c.id = cp.center
JOIN ar_trans art   
    ON art.center = ar.center
   AND art.id = ar.id
   AND art.unsettled_amount != 0
WHERE ar.center IN (:scope)
  AND cp.status IN (1, 3)
  AND ar.BALANCE <> 0
  AND (pr.globalid = 'DIGITAL_USER' OR pr.name = 'Digital user')
ORDER BY cp.center, cp.id, art.trans_time DESC