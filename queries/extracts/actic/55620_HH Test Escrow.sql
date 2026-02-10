-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
	CASE relative.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS STATUS,
    center.id,
	center.external_id,                                                                                                                                                 
    center.NAME                                                                                                                                               AS centerName,
    relative.center || 'p' || relative.id                                                                                                                                   AS personid,
    personCreation.txtvalue                                                                                                                                   AS personCreationDate,
    salutation.txtvalue                                                                                                                                       AS title,
    relative.firstname                                                                                                                                               AS firstname,
    relative.MIDDLENAME                                                                                                                                              AS middlename,
    relative.lastname                                                                                                                                                AS lastname,
    relative.ssn                                                                                                                                                     AS ssn,
    TO_CHAR(relative.birthdate, 'YYYY-MM-DD')                                                                                                                        AS birthdate,
    relative.sex                                                                                                                                                     AS gender,
    relative.ADDRESS1                                                                                                                                                AS AddressLine1,
    relative.ADDRESS2                                                                                                                                                AS AddressLine2,
    relative.ADDRESS3                                                                                                                                                AS AddressLine3,
    relative.zipcode                                                                                                                                                 AS zipcode,
    relative.city                                                                                                                                                    AS city,
    zipcode.county                                                                                                                                            AS county,
    relative.country                                                                                                                                                 AS country,
    home.txtvalue                                                                                                                                             AS homephone,
    workphone.txtvalue                                                                                                                                        AS workphone,
    mobile.txtvalue                                                                                                                                           AS mobilephone,
    email.txtvalue                                                                                                                                            AS email,
    personcomment.txtvalue                                                                                                                                    AS personcomment,
    CASE  relative.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
    CASE  channelEmail.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELEMAIL,
    CASE  channelLetter.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                            AS ALLOWEDCHANNELLETTER,
    CASE  channelPhone.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELPHONE,
    CASE  channelSMS.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                               AS ALLOWEDCHANNELSMS,
    CASE  emailNewsLetter.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                          AS ALLOWEDCHANNELNEWSLETTERS,
    CASE  thirdPartyOffers.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                         AS ALLOWEDCHANNELTHIRDPARTYOFFERS,
    NULL               AS RelatedToId,
    '' AS RelatedToName,
    NULL                AS RelatedToCompanyID,
    ''      AS RelatedToCompanyName,
    ''      AS "RelatedToCompany AddressLine1",
    ''      AS "RelatedToCompany AddressLine2",
    ''      AS "RelatedToCompany AddressLine3",       
    ''       AS "RelatedToCompany Zipcode",       
    ''          AS "RelatedToCompany City",       
    ''           AS RelatedToCompanyAgreement,
    cash_ar.balance    AS CashAccountBalance,
    payment_ar.balance AS PaymentAccountBalance,
    NULL AS BarcodeMemberCard,
    NULL AS MagneticMemberCard,
    NULL                                                 AS RFIDMemberCard,
    ch.name                                             AS ClearingHouse,
    pa.REF                                              AS Agreement_referenceid,
    (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.EXAMPLE_REFERENCE
     END) AS KID_NUMBER,
    (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.CLEARINGHOUSE_REF 
     END) AS dd_contractid,      
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.BANK_REGNO 
     END) AS dd_bankreg,                          
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.BANK_BRANCH_NO  
     END) AS dd_bankbranch,
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.BANK_ACCNO  
     END) AS dd_bankaccount,
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.BANK_ACCOUNT_HOLDER  
     END) AS dd_accountholder,
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.EXTRA_INFO  
     END) AS dd_extrainfo,   
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.IBAN  
     END) AS dd_iban,
     (CASE 
        WHEN ch.CTYPE IN (141,184) THEN NULL -- ADYEN_TOKEN , PAYEX
        ELSE pa.bic  
     END) AS dd_bic,   
    TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS Agreement_creationdate,
    (CASE 
        WHEN ch.CTYPE = 184 THEN p.external_id -- ADYEN_TOKEN 
        ELSE NULL  
     END) AS cc_shopperReference, 
     (CASE 
        WHEN ch.CTYPE = 184 THEN pa.CLEARINGHOUSE_REF -- ADYEN_TOKEN 
        ELSE NULL  
     END) AS cc_token,
     (CASE 
        WHEN ch.CTYPE = 184 THEN TO_CHAR(pa.EXPIRATION_DATE, 'YYYY-MM-DD') -- ADYEN_TOKEN 
        ELSE NULL  
     END) AS cc_expiration_date,
    CASE   WHEN pa.STATE IS NULL THEN  NULL  WHEN pa.STATE = 1 THEN 'CREATED'  WHEN pa.STATE = 2 THEN 'SENT'  WHEN pa.STATE = 3 THEN 'FAILED'  WHEN pa.STATE = 4 THEN 'OK'  WHEN pa.STATE = 5 THEN 'ENDED BY DEBITOR''S BANK'  WHEN pa.STATE = 6 THEN  'ENDED BY THE CLEARING HOUSE'  WHEN pa.STATE = 7 THEN 'ENDED BY DEBITOR'  WHEN pa.STATE = 8 THEN 'SHAL BE CANCELLED'  WHEN pa.STATE = 9 THEN 'END REQUEST SENT'  WHEN pa.STATE = 10 THEN  'ENDED BY CREDITOR'  WHEN pa.STATE = 11 THEN 'NO AGREEMENT WITH DEBITOR'  WHEN pa.STATE = 12 THEN 'DEPRECATED'  WHEN pa.STATE = 13 THEN 'NOT NEEDED' WHEN pa.STATE = 14 THEN  'INCOMPLETE' WHEN pa.STATE = 15 THEN  'TRANSFERRED' ELSE 'UNKNOWN' END AS Agreement_state,
    pa.REQUESTS_SENT,
    NULL    AS OTHERPAYERNAME,
    '' AS OTHERPAYERSSN,
    '' AS OTHERPAYERID,
    '' AS otherpayer_address,
    '' AS otherpayer_zipcode,
    '' AS otherpayer_city,
    ''                                              AS otherpayer_dd_referenceid,
    ''                                       AS otherpayer_dd_bankreg,
    ''                                       AS otherpayer_dd_bankaccount,	
    'YES' AS IS_OTHER_PAYER,
    'NO' AS HAS_EFT_SUB,
    'NO' AS HAS_CASH_SUB,
    'NO' AS HAS_CLIP_CARD,
    
    
    
    /*Subscription stuff*/
    ''                           AS MembershipId,
    '' AS CreationDate,
    ''                AS StartDate,
    ''                  AS EndDate,
    
    ''                                        AS GlobalName,
    ''                                            AS Name,
    ''             AS MembershipType,
    '',
    '' bindingenddate,
    '',
    '' AS BilledUntilDate ,
    NULL AS Sponsorship ,
    NULL AS Sponsorship_amount,
    '',
    '',
    '',
    '',
'' AS renewal_policy_override,
    /*End subscription stuff*/
    

	/*PRICE_CHANGE*/
	'' AS price_change_date,
	'' AS price_change,
	'' AS price_change_comment


FROM PERSONS p
LEFT JOIN SUBSCRIPTIONS s 
ON
        s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID

LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
LEFT JOIN PERSONS relative ON
	op_rel.CENTER = relative.CENTER
	AND op_rel.ID = relative.ID
JOIN
    CENTERS center
ON
    relative.center = center.id
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = relative.country
    AND zipcode.zipcode = relative.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    relative.center=salutation.PERSONCENTER
    AND relative.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS personCreation
ON
    relative.center=personCreation.PERSONCENTER
    AND relative.id=personCreation.PERSONID
    AND personCreation.name='CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    relative.center=home.PERSONCENTER
    AND relative.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    relative.center=mobile.PERSONCENTER
    AND relative.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    relative.center=workphone.PERSONCENTER
    AND relative.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    relative.center=email.PERSONCENTER
    AND relative.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS personcomment
ON
    relative.center=personcomment.PERSONCENTER
    AND relative.id=personcomment.PERSONID
    AND personcomment.name='_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    relative.center=channelEmail.PERSONCENTER
    AND relative.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    relative.center=channelLetter.PERSONCENTER
    AND relative.id=channelLetter.PERSONID
    AND channelLetter.name='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    relative.center=channelPhone.PERSONCENTER
    AND relative.id=channelPhone.PERSONID
    AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    relative.center=channelSMS.PERSONCENTER
    AND relative.id=channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS emailNewsLetter
ON
    relative.center=emailNewsLetter.PERSONCENTER
    AND relative.id=emailNewsLetter.PERSONID
    AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    relative.center=thirdPartyOffers.PERSONCENTER
    AND relative.id=thirdPartyOffers.PERSONID
    AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = relative.center
    AND payment_ar.CUSTOMERID = relative.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=relative.center
    AND cash_ar.CUSTOMERID=relative.id
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
    ch.id = pa.CLEARINGHOUSE

WHERE 
 	p.center IN ($$scope$$)
	AND s.STATE IN(2,4,8)
	AND p.PERSONTYPE != 2
    AND p.sex != 'C'
    AND p.persontype NOT IN (8)
	AND relative.STATUS != 1

