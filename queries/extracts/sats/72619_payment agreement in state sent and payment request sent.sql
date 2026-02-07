SELECT DISTINCT
	p.center || 'p' || p.id as medlemsid,
	case
		when pag.center is null then 'NO AGREEMENT'
		else DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete')
	end agreement_state, 
longtodate(pag.CREATION_TIME) as "agreement creation time", 
    ch.id   AS "Clearing House ID",
    ch.NAME AS "Clearing House Name",
    a.NAME as "Scope",
    pcc.NAME                                                   AS "Payment Cycle Name",
    DECODE(pcc.RENEWAL_POLICY,4,'Postpaid',5,'Prepaid','else') RENEWAL_POLICY,
longtodate(pr.ENTRY_TIME) as request_while_state_sent,
pr.REQ_AMOUNT as requested_amount,
DECODE(pr.STATE,1,'New',2,'Sent',3,'Done',4,'Done, manual',5,'Rejected, clearinghouse',6,'Rejected, bank',7,'Rejected, debtor',8,'Cancelled',10,'Reversed, new',11,'Reversed, sent',12,'Failed, not creditor',13,'Reversed, rejected',14,'Reversed, confirmed',17,'Failed, payment revoked',18,'Done Partial',19,'Failed, Unsupported',20,'Require approval',21,'Fail, debt case exists',22,'Failed, timed out','Undefined') as state
 
    
FROM
    PERSONS p
left JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4
left JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
left JOIN
    PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.CENTER
    AND pac.ACTIVE_AGR_ID = pag.ID
    AND pac.ACTIVE_AGR_SUBID = pag.SUBID
and pag.active = 1
left join
PAYMENT_REQUESTS pr
on
pr.center = pag.center
and
pr.id = pag.id

left JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pag.CLEARINGHOUSE
left JOIN
    CH_AND_PCC_LINK ch_pcc
ON
    ch_pcc.CLEARING_HOUSE_ID = pag.CLEARINGHOUSE
left JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    ch_pcc.PAYMENT_CYCLE_ID = pcc.ID
left JOIN
    AREAS a
ON
    ch.SCOPE_ID = a.ID
WHERE
    p.center IN ($$scope$$)
and
p.STATUS not in (0,2,4,5,7,8,9)
and
pag.state = 2
and
pr.ENTRY_TIME > pag.CREATION_TIME
and
pr.REQ_AMOUNT > 0 
and
pr.XFR_INFO != 'PBS FI-kort'
and
pr.state != 12