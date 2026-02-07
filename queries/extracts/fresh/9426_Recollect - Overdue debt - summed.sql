SELECT
    ar.CUSTOMERCENTER center,
    p.SEX,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') pa_state,
    ch.NAME clearing_house,
    SUM(art.UNSETTLED_AMOUNT) debt_summed
FROM
    AR_TRANS art
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
JOIN PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
    art.DUE_DATE < exerpsysdate()
    AND art.UNSETTLED_AMOUNT < 0
	and art.center in (:scope)
GROUP BY
    ar.CUSTOMERCENTER,
    p.SEX,
    pa.STATE,
    ch.NAME