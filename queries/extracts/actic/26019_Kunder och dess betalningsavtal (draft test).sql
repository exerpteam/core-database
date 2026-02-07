SELECT
    per.center || 'p' || per.id personid,
	per.FIRSTNAME,
	per.LASTNAME,
	per.ssn,
	pa.CREDITOR_ID,
	pa.BANK_REGNO,
	pa.BANK_ACCNO,
	pa.REF,
    DECODE (pa.STATE, 1,'Created', 2,'Sent', 3,'Incorrect Account', 4,'Ok', 5,'Account closed', 6,'Cancelled','UNKNOWN') AGREEMENTSTATE,
	TO_CHAR(longToDate(pa.CREATION_TIME), 'YYYY-MM-DD')		AS PA_CreationTime,
    prod.NAME PRODUCTNAME,
	sub.CENTER || 'ss' || sub.ID 							AS SubscriptionID,
    sub.SUBSCRIPTION_PRICE currentMemberPrice,
	sub.BILLED_UNTIL_DATE, 
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') start_DATE,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD') end_DATE,
    DECODE(subType.ST_TYPE, 0, 'CASH', 1, 'EFT') currenttype,
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date


FROM
	PERSONS per
LEFT JOIN SUBSCRIPTIONS sub
ON
	sub.OWNER_CENTER = per.CENTER
	AND sub.OWNER_ID = per.ID
	--AND sub.STATE IN (2,8)
LEFT JOIN SUBSCRIPTIONTYPES subType
ON
    subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
JOIN PRODUCTS prod
ON
    subType.CENTER = prod.CENTER
    AND subType.ID = prod.ID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
	per.CENTER = ar.CUSTOMERCENTER
	AND per.ID = ar.CUSTOMERID
	
LEFT JOIN PAYMENT_ACCOUNTS pacc
ON
	pacc.CENTER = ar.CENTER
	AND pacc.ID = ar.ID

JOIN PAYMENT_AGREEMENTS pa
ON
	pa.CENTER = pacc.ACTIVE_AGR_CENTER
	AND pa.ID = pacc.ACTIVE_AGR_ID
	AND pa.SUBID = pacc.ACTIVE_AGR_SUBID

WHERE
per.center IN (:Scope)


	AND sub.START_DATE <= date '2017-11-30' -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= date '2017-01-01') -- Date


--AND subType.ST_TYPE =1

--AND pa.CREDITOR_ID IN ('AutoGiro', 'Payex')
 


ORDER BY
	per.CENTER,
	per.ID