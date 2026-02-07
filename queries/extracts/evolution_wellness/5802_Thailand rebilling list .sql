SELECT
         p.external_id AS ExternalID
         ,p.center||'p'||p.id as PersonID
         ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
         ,ar.balance
         ,CASE
                WHEN pag.clearinghouse = 803 THEN 'Adyen TH CF'
                WHEN pag.clearinghouse = 804 THEN 'Adyen TH FF'
                WHEN pag.clearinghouse = 1801 THEN 'Bangkok TH'
                WHEN pag.clearinghouse = 2001 THEN 'Kasikorn TH'
                WHEN pag.clearinghouse = 3601 THEN 'Krungthai TH'
                WHEN pag.clearinghouse =  3801 THEN 'Siam TH'
        END AS ClearingHouse 
        ,CASE
                WHEN ccc.center IS NULL THEN 'No'
                ELSE 'Yes'  
        END AS OpenDebtCase                          
FROM evolutionwellness.persons p
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
JOIN evolutionwellness.clearinghouses ch ON pag.clearinghouse = ch.id
LEFT JOIN evolutionwellness.cashcollectioncases ccc ON ccc.personcenter = ar.customercenter AND ccc.personid = ar.customerid AND ccc.closed IS FALSE AND ccc.missingpayment IS true
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND pag.clearinghouse IN (:ClearingHouseID)
        AND pag.state  = 4
        AND ar.balance < 0
Order by
        pag.clearinghouse
        ,p.external_id        
