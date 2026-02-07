SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID                                                                                                                                                                                                        AS MEMBER_ID,
    DECODE (p.status, 0,'Lead', 1,'Active', 2,'Inactive', 3,'Temporary Inactive', 4,'Transfered', 5,'Duplicate', 6,'Prospect', 7,'Deleted',8, 'Anonymized', 9, 'Contact', 'Unknown')                                                                                                                                                                                                        AS PERSON_STATUS,
    pag.CLEARINGHOUSE_REF                                                                                                                                                                                                        AS REFERENCE,
pag.ref,
pag.CREDITOR_ID,
    longtodateC(pag.CREATION_TIME,pag.center)                                                                                                                                                                                                        AS AGREEMENT_CREATION_TIME,
    DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') AS AGREEMENT_STATE,
    r.center||'p'||r.id                                                                                                                                                                                                        AS OTHER_PAYER_ID
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    PAYMENT_ACCOUNTS pa
ON
    pa.center = ar.center
    AND pa.id = ar.id
    AND ar.ar_type = 4
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pa.ACTIVE_AGR_CENTER = pag.center
    AND pa.ACTIVE_AGR_ID = pag.id
    AND pa.ACTIVE_AGR_SUBID = pag.SUBID
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pag.CLEARINGHOUSE
JOIN
    PERSONS p
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
LEFT JOIN
    RELATIVES r
ON
    r.RELATIVECENTER = ar.CUSTOMERCENTER
    AND r.RELATIVEID = ar.CUSTOMERID
    AND r.RTYPE = 12
    AND r.STATUS = 1
WHERE

    pag.BANK_ACCNO IS NULL
    AND ch.CTYPE = 141