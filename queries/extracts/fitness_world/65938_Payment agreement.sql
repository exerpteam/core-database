-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID
FROM
    PAYMENT_AGREEMENTS pa
JOIN PAYMENT_ACCOUNTS pacc
ON
    pacc.ACTIVE_AGR_CENTER = pa.CENTER
    AND pacc.ACTIVE_AGR_ID = pa.ID
    AND pacc.ACTIVE_AGR_SUBID = pa.SUBID
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pacc.CENTER
    AND ar.ID = pacc.ID
JOIN Persons p
ON
    ar.CUSTOMERCENTER = P.center
    AND ar.CUSTOMERID = P.id
WHERE
    ar.AR_TYPE = 4
    --AND pa.REF in (agreementRefs)
	AND pa.CREDITOR_ID = 'FW_ADYEN'
	AND pa.PAYMENT_CYCLE_CONFIG_ID = 1009
	AND pa.ACTIVE = 1
	AND pa.ENDED_DATE is null
	AND pa.ENDED_REASON_TEXT is null
	AND ar.CUSTOMERCENTER in (:scope)

