SELECT DISTINCT
    p.center || 'p' || p.id AS personid,
    p.center                AS PersonCenter,
    p.firstname             AS firstname,
    p.MIDDLENAME            AS middlename,
    p.lastname              AS lastname,
    p.fullname ,
    salutation.txtvalue                                                                                                                                       AS salutation,
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
    TO_CHAR(to_date(personCreation.txtvalue, 'YYYY-MM-DD'), 'YYYY-MM-DD')                                                                                     AS personCreationDate,
	CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END                               AS PERSONTYPE,	
    CASE
        WHEN ei_barcode.ID IS NOT NULL
        THEN 'BARCODE'
        WHEN ei_barcode.ID IS NULL
            AND ei_mag.ID IS NOT NULL
        THEN 'MAGNETIC_CARD'
    END AS MembercardType,
    CASE
        WHEN ei_barcode.ID IS NOT NULL
        THEN ei_barcode.IDENTITY
        WHEN ei_barcode.ID IS NULL
            AND ei_mag.ID IS NOT NULL
        THEN ei_mag.IDENTITY
    END                                                           AS membercardid,
    s.center || 'ss' || s.id                                      AS MembershipId,
    TO_CHAR(longtodateC(s.CREATION_TIME, s.center), 'YYYY-MM-DD') AS MembershipCreationDate,
    s.subscription_price                                          AS MembershipPrice,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                           AS MembershipStartDate,
    CASE
        WHEN st.st_type = 0
        THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
        ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
    END                                                                                                                                                                                                        AS MembershipBilledUntilDate ,
	CASE 
		WHEN st.st_type = 0 THEN 'CASH'
		ELSE 'EFT'
	END AS MembershipType,
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                                                                                                                                                                                                        AS MembershipEndDate,
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')                                                                                                                                                                                                        MembershipBindingEndDate,
    pd.name                                                                                                                                                                                                        AS MembershipName,
    pd.GLOBALID                                                                                                                                                                                                        AS MembershipGlobalName,
    CASE pa.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                        AS PaymentAgreementState,
    pa.REQUESTS_SENT                                                                                                                                                                                                        AS PaymentAgreementRequestsSent,
    pa.BANK_ACCOUNT_HOLDER                                                                                                                                                                                                        AS PaymentAgreementBankAccountHolder,
    pcc.name                                                                                                                                                                                                        AS PaymentAgreementPaymentCycle,
    TO_CHAR(longtodateC(pa.CREATION_TIME, pa.center), 'YYYY-MM-DD')                                                                                                                                                                                                        AS PaymentAgreementCreationDate,
    pa.REF                                                                                                                                                                                                        AS PaymentAgreementReferenceId,
    pa.CLEARINGHOUSE_REF                                                                                                                                                                                                        AS PaymentAgreementContractId,
    pa.bank_branch_no                                                                                                                                                                                                        AS PaymentAgreementBankBranch,
    ch.id                                                                                                                                                                                                        AS ClearingHouseId,
    ch.name                                                                                                                                                                                                        AS ClearingHouseName,
    CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME || ' ' || op.LASTNAME
        ELSE NULL
    END AS OTHERPAYERNAME,
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS OTHERPAYERID
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
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
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ENTITYIDENTIFIERS ei_barcode
ON
    ei_barcode.REF_CENTER = p.CENTER
    AND ei_barcode.REF_ID = p.id
    AND ei_barcode.entitystatus = 1
    AND ei_barcode.idmethod = 1
LEFT JOIN
    ENTITYIDENTIFIERS ei_mag
ON
    ei_mag.REF_CENTER = p.CENTER
    AND ei_mag.REF_ID = p.id
    AND ei_mag.entitystatus = 1
    AND ei_mag.idmethod = 2
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
    PAYMENT_CYCLE_CONFIG pcc
ON
    pcc.id = pa.payment_cycle_config_id
LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pa.CLEARINGHOUSE	
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
WHERE
    p.center IN (207, 209, 225)
	AND p.STATUS IN (1,3)
	AND s.STATE IN (2,4,8)