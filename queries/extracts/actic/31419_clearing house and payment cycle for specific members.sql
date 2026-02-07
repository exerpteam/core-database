/**
* Creator: Exerp
* ServiceTicket: N/A
* Purpose: Select information om Transaktions and PaymentAgreements for given members.
*/
SELECT DISTINCT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS memberid,
    p.FULLNAME,
    ' any agreement >' AS any_agr,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,
    'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,
    'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,
    'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS agr_state,
    ch.NAME                                                                         AS agr_clearing
    ,
    pcc.NAME                    AS payment_cycle,
    ' active agreement >' AS active_agr,
    DECODE(pa2.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,
    'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,
    'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,
    'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS
                active_agr_state,
    ch2.NAME  AS active_agr_clearing,
    pcc2.NAME AS act_payment_cycle
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.center = ar.center
AND pa.id = ar.id
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id
JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    CLEARINGHOUSES ch
ON
    pa.CLEARINGHOUSE = ch.id
JOIN
    CLEARINGHOUSES ch2
ON
    pa2.CLEARINGHOUSE = ch2.id
JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    pa.PAYMENT_CYCLE_CONFIG_ID = pcc.id
JOIN
    PAYMENT_CYCLE_CONFIG pcc2
ON
    pa2.PAYMENT_CYCLE_CONFIG_ID = pcc2.id
JOIN
    persons p
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
WHERE
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID in (:memberid)