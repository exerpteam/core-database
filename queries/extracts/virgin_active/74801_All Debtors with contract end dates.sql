SELECT 
	
	
	C.Shortname as "Club",
	CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
	p.center||'p'||p.id  as memberid,
	PR.NAME as Subscription,
	S.subscription_price,
	S.Start_date,
	TO_CHAR(s.END_DATE,'yyyy-MM-dd') as End_date,
	TO_CHAR (S.BINDING_END_DATE,'yyyy-MM-dd') as Bind_Date,
	  --(ccc.amount*-1) as debtamount,
   case when ccc.cashcollectionservice is not null
		then 'Yes'
		else 'No' 
   end AS "Sent to debt collection agency",

-- case when ccc.CASHCOLLECTIONSERVICE = 1
-- then 'ARC'
-- Else null
-- end as agency,
	

	ACCOUNT_RECEIVABLES.BALANCE,
CASE 
	ACCOUNT_RECEIVABLES.AR_TYPE WHEN 5 THEN 'Debt collection account' WHEN 4 THEN 'Payment Account' WHEN 1 THEN 'Cash Account' ELSE 'None' END AS Account_Type
	
	--ccc.STARTDATE as "Debt case startdate"
FROM 
	ACCOUNT_RECEIVABLES 
JOIN
	persons p
	on ACCOUNT_RECEIVABLES.customercenter = P.center and ACCOUNT_RECEIVABLES.customerid=P.id
JOIN
	Centers C 
	ON C.ID = P.Center
LEFT JOIN
    CASHCOLLECTIONCASES ccc
	ON
    ccc.PERSONCENTER = ACCOUNT_RECEIVABLES.customercenter
    AND ccc.PERSONID = ACCOUNT_RECEIVABLES.customerid
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
JOIN
    SUBSCRIPTIONS s
    ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)
JOIN
    SUBSCRIPTIONTYPES st
    ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
    ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
 
WHERE  
	ACCOUNT_RECEIVABLES.CENTER in  (:center)

and 
	BALANCE < 0
AND 
	PR.NAME NOT LIKE 'PT%'
