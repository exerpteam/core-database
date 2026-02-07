SELECT DISTINCT
	CASE P.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS STATUS,
    center.id,
	center.external_id,                                                                                                                                                 
    center.NAME                                                                                                                                               AS centerName,
    p.center || 'p' || p.id                                                                                                                                   AS personid,
    personCreation.txtvalue                                                                                                                                   AS personCreationDate,
    salutation.txtvalue                                                                                                                                       AS title,
    p.firstname                                                                                                                                               AS firstname,
    p.MIDDLENAME                                                                                                                                              AS middlename,
    p.lastname                                                                                                                                                AS lastname,
    p.ssn                                                                                                                                                     AS ssn,
    TO_CHAR(p.birthdate, 'YYYY-MM-DD')                                                                                                                        AS birthdate,
    p.sex                                                                                                                                                     AS gender,
    p.ADDRESS1                                                                                                                                                AS AddressLine1,
    p.ADDRESS2                                                                                                                                                AS AddressLine2,
    p.ADDRESS3                                                                                                                                                AS AddressLine3,
    p.zipcode                                                                                                                                                 AS zipcode,
    p.city                                                                                                                                                    AS city,
    zipcode.county                                                                                                                                            AS county,
    p.country                                                                                                                                                 AS country,
    home.txtvalue                                                                                                                                             AS homephone,
    workphone.txtvalue                                                                                                                                        AS workphone,
    mobile.txtvalue                                                                                                                                           AS mobilephone,
    email.txtvalue                                                                                                                                            AS email,
    personcomment.txtvalue                                                                                                                                    AS personcomment,
    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
    CASE  channelEmail.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELEMAIL,
    CASE  channelLetter.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                            AS ALLOWEDCHANNELLETTER,
    CASE  channelPhone.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                             AS ALLOWEDCHANNELPHONE,
    CASE  channelSMS.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                               AS ALLOWEDCHANNELSMS,
    CASE  emailNewsLetter.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                          AS ALLOWEDCHANNELNEWSLETTERS,
    CASE  thirdPartyOffers.txtvalue  WHEN 'true' THEN  1  ELSE 0 END                                                                                                         AS ALLOWEDCHANNELTHIRDPARTYOFFERS,
    CASE
        WHEN pt_rel_p.center IS NOT NULL
        THEN pt_rel_p.center || 'p' || pt_rel_p.id
        ELSE NULL
    END               AS RelatedToId,
    pt_rel_p.fullname AS RelatedToName,
    CASE
        WHEN comp.CENTER IS NOT NULL
        THEN comp.CENTER||'p'||comp.ID
        ELSE NULL
    END                AS RelatedToCompanyID,
    comp.fullname      AS RelatedToCompanyName,
    comp.address1      AS "RelatedToCompany AddressLine1",
    comp.address2      AS "RelatedToCompany AddressLine2",
    comp.address3      AS "RelatedToCompany AddressLine3",       
    comp.zipcode       AS "RelatedToCompany Zipcode",       
    comp.city          AS "RelatedToCompany City",       
    cag.NAME           AS RelatedToCompanyAgreement,
    cash_ar.balance    AS CashAccountBalance,
    payment_ar.balance AS PaymentAccountBalance,
    CASE
        WHEN ei_barcode.ID IS NOT NULL
        THEN ei_barcode.IDENTITY
        ELSE NULL
    END AS BarcodeMemberCard,
    CASE
        WHEN ei_mag.ID IS NOT NULL
        THEN ei_mag.IDENTITY
        ELSE NULL
    END AS MagneticMemberCard,
    CASE
        WHEN ei_rfid.ID IS NOT NULL
        THEN ei_rfid.IDENTITY
        ELSE NULL
    END                                                 AS RFIDMemberCard,
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
    CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME || ' ' || op.LASTNAME
        ELSE NULL
    END    AS OTHERPAYERNAME,
    op.ssn AS OTHERPAYERSSN,
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS OTHERPAYERID,
    op.address1 AS otherpayer_address,
    op.zipcode AS otherpayer_zipcode,
    op.city AS otherpayer_city,
    otherPayerPa.REF                                              AS otherpayer_dd_referenceid,
    otherPayerPa.BANK_REGNO                                       AS otherpayer_dd_bankreg,
    otherPayerPa.BANK_ACCNO                                       AS otherpayer_dd_bankaccount,	
    CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,
    CASE
        WHEN has_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_EFT_SUB,
    CASE
        WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CASH_SUB,
    CASE
        WHEN has_clipcard.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CLIP_CARD,
    
    
    
    --Subscription stuff
    s.center || 'ss' || s.id                           AS MembershipId,
    TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS CreationDate,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                AS StartDate,
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                  AS EndDate,
    
    pd.GLOBALID                                        AS GlobalName,
    pd.name                                            AS Name,
    CASE st.st_type  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'DD' END             AS MembershipType,
    s.BINDING_PRICE,
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD') bindingenddate,
    s.SUBSCRIPTION_PRICE,
    CASE
        WHEN st.st_type = 0
        THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
        ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
    END AS BilledUntilDate ,
    CASE
        WHEN st.ST_TYPE = 1
            AND priv.SPONSORSHIP_NAME IS NOT NULL
        THEN priv.SPONSORSHIP_NAME
        ELSE NULL
    END AS Sponsorship ,
    CASE
        WHEN st.ST_TYPE = 1
            AND priv.SPONSORSHIP_NAME IS NOT NULL
        THEN priv.SPONSORSHIP_AMOUNT
        ELSE NULL
    END AS Sponsorship_amount,
    fh.FreezeFrom,
    fh.FreezeTo,
    fh.FreezeReason,
	s.STATE AS SUBSCRIPTION_STATE,
	s.renewal_policy_override AS renewal_policy_override,
    --End subscription stuff
    

	--PRICE_CHANGE
	sp.from_date AS price_change_date,
	sp.price AS price_change,
	sp.coment AS price_change_comment


FROM
    persons p
JOIN
    CENTERS center
ON
    p.center = center.id
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
    AND zipcode.zipcode = p.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
    AND p.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS personCreation
ON
    p.center=personCreation.PERSONCENTER
    AND p.id=personCreation.PERSONID
    AND personCreation.name='CREATION_DATE'
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
    PERSON_EXT_ATTRS personcomment
ON
    p.center=personcomment.PERSONCENTER
    AND p.id=personcomment.PERSONID
    AND personcomment.name='_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
    AND p.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    p.center=channelLetter.PERSONCENTER
    AND p.id=channelLetter.PERSONID
    AND channelLetter.name='_eClub_AllowedChannelLetter'
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
    PERSON_EXT_ATTRS emailNewsLetter
ON
    p.center=emailNewsLetter.PERSONCENTER
    AND p.id=emailNewsLetter.PERSONID
    AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    p.center=thirdPartyOffers.PERSONCENTER
    AND p.id=thirdPartyOffers.PERSONID
    AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'
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
    ENTITYIDENTIFIERS ei_barcode
ON
    ei_barcode.REF_CENTER = p.CENTER
    AND ei_barcode.REF_ID = p.id
    AND ei_barcode.entitystatus = 1
    AND ei_barcode.idmethod = 1
    AND ei_barcode.ref_type = 1
LEFT JOIN
    ENTITYIDENTIFIERS ei_mag
ON
    ei_mag.REF_CENTER = p.CENTER
    AND ei_mag.REF_ID = p.id
    AND ei_mag.entitystatus = 1
    AND ei_mag.idmethod = 2
    AND ei_mag.ref_type = 1
LEFT JOIN
    ENTITYIDENTIFIERS ei_rfid
ON
    ei_rfid.REF_CENTER = p.CENTER
    AND ei_rfid.REF_ID = p.id
    AND ei_rfid.entitystatus = 1
    AND ei_rfid.idmethod = 4
    AND ei_rfid.ref_type = 1
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
-- other payer	
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
LEFT JOIN
    PAYMENT_ACCOUNTS otherPayerpaymentaccount
ON
    otherPayerpaymentaccount.center = otherPayerAR.center
    AND otherPayerpaymentaccount.id = otherPayerAR.id
LEFT JOIN
    PAYMENT_AGREEMENTS otherPayerPa
ON
    otherPayerpaymentaccount.ACTIVE_AGR_CENTER = otherPayerPa.center
    AND otherPayerpaymentaccount.ACTIVE_AGR_ID = otherPayerPa.id
    AND otherPayerpaymentaccount.ACTIVE_AGR_SUBID = otherPayerPa.subid
    
LEFT JOIN SUBSCRIPTIONS s 
ON
        s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID
LEFT JOIN SUBSCRIPTION_SALES ss ON
        ss.SUBSCRIPTION_CENTER = s.CENTER
        AND ss.SUBSCRIPTION_ID = s.ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER=st.center
    AND s.SUBSCRIPTIONTYPE_ID=st.id
JOIN
    PRODUCTS pd
ON
    st.center=pd.center
    AND st.id=pd.id
LEFT JOIN
    (
        SELECT
            fr.subscription_center,
            fr.subscription_id,
            TO_CHAR(MIN(fr.START_DATE), 'YYYY-MM-DD') AS FreezeFrom,
            TO_CHAR(MAX(fr.END_DATE), 'YYYY-MM-DD')   AS FreezeTo,
            MIN(fr.text)                              AS FreezeReason
		
        FROM
            SUBSCRIPTION_FREEZE_PERIOD fr
        WHERE
            fr.subscription_center IN ($$scope$$)
            AND fr.END_DATE > current_timestamp
	AND fr.state != 'CANCELLED'

        GROUP BY
            fr.subscription_center,
            fr.subscription_id ) fh
ON
    fh.subscription_center = s.center
    AND fh.subscription_id = s.id
LEFT JOIN
    (
        SELECT
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT
        FROM
            relatives car
        JOIN
            COMPANYAGREEMENTS ca
        ON
            ca.center = car.RELATIVECENTER
            AND ca.id = car.RELATIVEID
            AND ca.SUBID = car.RELATIVESUBID
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE='CompanyAgreement'
            AND pg.GRANTER_CENTER=ca.center
            AND pg.granter_id=ca.id
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME!= 'NONE'
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > datetolong(TO_CHAR(current_timestamp, 'YYYY-MM-DD HH24:MM')) )
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        WHERE
            car.RTYPE = 3
            AND car.STATUS < 3
            AND car.center IN ($$scope$$)
        GROUP BY
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT ) priv
ON
    priv.center=p.center
    AND priv.id = p.id
    AND priv.REF_GLOBALID = pd.GLOBALID
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
    -- has eft sub
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 1
            AND sub.STATE IN (2,4,8) ) has_sub
ON
    has_sub.owner_center = p.center
    AND has_sub.owner_id = p.id
    -- has cash sub
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 0
            AND sub.STATE IN (2,4,8) ) has_cash_sub
ON
    has_cash_sub.owner_center = p.center
    AND has_cash_sub.owner_id = p.id
    -- clipcards
LEFT JOIN
    (
        SELECT DISTINCT
            clips.OWNER_CENTER,
            clips.OWNER_ID
        FROM
            clipcards clips
        JOIN
            products pd
        ON
            pd.center = clips.center
            AND pd.id = clips.id
        WHERE
            clips.CLIPS_LEFT > 0
            AND clips.FINISHED = 0
            AND clips.CANCELLED = 0
            AND clips.BLOCKED = 0 ) has_clipcard
ON
    has_clipcard.owner_center = p.center
    AND has_clipcard.owner_id = p.id
    -- get friends, family relation
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
LEFT JOIN subscription_price sp ON
	s.CENTER = sp.SUBSCRIPTION_CENTER
	AND s.ID = sp.SUBSCRIPTION_ID
	AND sp.FROM_DATE > CURRENT_DATE
	AND sp.PRICE != s.SUBSCRIPTION_PRICE
	AND sp.CANCELLED != TRUE

WHERE
    p.center IN ($$scope$$)
	AND s.STATE IN(2,4,8)
	AND p.PERSONTYPE != 2
    AND p.sex != 'C'
    AND p.persontype NOT IN (8)
    AND (
        -- active,temp inactive
        p.status IN (1, 3)
        -- staff if they are other payer
        OR (
            p.persontype = 2
            AND pay_for.PAYER_CENTER IS NOT NULL)		
        -- prospect,contact if they are other payer
        OR (
            p.status IN (6,9)
            AND pay_for.PAYER_CENTER IS NOT NULL)
        -- members having clip card
        OR (
            has_clipcard.OWNER_CENTER IS NOT NULL)        
)

/*UNION ON PERSONS WHO ARE PAYERS BUT NOT ACTIVE MEMBERS*/
UNION ALL

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
    NULL      AS RelatedToCompanyName,
    NULL      AS "RelatedToCompany AddressLine1",
    NULL      AS "RelatedToCompany AddressLine2",
    NULL      AS "RelatedToCompany AddressLine3",       
    NULL       AS "RelatedToCompany Zipcode",       
    NULL          AS "RelatedToCompany City",       
    NULL           AS RelatedToCompanyAgreement,
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
    NULL AS OTHERPAYERID,
    '' AS otherpayer_address,
    '' AS otherpayer_zipcode,
    '' AS otherpayer_city,
    NULL                                              AS otherpayer_dd_referenceid,
    NULL                                       AS otherpayer_dd_bankreg,
    NULL                                       AS otherpayer_dd_bankaccount,	
    'YES' AS IS_OTHER_PAYER,
    'NO' AS HAS_EFT_SUB,
    'NO' AS HAS_CASH_SUB,
    'NO' AS HAS_CLIP_CARD,
    
    
    
    --Subscription stuff
    NULL                           AS MembershipId,
    NULL AS CreationDate,
    NULL                AS StartDate,
    NULL                  AS EndDate,
    
    NULL                                        AS GlobalName,
    NULL                                            AS Name,
    NULL             AS MembershipType,
    0,
    NULL bindingenddate,
    0 AS SUBSCRIPTION_PRICE,
    NULL AS BilledUntilDate ,
    NULL AS Sponsorship ,
    0 AS Sponsorship_amount,
    NULL AS FreezeFrom,
    NULL AS FreezeTo,
    NULL AS FreezeReason,
    3 AS SUBSCRIPTION_STATE,
0 AS renewal_policy_override,
    --End subscription stuff
    

	--PRICE_CHANGE--
	NULL::date AS price_change_date,
	0 AS price_change,
	NULL AS price_change_comment


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
	AND (s.STATE IN(2,4,8) OR p.PERSONTYPE = 2)
    AND p.sex != 'C'
	AND p.persontype NOT IN (8)
--	AND (relative.STATUS != 1 OR p.PERSONTYPE = 2)


