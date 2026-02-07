SELECT DISTINCT
    center.id                          AS "CenterId",
    center.NAME                        AS "CenterName",
	p.EXTERNAL_ID			   		AS "ExternalUserId",
    p.center || 'p' || p.id            AS "MemberReference",
	p.sex                              AS Gender,
	p.lastname                         AS "LastName",    
	p.firstname                        AS "Firstname",
    p.ADDRESS1                         AS AddressLine,
    p.ADDRESS2                         AS AddressLine2,
    p.zipcode                          AS "PostalCode",
    p.city                             AS "City",
    p.country                     AS county,
    p.country                          AS country,
    home.txtvalue                      AS "PhoneNumber",
    workphone.txtvalue                 AS "WorkpNumber",
    mobile.txtvalue                    AS "MobileNumber",
    email.txtvalue                     AS "Email",
	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "Birthdate",
	pa.REF                             AS "MandateReference",
	TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS "MandateCreationdate",
	pa.REQUESTS_SENT 					AS "RequestsSent",
	op.FIRSTNAME 						AS "OtherPayerFirstName",
	op.LASTNAME 						AS "OtherPayerLastName",

	TO_CHAR(op.birthdate, 'YYYY-MM-DD') AS "OtherPayerBirthDate",
	op.ADDRESS1							AS "OtherPayerAddressLine",
	op.ADDRESS2 						AS "OtherPayerAddressLine2",
	op.zipcode							AS "OtherPayerPostalCode",
	op.city								AS "OtherPayerCity",
	op.country					AS "OtherPayerCountry",
    
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS "OtherPayerMemberReference",
    

CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,
    
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


    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
    CASE  channelEmail.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELEMAIL,
    
    CASE  channelPhone.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELPHONE,
    CASE  channelSMS.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                               AS ALLOWEDCHANNELSMS,
   
    CASE
        WHEN comp.CENTER IS NOT NULL
        THEN comp.CENTER||'p'||comp.ID
        ELSE NULL
    END                                     AS RelatedToCompanyID,
    comp.lastname                           AS RelatedToCompanyName,
    cag.NAME                                AS RelatedToCompanyAgreement,
    cash_ar.balance                         AS CashAccountBalance,
    payment_ar.balance                      AS PaymentAccountBalance,
    
    
    pa.CLEARINGHOUSE_REF                 AS dd_contractid,
    pa.BANK_REGNO         				 AS dd_bankreg,
    pa.BANK_BRANCH_NO                    AS dd_bankbranch,
    pa.BANK_ACCNO                        AS dd_bankaccount,
    pa.BANK_ACCOUNT_HOLDER               AS  dd_accountholder,
    pa.EXTRA_INFO                        AS dd_extrainfo,
    pa.IBAN                              AS dd_iban
    
        
    
   
FROM
    persons p
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
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
    AND comp_rel.id=p.id
    AND comp_rel.RTYPE = 3
    AND comp_rel.STATUS < 3
LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
    AND cag.id=comp_rel.RELATIVEID
    AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
    AND comp.id=cag.id
LEFT JOIN
    ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.id
    AND ei.entitystatus = 1
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

LEFT JOIN
	payment_requests pr
	ON pr.center = pa.center
	AND pr.agr_subid = pa.subid

LEFT JOIN 
	payment_request_specifications prs
ON 	PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID


LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12
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
    -- other payer
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
    pay_for.payer_center = p.center
    AND pay_for.payer_id = p.id
    
LEFT JOIN
    RELATIVES pt_rel
ON
    pt_rel.CENTER = p.center
    AND pt_rel.id = p.id
    AND pt_rel.STATUS < 3
    AND ( (
            p.PERSONTYPE = 3
            AND pt_rel.RTYPE = 1 )
        OR (
            p.PERSONTYPE = 6
            AND pt_rel.RTYPE = 4 ) )
LEFT JOIN
    PERSONS pt_rel_p
ON
    pt_rel_p.center = pt_rel.RELATIVECENTER
    AND pt_rel_p.id = pt_rel.RELATIVEID
WHERE
    p.center IN ($$scope$$)
	AND pr.req_date >= :ReqDateFrom
    AND pr.req_date <= :ReqDateTo
	AND  p.status  IN (0,1,2,3,6,9)
    