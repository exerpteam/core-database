SELECT
    p.CENTER || 'p' || p.id AS "Person key",
    pa.REF,
    CASE
        WHEN pa.state = 1
        THEN 'Created'
        WHEN pa.state = 2
        THEN 'SENT'
        WHEN pa.state = 3
        THEN 'Failed'
        WHEN pa.state = 4
        THEN 'OK'
        WHEN pa.state = 5
        THEN 'Ended, bank'
        WHEN pa.state = 6
        THEN 'Ended, bank'
        WHEN pa.state = 7
        THEN 'Ended, debtor'
        WHEN pa.state = 8
        THEN 'Cancelled, not sent'
        WHEN pa.state = 9
        THEN 'Cancelled, sent'
        WHEN pa.state = 10
        THEN 'Ended, creditor'
        WHEN pa.state = 11
        THEN 'No agreement'
        WHEN pa.state = 12
        THEN 'Cash payment'
        WHEN pa.state = 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN pa.state = 14
        THEN 'Agreement information incomplete'
        WHEN pa.state = 15
        THEN 'Transfer'
        WHEN pa.state = 16
        THEN 'Agreement recreated'
        WHEN pa.state = 17
        THEN 'Agreement signature missing'
        ELSE 'UNKNOWN'
    END     AS "Agreement STATE"
FROM
    PERSONS p
JOIN SATS.ACCOUNT_RECEIVABLES ar
ON ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.ID
AND ar.AR_TYPE = 4
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON pac.CENTER = ar.CENTER
AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
AND pa.ID = pac.ACTIVE_AGR_ID
AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN PAYMENT_CYCLE_CONFIG pcc
ON pa.PAYMENT_CYCLE_CONFIG_ID = pcc.ID
WHERE pcc.ID = 3
AND p.STATUS IN (1,3)
AND pa.STATE NOT IN (5,6,7,10)
AND p.center in ($$scope$$)