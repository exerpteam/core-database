SELECT
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    p.SEX,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') pa_state,
    ch.NAME clearing_house,
    sum(art.UNSETTLED_AMOUNT) debt_summed
FROM
    AR_TRANS art
join ACCOUNT_RECEIVABLES ar on ar.CENTER = art.CENTER and ar.ID = art.ID
join PAYMENT_ACCOUNTS pac on pac.CENTER = ar.CENTER and pac.ID = ar.ID
join PAYMENT_AGREEMENTS pa on pa.CENTER = pac.ACTIVE_AGR_CENTER and 
pa.ID = pac.ACTIVE_AGR_ID and 
pa.SUBID = pac.ACTIVE_AGR_SUBID 
join CLEARINGHOUSES ch on ch.ID = pa.CLEARINGHOUSE
join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
WHERE
    art.DUE_DATE < exerpsysdate()
    AND art.UNSETTLED_AMOUNT < 0
	and art.center in (:scope)
group by     
    ar.CUSTOMERCENTER,
    p.SEX,
    pa.STATE,
    ch.NAME,
    ar.CUSTOMERID