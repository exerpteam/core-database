SELECT 
CUSTOMERCENTER ||'p'|| CUSTOMERID as memberid,
P.firstname,
P.lastname,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS, 
BALANCE, MobilePhone.TxtValue as MobilePhone, HomePhone.TxtValue AS HomePhone,
ccc.STARTDATE as "Debt case startdate"
FROM ACCOUNT_RECEIVABLES 
join persons p
on ACCOUNT_RECEIVABLES.customercenter = P.center and ACCOUNT_RECEIVABLES.customerid=P.id
left JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = ACCOUNT_RECEIVABLES.customercenter
    AND ccc.PERSONID = ACCOUNT_RECEIVABLES.customerid
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1

LEFT JOIN Person_Ext_Attrs MobilePhone ON p.center = MobilePhone.PersonCenter 
AND p.id = MobilePhone.PersonId  AND  MobilePhone.Name = '_eClub_PhoneSMS'  
LEFT JOIN Person_Ext_Attrs HomePhone ON p.center = HomePhone.PersonCenter 
AND p.id = HomePhone.PersonId  AND  HomePhone.Name = '_eClub_PhoneHome'  
WHERE  ACCOUNT_RECEIVABLES.CENTER in  (:center)
and 
ACCOUNT_RECEIVABLES.AR_TYPE = 
:accounttype
and 
	BALANCE <
- :LessThan  