SELECT
    p.CENTER || 'p' || p.id AS "Person key",
    p.FULLNAME,
    DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,
    'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Person Type",
    DECODE (p.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 5
    ,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown') AS
    "Person status",
    pa.REF,
    pa.NOTIFY_PAYMENT,
    pa.ACTIVE,
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
    ,ch.NAME AS "Clearing house name"
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
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
JOIN SATS.CENTERS c
ON
        c.id = p.center
WHERE
    c.COUNTRY = 'NO'
AND pa.NOTIFY_PAYMENT = 1
AND p.STATUS NOT IN (4,5,7,8)
AND c.ID in ($$scope$$)