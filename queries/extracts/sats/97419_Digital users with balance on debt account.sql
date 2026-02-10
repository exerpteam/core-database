-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cp.center || 'p' || cp.id AS "MEMBER_ID",
	cp.external_id AS "MEMBER EXTERNAL ID",
    ar.BALANCE AS "DEBT_AMOUNT"
    
    
FROM
    ACCOUNT_RECEIVABLES ar
LEFT JOIN ACCOUNTS ac ON
    ac.center = ar.ASSET_ACCOUNTCENTER AND
    ac.id = ar.ASSET_ACCOUNTID
LEFT JOIN PERSONS p ON
    p.center = ar.CUSTOMERCENTER AND
    p.id = ar.CUSTOMERID
LEFT JOIN PERSONS cp ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER AND
    cp.id = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN SUBSCRIPTIONS s ON
    s.owner_center = cp.center AND
    s.owner_id = cp.id AND
    s.state = 2  
LEFT JOIN PRODUCTS pr ON
    pr.center = s.subscriptiontype_center AND
    pr.id = s.subscriptiontype_id
LEFT JOIN CENTERS c ON
    c.id = cp.center
WHERE
    ar.center IN (:scope) AND
    cp.status IN (1, 3) AND  
    ar.AR_TYPE = 5 AND       
    ar.BALANCE < 0 AND
    (pr.globalid = 'DIGITAL_USER' OR pr.name = 'Digital user')

