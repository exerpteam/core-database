WITH
	PAY_REQUESTS AS
		(
			SELECT
				*
			FROM
				PAYMENT_REQUESTS pr
			WHERE
				pr.req_date = 	(
									SELECT
										MAX(pr_new.req_date)
									FROM
										PAYMENT_REQUESTS pr_new
									WHERE
										pr_new.CENTER = pr.CENTER
									AND	pr_new.ID = pr.ID
									AND     pr_new.state != 8
								)
		)
SELECT
	
    center.id                          AS "CenterId",
    center.NAME                        AS "CenterName",
	p.center || 'p' || p.id            AS "MemberReference",
	p.sex                              AS "Gender",
	p.firstname                        AS "Firstname",
	p.lastname                         AS "LastName",    
	p.ADDRESS1                         AS AddressLine,
    p.ADDRESS2                         AS AddressLine2,
    p.zipcode                          AS "PostalCode",
    p.city                             AS "City",
    p.country                          AS "Country",
	home.txtvalue                      AS "PhoneNumber",
    workphone.txtvalue                 AS "WorkNumber",
    mobile.txtvalue                    AS "MobileNumber",
    email.txtvalue                     AS "Email",
	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "Birthdate",
	pa.REF                             AS "MandateReference",
	TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS "MandateCreationdate",
	pa.REQUESTS_SENT 					AS "RequestsSent",
	
	op.FIRSTNAME 						AS "PaysForFirstName",
	op.LASTNAME 						AS "PaysForLastName",

	TO_CHAR(op.birthdate, 'YYYY-MM-DD') AS "PaysForBirthDate",
	op.ADDRESS1							AS "PaysForAddressLine",
	op.ADDRESS2 						AS "PaysForAddressLine2",
	op.zipcode							AS "PaysForPostalCode",
	op.city								AS "PaysForCity",
	op.country						AS "PaysForCountry",
    
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS "PaysForMemberReference",
    

CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,

---additional----

    comp.fullname           AS "Company",
    
   
    CASE pr.request_type
        WHEN 1
        THEN 'payment'
        WHEN 6
        THEN 'representation'
        ELSE 'undefinded'
    END                                AS "Request Type",
    TO_CHAR(pr.req_date, 'YYYY-MM-DD') AS "req date",
    TO_CHAR(pr.due_date, 'YYYY-MM-DD') AS "DueDate",
    
    ch.name AS "ClearingHouse",
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
    END                 AS "PaymentType",
CASE pr.state
WHEN 3 THEN 'Done'
WHEN 12 THEN 'FailedNotSent'
WHEN 17 THEN 'FailedRevoked'
ELSE 'UNKNOWN'  END AS "PaymentReqState",
    
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
    PAY_REQUESTS pr
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
AND ar.ID = pr.ID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID

JOIN
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

---PAID FOR DETIALS---

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
    ACCOUNT_RECEIVABLES otherPayerAR
ON
    otherPayerAR.CUSTOMERCENTER = op.center
    AND otherPayerAR.CUSTOMERID = op.id
    AND otherPayerAR.AR_TYPE = 4

LEFT JOIN
    (
        SELECT DISTINCT
            rel.center AS PAYER_CENTER,
            rel.id     AS PAYER_ID
        FROM
            PERSONS mem
        JOIN
            SUBSCRIPTIONS sub
        ON
            mem.center = sub.OWNER_CENTER
            AND mem.id = sub.OWNER_ID
            AND sub.STATE IN (2,4,8)
            AND (
                sub.end_date IS NULL
                OR sub.end_date > sub.BILLED_UNTIL_DATE )
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = mem.center
            AND rel.RELATIVEID = mem.id
            AND rel.RTYPE = 12
            AND rel.STATUS < 3
        WHERE
            st.ST_TYPE = 1
            AND mem.persontype NOT IN (2,8) ) pay_for
ON
    pay_for.payer_center = op.center
    AND pay_for.payer_id = op.id
    




LEFT JOIN
    payment_request_specifications prs
ON
    PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID
LEFT JOIN
    AR_TRANS art
ON
    art.payreq_spec_center = prs.CENTER
AND art.payreq_spec_id = prs.ID
AND art.payreq_spec_subid = prs.SUBID
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = art.REF_CENTER
AND invl.ID = art.REF_ID
AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    ACCOUNT_TRANS trans
ON
    trans.center = invl.account_trans_center
AND trans.id= invl.account_trans_id
AND trans.subid= invl.account_trans_subid

LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER ----Member of the company agreement
AND rel.ID = p.ID
AND rel.RTYPE = 3
AND rel.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
AND ca.id = rel.RELATIVEID
AND ca.SUBID = rel.RELATIVESUBID

LEFT JOIN
    PERSONS comp
ON
    comp.center = rel.RELATIVECENTER
AND comp.id = rel.RELATIVEID
LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.center = pr.CENTER
AND pa.id = pr.ID
AND pa.SUBID = pr.AGR_SUBID
LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse
LEFT JOIN
    payment_cycle_config pcc
ON
    pcc.ID = pa.payment_cycle_config_id

                        

WHERE
    prs.CENTER IN (:Center)

AND ch.ctype IN (145,192) ---DD---
---AND pr.state IN (3)  ---DONE---
AND pr.REQUEST_TYPE IN(1,6)
AND pr.REQ_DATE >= :ReqDateFrom
AND pr.REQ_DATE <= :ReqDateTo

    

GROUP BY
center.id,
center.NAME,
p.center,
p.id,
p.sex,
p.lastname,
p.firstname,
p.ADDRESS1,
p.ADDRESS2,
p.zipcode,
p.city,
p.country,
home.txtvalue,
workphone.txtvalue,
mobile.txtvalue,
email.txtvalue,
p.birthdate,
pa.creation_time,
pa.ref,
pa.REQUESTS_SENT,
op.FIRSTNAME,
op.LASTNAME,
op.birthdate,
op.ADDRESS1,
op.ADDRESS2,
op.zipcode,
op.city,
op.country,
op.center,
op.id,
pay_for.PAYER_CENTER,
comp.fullname,
pr.request_type,
pr.req_date,
pr.due_date,
ch.name,
ch.ctype,
pr.state,
p.status

ORDER BY

    p.center,
    p.id,
	pr.req_date,
	pr.due_date
