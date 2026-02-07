SELECT DISTINCT
    
    center.id                          AS "ClubId",
    center.NAME                        AS "ClubName",
    p.EXTERNAL_ID			   		AS "MemberExtId",
	p.center || 'p' || p.id            AS "MemberReference",
	CASE p.sex
	WHEN 'M' THEN 'MALE'
	WHEN 'F' THEN 'FEMALE'
	WHEN 'C' THEN 'OTHER'
	END  								AS "Gender",						
	p.firstname                        AS "Firstname",
	p.lastname                         AS "LastName",
	p.ADDRESS1                         AS AddressLine,
    p.ADDRESS2                         AS AddressLine2,
    p.zipcode                          AS "PostalCode",
    p.city                             AS "City",
     p.country   						AS "Country",
home.txtvalue                      AS "PhoneNumber",
workphone.txtvalue                 AS "WorkNumber",
mobile.txtvalue                    AS "MobileNumber",
email.txtvalue                     AS "Email",
	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "Birthdate",
	
	pa.REF                             AS "MandateReference",

CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME
        ELSE NULL
    								END    AS "LegalRepFirstName",

CASE
        WHEN op.center IS NOT NULL
        THEN op.LASTNAME
        ELSE NULL
    								END    AS "LegalRepLastName",

CASE
        WHEN op.center IS NOT NULL
        THEN TO_CHAR(op.birthdate, 'YYYY-MM-DD')
        ELSE NULL
    								END    AS "LegalRepBirthDate",

CASE
        WHEN op.center IS NOT NULL
        THEN op.ADDRESS1
        ELSE NULL
    								END    AS "LegalRepAddressLine",

CASE
        WHEN op.center IS NOT NULL
        THEN op.zipcode
        ELSE NULL
    								END    AS "LegalRepPostalCode",

	CASE
        WHEN op.center IS NOT NULL
        THEN op.city 
        ELSE NULL
    								END    AS "LegalRepCity",

CASE
        WHEN op.center IS NOT NULL
        THEN op.country
        ELSE NULL
    								END    AS "LegalRepCountry",
	
CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS "LegalRepMemberReference",


	

	CASE WHEN
	op.FIRSTNAME IS NOT NULL
	THEN 'YES'
	ELSE 'NO'
	END AS "PaysFor",
	
	
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
    
	
	  ch.name 						AS "ClearingHouse",
		pa.active AS "PaDefault",
    
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
    p.center = home.personcenter
    AND p.id = home.personid
    AND home.name = '_eClub_PhoneHome'
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

 ---payer---

LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12 ---paid for by me---
    AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS op
ON
    op.center = op_rel.center
    AND op.id = op_rel.id

LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar ---left join link to op instead of p----
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER = p.center
    AND cash_ar.CUSTOMERID = p.id
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

---trying to add the missing---

LEFT JOIN
    ACCOUNT_RECEIVABLES payment_arop ---left join link to op instead of p----
ON
    payment_arop.CUSTOMERCENTER = op.center
    AND payment_arop.CUSTOMERID = op.id
    AND payment_arop.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_arop
ON
    cash_arop.CUSTOMERCENTER = op.center
    AND cash_arop.CUSTOMERID = op.id
    AND cash_arop.AR_TYPE = 1

LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccountop
ON
    paymentaccountop.center = payment_ar.center
    AND paymentaccountop.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS paop
ON
    paymentaccount.ACTIVE_AGR_CENTER = paop.center
    AND paymentaccount.ACTIVE_AGR_ID = paop.id
    AND paymentaccount.ACTIVE_AGR_SUBID = paop.subid


LEFT JOIN CLEARINGHOUSES chop
ON
    chop.ID = pa.clearinghouse


---company----


LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center = p.center
    AND comp_rel.id = p.id
    AND comp_rel.RTYPE = 3
    AND comp_rel.STATUS < 3


WHERE
    p.center IN ($$scope$$)
	AND p.status NOT IN (4,5,7,8)   ---trans dup del anon---
	AND (chop.ctype IN (145,192) ---DD---
OR ch.ctype IN (145,192) ---DD---
)
	AND (paop.active = 1 ---default one--
OR pa.active = 1
)
	
	
          
        

