SELECT DISTINCT
	DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') agreement_state, 
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
    SATS.PERSONS p
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    SATS.PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.CENTER
    AND pac.ACTIVE_AGR_ID = pag.ID
    AND pac.ACTIVE_AGR_SUBID = pag.SUBID
JOIN
    sats.CLEARINGHOUSES ch
ON
    ch.ID = pag.CLEARINGHOUSE
JOIN
    sats.CH_AND_PCC_LINK ch_pcc
ON
    ch_pcc.CLEARING_HOUSE_ID = pag.CLEARINGHOUSE
JOIN
    SATS.PAYMENT_CYCLE_CONFIG pcc
ON
    ch_pcc.PAYMENT_CYCLE_ID = pcc.ID
JOIN
    SATS.AREAS a
ON
    ch.SCOPE_ID = a.ID
WHERE
    p.center IN ($$scope$$)
GROUP BY
    ch.id,
    ch.NAME,
    a.NAME,
    pcc.NAME,
	pag.STATE,
    pcc.RENEWAL_POLICY