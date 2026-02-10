-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.id,
    c.shortname,
    ar.customercenter||'p'||ar.customerid           AS member_id,
    CASE 	WHEN pa.STATE = 1 THEN 'CREATED'
        WHEN pa.STATE = 2 THEN 'SENT'
        WHEN pa.STATE = 3 THEN 'FAILED'
        WHEN pa.STATE = 4 THEN 'OK'
        WHEN pa.STATE = 5 THEN 'ENDED, BANK'
        WHEN pa.STATE = 6 THEN 'ENDED, CLEARING HOUSE'
        WHEN pa.STATE = 7 THEN 'ENDED, DEBTOR'
        WHEN pa.STATE = 8 THEN 'CANCELLED, NOT SENT'
        WHEN pa.STATE = 9 THEN 'CANCELLED, SENT'
        WHEN pa.STATE = 10 THEN 'ENDED, CREDITOR'
        WHEN pa.STATE = 11 THEN 'NO AGREEMENT'
        WHEN pa.STATE = 12 THEN 'CASH PAYMENT'
        WHEN pa.STATE = 13 THEN 'AGREEMENT NOT NEEDED'
        WHEN pa.STATE = 14 THEN 'AGREEMENT INFORMATION INCOMPLETE'
        WHEN pa.STATE = 15 THEN 'TRANSFER'
        WHEN pa.STATE = 16 THEN 'AGREEMENT RECREATED'
        WHEN pa.STATE = 17 THEN 'SIGNATURE MISSING'
        ELSE 'UNDEFINED'
  END 						AS "STATE",
    2804                                            AS new_clearinghouse,
    'Saferpay VAI'                                  AS new_creditor_id,
    dateToLongC(getCenterTime(ar.center),ar.center) AS new_last_modified
FROM
    virginactive.account_receivables ar
JOIN
    virginactive.payment_agreements pa
ON
    pa.center = ar.center
AND pa.id = ar.id
JOIN
    centers c
ON
    c.id = ar.center
WHERE
    ar.ar_type = 4
AND pa.clearinghouse IN(2801,2802)
