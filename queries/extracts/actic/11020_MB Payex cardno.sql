SELECT
	ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID personid,
	pa.BANK_ACCNO AS CARDNO,
	pa.REF,
    DECODE (pa.STATE, 1,'Created', 2,'Sent', 3,'Incorrect Account', 4,'Ok', 5,'Account closed', 6,'Cancelled','UNKNOWN') AGREEMENTSTATE,
	TO_CHAR(longToDate(pa.CREATION_TIME), 'YYYY-MM-DD')		AS CreationTime

FROM PAYMENT_AGREEMENTS pa

LEFT JOIN PAYMENT_ACCOUNTS pacc
ON
	pa.CENTER = pacc.ACTIVE_AGR_CENTER
	AND pa.ID = pacc.ACTIVE_AGR_ID
--	AND pa.SUBID = pacc.ACTIVE_AGR_SUBID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
	pacc.CENTER = ar.CENTER
	AND pacc.ID = ar.ID
	
WHERE
    pa.center in (:Scope)
	AND pa.CLEARINGHOUSE = 402
ORDER BY
	pa.BANK_ACCNO