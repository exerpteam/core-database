-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    cr.CREDITOR_NAME,
 /*   cr.EXTERNAL_CREDITOR_ID pbsnr, */
    replace('' || pr.REQ_AMOUNT, '.', ',') amount,
    pr.REQ_DELIVERY sendt_fil,
    pr.XFR_DELIVERY modt_fil,
    DECODE(pr.STATE, '1', 'New', '2', 'Sent', '3', 'Done', '4', 'Done manual','7','Afvist', '8', 'Cancelled') state
FROM
    ECLUB2.PAYMENT_REQUESTS pr
JOIN ECLUB2.ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
JOIN ECLUB2."CLEARINGHOUSES" ch
ON
    ch.id = pr."CLEARINGHOUSE_ID"
JOIN ECLUB2."CLEARINGHOUSE_CREDITORS" cr
ON
    cr."CREDITOR_ID" = pr."CREDITOR_ID"
WHERE
    pr.REQ_DATE between (:Request_DATE_from) and (:Request_date_to)
	and pr.center in (:centerid)
ORDER BY
    cr.CREDITOR_NAME,
    pr.state