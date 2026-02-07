SELECT
COUNT(p.CENTER),
ch.NAME,
DECODE(pagr.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') state
FROM
PERSONS p
JOIN ACCOUNT_RECEIVABLES ar
ON
ar.CUSTOMERCENTER = p.CENTER
AND ar.CUSTOMERID = p.ID
JOIN PAYMENT_ACCOUNTS pa
ON
pa.CENTER = ar.CENTER
AND pa.ID = ar.ID
JOIN PAYMENT_AGREEMENTS pagr
ON
pagr.CENTER = pa.ACTIVE_AGR_CENTER
AND pagr.ID = pa.ACTIVE_AGR_ID
AND pagr.SUBID = pa.ACTIVE_AGR_SUBID
JOIN CLEARINGHOUSES ch
ON
ch.ID = pagr.CLEARINGHOUSE
WHERE
p.STATUS IN (1)and p.center in (:scope) 
and pagr.CREATION_TIME between :start_time and :end_time
AND ar.AR_TYPE = 4
GROUP BY
pagr.STATE,
ch.NAME
ORDER BY
pagr.STATE