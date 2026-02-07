SELECT DISTINCT
    center.id                         AS "ClubId",
    center.NAME                       AS "ClubName",
    p.EXTERNAL_ID			   		AS "MemberExtId",
	p.center || 'p' || p.id           AS "MemberReference",
	CASE p.sex
	WHEN 'M' THEN 'MALE'
	WHEN 'F' THEN 'FEMALE'
	WHEN 'C' THEN 'OTHER'
	END  							AS "Gender",						
	p.firstname                       AS "Firstname",
	p.lastname                        AS "LastName",
	p.ADDRESS1                        AS AddressLine,
    p.ADDRESS2                        AS AddressLine2,
    p.zipcode                         AS "PostalCode",
    p.city                            AS "City",
    p.country   					AS "Country",
	home.txtvalue                      AS "PhoneNumber",
	workphone.txtvalue                 AS "WorkNumber",
	mobile.txtvalue                    AS "MobileNumber",
	email.txtvalue                     AS "Email",
	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "Birthdate",
	pa.REF                             AS "MandateReference",

CASE
        WHEN op.firstname IS NOT NULL
        THEN op.FIRSTNAME
        ELSE NULL
    								END    AS "LegalRepFirstName",

CASE
        WHEN op.firstname IS NOT NULL
        THEN op.LASTNAME
        ELSE NULL
    								END    AS "LegalRepLastName",

CASE
        WHEN op.firstname IS NOT NULL
        THEN TO_CHAR(op.birthdate, 'YYYY-MM-DD')
        ELSE NULL
    								END    AS "LegalRepBirthDate",

CASE
        WHEN op.firstname IS NOT NULL
        THEN op.ADDRESS1
        ELSE NULL
    								END    AS "LegalRepAddressLine",

CASE
        WHEN op.firstname IS NOT NULL
        THEN op.zipcode
        ELSE NULL
    								END    AS "LegalRepPostalCode",

	CASE
        WHEN op.firstname IS NOT NULL
        THEN op.city 
        ELSE NULL
    								END    AS "LegalRepCity",

CASE
        WHEN op.firstname IS NOT NULL
        THEN op.country
        ELSE NULL
    								END    AS "LegalRepCountry",
	
CASE
        WHEN op.firstname IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS "LegalRepMemberReference",


	
	
	
	CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS "PersonType",
    
	TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS 		"MandateCreationdate",
	
   
    CASE pr.request_type
        WHEN 1
        THEN 'payment'
        WHEN 6
        THEN 'representation'
        ELSE 'undefinded'
    END                                AS "Request Type",
    TO_CHAR(pr.req_date, 'YYYY-MM-DD') AS "req date",
    TO_CHAR(pr.due_date, 'YYYY-MM-DD') AS "DueDate",


        ch.name 						AS "ClearingHouse",
    
CASE
        WHEN ch.ctype IN (144,184)
        THEN 'CC'
        WHEN ch.ctype IN (152)
        THEN 'LSV PLUS'
        WHEN ch.ctype IN (145,192)
        THEN 'DD'
        WHEN ch.ctype IN (142)
        THEN 'INV/SO'
        ELSE 'Unknown'
    END                 				AS "PaymentType",


CASE pr.state
WHEN 3 THEN 'Done'
WHEN 12 THEN 'FailedNotSent'
WHEN 17 THEN 'FailedRevoked'
ELSE 'UNKNOWN'  END 				AS "PaymentReqState",
    
    CASE p.status
        WHEN 0
        THEN 'lead'
        WHEN 1
        THEN 'active'
        WHEN 2
        THEN 'inactive'
        WHEN 3
        THEN 'temp inactive'
        WHEN 4
        THEN 'transferred'
        WHEN 5
        THEN 'duplicate'
        WHEN 6
        THEN 'prospect'
        WHEN 7
        THEN 'blocked'
        WHEN 8
        THEN 'anonymized'
        WHEN 9
        THEN 'contact'
        ELSE 'undefined'
    END                               AS "PersonStatus",

CASE p.blacklisted 
WHEN '1' THEN 'Blacklisted' 
WHEN '2' THEN 'Suspended' 
ELSE 'NO' 						END AS "Blacklisted"

FROM
    persons p
JOIN
    CENTERS center
ON
    p.center = center.id

LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center = home.PERSONCENTER
    AND p.id = home.PERSONID
    AND home.name ='_eClub_PhoneHome'

LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
    AND p.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'



LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
    AND cash_ar.CUSTOMERID=p.id
    AND cash_ar.AR_TYPE = 1

LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
    AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
    AND paymentaccount.ACTIVE_AGR_ID = pa.id
    AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid

LEFT JOIN CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse

LEFT JOIN
	PAYMENT_REQUESTS pr
	ON pr.agr_subid = pa.subid
	
	
LEFT JOIN  payment_cycle_config pcc
ON
pcc.ID = pa.payment_cycle_config_id

 ---payer---

LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter = p.center
    AND op_rel.relativeid = p.id
    AND op_rel.RTYPE = 12 ---paid for by me---
    AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS op
ON
    op.center = op_rel.center
    AND op.id = op_rel.id

LEFT JOIN
    ACCOUNT_RECEIVABLES otherPayerAR
ON
    otherPayerAR.CUSTOMERCENTER = op.center
    AND otherPayerAR.CUSTOMERID = op.id
    AND otherPayerAR.AR_TYPE = 4
   

WHERE
    p.center IN ($$scope$$)
	AND p.status NOT IN (5,8)   --not duplicate Anonymised---
	AND ch.ctype IN (145,192) ---DD---
AND pr.state NOT IN (12)  ---FAILED NOT SENT---
AND pr.REQUEST_TYPE IN(1,6)
AND pr.REQ_DATE >= :ReqDateFrom
AND pr.REQ_DATE <= :ReqDateTo

            
        

