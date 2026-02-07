
SELECT DISTINCT
	
    center.id                          AS "ClubId",
    center.NAME                        AS "ClubName",
	p.external_id 					   AS  "MemberExtId",
	p.center || 'p' || p.id            AS "MemberReference",
	p.sex                              AS "Gender",
	CASE WHEN p.sex = 'C' then 'COMPANY'
	ELSE p.firstname
	END					AS	"Firstname",
	--CASE WHEN p.firstname IS NOT NULL THEN p.firstname ELSE 'EMPTY'--
	
	p.lastname                         AS "LastName",    
	CASE WHEN p.ADDRESS1 IS NOT NULL THEN p.ADDRESS1
	ELSE  'EMPTY'
	END                    AS AddressLine,
    p.ADDRESS2                         AS AddressLine2,
    CASE WHEN p.zipcode IS NOT NULL THEN p.zipcode
	ELSE '00000'
	END                       AS "PostalCode",
    CASE WHEN p.city IS NOT NULL THEN p.city
	ELSE   'EMPTY'
	END                         AS "City",
   	CASE WHEN p.country IS NOT NULL THEN p.country
	ELSE 'EMPTY'
	END                       AS "Country",
	home.txtvalue                      AS "PhoneNumber",
    workphone.txtvalue                 AS "WorkNumber",
    mobile.txtvalue                    AS "MobileNumber",
    email.txtvalue                     AS "Email",
	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "Birthdate",
	pa.REF                             AS "MandateReference",
	
	
	op.FIRSTNAME 						AS "PaysForFirstName",
	op.LASTNAME 						AS "PaysForLastName",
	TO_CHAR(op.birthdate, 'YYYY-MM-DD') AS "PaysForBirthDate",
	op.ADDRESS1							AS "PaysForAddressLine",
	op.ADDRESS2 						AS "PaysForAddressLine2",
	op.zipcode							AS "PaysForPostalCode",
	op.city								AS "PaysForCity",
	op.country						    AS "PaysForCountry",
    op.center || 'p' || op.id           AS "PaysForMemberReference",
	
    

---additional----
	CASE WHEN
	op.FIRSTNAME IS NOT NULL
	THEN 'YES'
	ELSE 'NO'
	END AS "PaysFor",
	pr.req_amount as "AmountRequested",
	
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
    comp.fullname           AS "Company",
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
WHEN 2 THEN 'Sent'
WHEN 3 THEN 'Done'
WHEN 8 THEN 'Cancelled'
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
    END                               AS "PersonStatus"
    
FROM
    PAYMENT_REQUESTS pr
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
AND ar.ID = pr.ID

LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.center = pr.CENTER
AND pa.id = pr.ID
AND pa.SUBID = pr.AGR_SUBID

LEFT JOIN payment_request_specifications prs
ON
	prs.center= pr.center
AND prs.id = pr.id

LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse


LEFT JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID




LEFT JOIN
    CENTERS center
ON
    p.center = center.id


LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
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
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
    AND p.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'

LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
    AND p.id=channelPhone.PERSONID
    AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
    AND p.id=channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'

---PAYS FOR DETIALS---

LEFT JOIN
    RELATIVES r
ON 
    r.CENTER = p.CENTER
    AND r.ID = p.ID
	AND r.RTYPE = 12
	AND r.STATUS <3

LEFT JOIN
    PERSONS op
ON
    op.center = r.RELATIVECENTER
    AND op.id = r.RELATIVEID



LEFT JOIN
    RELATIVES C
ON
    C.CENTER = p.CENTER ----Member of the company agreement
AND C.ID = p.ID
AND C.RTYPE = 3
AND C.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = C.RELATIVECENTER
AND ca.id = C.RELATIVEID
AND ca.SUBID = C.RELATIVESUBID

LEFT JOIN
    PERSONS comp
ON
    comp.center = C.RELATIVECENTER
AND comp.id = C.RELATIVEID



                        

WHERE
    pr.CENTER IN (:Center)

AND ch.ctype IN (145,192) ---DD---
AND pr.state NOT IN (8,12)  ---CANCELLED FAILED NOT SENT---
AND p.status NOT IN (8) ---ANONYMISED---
AND pr.REQUEST_TYPE IN(1,6)
AND pr.REQ_DATE >= :ReqDateFrom
AND pr.REQ_DATE <= :ReqDateTo
AND prs.cancelled = 0

