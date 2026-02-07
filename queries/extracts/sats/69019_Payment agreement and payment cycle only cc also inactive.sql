SELECT DISTINCT
	p.center || 'p' || p.id as medlemsid,
	case
		when pag.center is null then 'NO AGREEMENT'
		else DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete')
	end agreement_state, 
    ch.id   AS "Clearing House ID",
    ch.NAME AS "Clearing House Name",
    a.NAME as "Scope",
    pcc.NAME                                                   AS "Payment Cycle Name",
    DECODE(pcc.RENEWAL_POLICY,4,'Postpaid',5,'Prepaid','else') RENEWAL_POLICY,
    SUM(
        CASE
            WHEN pcc.COMPANY = 1
                AND p.SEX ='C' and p.STATUS in (0,1,3,8)
            THEN 1
            WHEN pcc.COMPANY = 0
                AND p.SEX IN('M',
                             'F') and p.status in (1,3)
            THEN 1
            ELSE 0
        END) AS "Members Count"
FROM
    PERSONS p
left JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4

left JOIN
    PAYMENT_AGREEMENTS pag
 ON
    pag.CENTER = ar.CENTER
    AND pag.ID = ar.ID   

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
p.STATUS not in (4,5,7,8)
and
ch.id in (3417,3412,3413,3414,3415,3416)

GROUP BY
	p.center,p.id,
    ch.id,
    ch.NAME,
    a.NAME,
    pcc.NAME,
	pag.STATE,
    pcc.RENEWAL_POLICY,
	case
		when pag.center is null then 'NO AGREEMENT'
		else DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete')
	end 