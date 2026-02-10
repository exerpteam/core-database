-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER || 'p' ||  ar.CUSTOMERID as memberid,
    DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') account_type,
    ch.NAME,
    chc.CREDITOR_NAME,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') as state,
    pa.REF,
    pa.CLEARINGHOUSE_REF,
    ar.BALANCE,
art.amount
    
FROM
    PAYMENT_AGREEMENTS pa
JOIN CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
JOIN CLEARINGHOUSE_CREDITORS chc
ON
    chc.CREDITOR_ID = pa.CREDITOR_ID
JOIN PAYMENT_ACCOUNTS pacc
ON
    pacc.ACTIVE_AGR_CENTER = pa.CENTER
    AND pacc.ACTIVE_AGR_ID = pa.ID
    AND pacc.ACTIVE_AGR_SUBID = pa.SUBID
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pacc.CENTER
    AND ar.ID = pacc.ID
join
ar_trans art
on
art.center = ar.center
and
art.id = ar.id
and
art.collected = 0
WHERE
    pa.CENTER in (:scope)
and pa.active = 1
and balance < 0

