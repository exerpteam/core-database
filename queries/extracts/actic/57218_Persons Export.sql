SELECT
    (p.CENTER || 'p' || p.ID) AS PersonId,
    p.CENTER                  AS OldPersonCenter,
    --cm.NewPersonCenter                 AS NewPersonCenter,
    p.center                           AS NewPersonCenter,
    p.FIRSTNAME                        AS FirstName,
    p.MIDDLENAME                       AS MiddleName,
    p.LASTNAME                         AS LastName,
    salutation.TXTVALUE                AS Salutation,
    p.SSN                              AS Ssn,
    TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') AS BirthDate,
    p.SEX                              AS Gender,
    p.ADDRESS1                         AS AddressLine1,
    p.ADDRESS2                         AS AddressLine2,
    p.ADDRESS3                         AS AddressLine3,
    p.ZIPCODE                          AS ZipCode,
    p.CITY                             AS City,
    zip.county                         AS County,
    zip.province                       AS Province,
    p.COUNTRY                          AS Country,
    homePhone.TXTVALUE                 AS HomePhone,
    workPhone.TXTVALUE                 AS WorkPhone,
    mobilePhone.TXTVALUE               AS MobilePhone,
    email.TXTVALUE                     AS Email,
    creationDate.TXTVALUE              AS CreationDate,
    personComment.txtvalue             AS PersonComment,
    --- do we need to set staff pincode to 1234?
    /*(
    CASE
    WHEN p.PERSONTYPE = 2
    THEN '1234'
    ELSE p.PINCODE
    END) AS Pincode,*/
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
        ELSE 'UNKNOWN'
    END AS PersonType,
    --applepass.identity as ApplePasscardId,
    rfcard.identity   AS RfMembercardId,
    magnetic.identity AS MagneticMembercardId,
    pin.identity      AS PinMembercardId,
    barcode.identity  AS BarcodeMembercardId,
    ext_sys.identity  AS ExternalSysMembercardId,
    (
        CASE
            WHEN comp.CENTER IS NULL
            THEN NULL
            ELSE comp.CENTER || 'p' || comp.ID
        END) AS CompanyId,
    (
        CASE
            WHEN compAgr.CENTER IS NULL
            THEN NULL
            ELSE compAgr.RELATIVECENTER || 'p' || compAgr.RELATIVEID || 'rpt' ||
                compAgr.RELATIVESUBID
        END) AS CompanyAgreementId,
    (
        CASE
            WHEN op.CENTER IS NOT NULL
            THEN op.CENTER || 'p' || op.ID
            ELSE NULL
        END) AS OtherPayerId,
    (
        CASE
            WHEN friend.RELATIVECENTER IS NULL
            THEN NULL
            ELSE friend.RELATIVECENTER || 'p'|| friend.RELATIVEID
        END) AS FriendId,
    ------Do we import family relations?
    (
        CASE
            WHEN p.persontype = 6
            AND familyRel.relativecenter IS NOT NULL
            THEN familyRel.relativecenter||'p'||familyRel.relativeid
            ELSE NULL
        END) AS FamilyId,
    -- null as PicturePath,
    (
        CASE
            WHEN allowNewsLetter.txtvalue='true'
            THEN '1'
            ELSE '0'
        END) AS AllowNewsLetter,
    (
        CASE
            WHEN allowThirdParty.txtvalue='true'
            THEN '1'
            ELSE '0'
        END) AS AllowThirdPartyOffers,
    (
        CASE
            WHEN allowEmail.txtvalue='true'
            THEN '1'
            ELSE '0'
        END) AS AllowChannelEmail,
    (
        CASE
            WHEN allowSms.txtvalue='true'
            THEN '1'
            ELSE '0'
        END) AS AllowChannelSMS,
    (
        CASE
            WHEN allowPhone.txtvalue='true'
            THEN '1'
            ELSE '0'
        END) AS AllowChannelPhone,
    (
        CASE
            WHEN allowLetter.txtvalue='true'
            THEN '1'
            ELSE '0'
        END)                AS AllowChannelLetter,
    p.blacklisted::text     AS BlackListed,
    cash_account.debit_max  AS MaxCashDebit,
    cash_account.BALANCE    AS CashAccountBalance,
    payment_account.BALANCE AS PaymentAccountBalance,
    --debt_account.BALANCE    AS DebtAccountBalance,
    (
        CASE
            WHEN p.PERSONTYPE = 2
            THEN 1
            ELSE 0
        END) AS AllowFriends,
    (
        CASE
            WHEN referRel.RELATIVECENTER IS NULL
            THEN NULL
            ELSE referRel.RELATIVECENTER || 'p'|| referRel.RELATIVEID
        END) AS ReferralID
FROM
    PERSONS p
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_account
ON
    cash_account.CUSTOMERCENTER=p.CENTER
AND cash_account.CUSTOMERID=p.ID
AND cash_account.AR_TYPE=1
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_account
ON
    payment_account.CUSTOMERCENTER=p.CENTER
AND payment_account.CUSTOMERID=p.ID
AND payment_account.AR_TYPE=4
LEFT JOIN
    ACCOUNT_RECEIVABLES debt_account
ON
    debt_account.CUSTOMERCENTER=p.CENTER
AND debt_account.CUSTOMERID=p.ID
AND debt_account.AR_TYPE=5
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center= salutation.PERSONCENTER
AND p.ID=salutation.PERSONID
AND salutation.NAME='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS homePhone
ON
    p.CENTER= homePhone.PERSONCENTER
AND p.ID=homePhone.PERSONID
AND homePhone.NAME='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS workPhone
ON
    p.CENTER= workPhone.PERSONCENTER
AND p.ID=workPhone.PERSONID
AND workPhone.NAME='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS mobilePhone
ON
    p.CENTER= mobilePhone.PERSONCENTER
AND p.ID=mobilePhone.PERSONID
AND mobilePhone.NAME='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.CENTER= email.PERSONCENTER
AND p.ID=email.PERSONID
AND email.NAME='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS creationDate
ON
    p.CENTER= creationDate.PERSONCENTER
AND p.ID=creationDate.PERSONID
AND creationDate.NAME='CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS personComment
ON
    p.CENTER= personComment.PERSONCENTER
AND p.ID=personComment.PERSONID
AND personComment.name='_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS allowEmail
ON
    p.center= allowEmail.PERSONCENTER
AND p.ID=allowEmail.PERSONID
AND allowEmail.NAME='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS allowPhone
ON
    p.CENTER =allowPhone.PERSONCENTER
AND p.ID=allowPhone.PERSONID
AND allowPhone.NAME='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS allowSms
ON
    p.CENTER= allowSms.PERSONCENTER
AND p.ID=allowSms.PERSONID
AND allowSms.NAME='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS allowLetter
ON
    p.CENTER= allowLetter.PERSONCENTER
AND p.ID=allowLetter.PERSONID
AND allowLetter.NAME='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS allowNewsLetter
ON
    p.CENTER=allowNewsLetter.PERSONCENTER
AND p.ID=allowNewsLetter.PERSONID
AND allowNewsLetter.NAME='eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS allowThirdParty
ON
    p.CENTER=allowThirdParty.PERSONCENTER
AND p.ID=allowThirdParty.PERSONID
AND allowThirdParty.NAME='eClubIsAcceptingThirdPartyOffers'
LEFT JOIN
    ENTITYIDENTIFIERS rfcard
ON
    rfcard.REF_CENTER=p.CENTER
AND rfcard.REF_ID=p.ID
AND rfcard.ENTITYSTATUS=1
AND rfcard.IDMETHOD=4
AND rfcard.REF_TYPE=1
LEFT JOIN
    ENTITYIDENTIFIERS magnetic
ON
    magnetic.REF_CENTER=p.CENTER
AND magnetic.REF_ID=p.ID
AND magnetic.ENTITYSTATUS=1
AND magnetic.IDMETHOD=2
AND magnetic.REF_TYPE=1
LEFT JOIN
    ENTITYIDENTIFIERS ext_sys
ON
    ext_sys.REF_CENTER=p.CENTER
AND ext_sys.REF_ID=p.ID
AND ext_sys.ENTITYSTATUS=1
AND ext_sys.IDMETHOD=8
AND ext_sys.REF_TYPE=1
LEFT JOIN
    ENTITYIDENTIFIERS pin
ON
    pin.REF_CENTER=p.CENTER
AND pin.REF_ID=p.ID
AND pin.ENTITYSTATUS=1
AND pin.IDMETHOD=5
AND pin.REF_TYPE=1
LEFT JOIN
    ENTITYIDENTIFIERS barcode
ON
    barcode.REF_CENTER=p.CENTER
AND barcode.REF_ID=p.ID
AND barcode.ENTITYSTATUS=1
AND barcode.IDMETHOD=1
AND barcode.REF_TYPE=1
    /*LEFT JOIN
    ENTITYIDENTIFIERS applepass
    ON
    applepass.REF_CENTER=p.CENTER
    AND applepass.REF_ID=p.ID
    AND applepass.ENTITYSTATUS=1
    AND applepass.IDMETHOD=9
    AND applepass.REF_TYPE=1*/
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER=p.CENTER
AND op_rel.RELATIVEID=p.ID
AND op_rel.RTYPE = 12
AND op_rel.STATUS < 3
LEFT JOIN
    RELATIVES comp
ON
    p.CENTER = comp.RELATIVECENTER
AND p.ID = comp.RELATIVEID
AND comp.RTYPE = 2
AND comp.STATUS=1
LEFT JOIN
    RELATIVES compAgr
ON
    p.CENTER = compAgr.CENTER
AND p.ID = compAgr.ID
AND compAgr.RTYPE = 3
AND compAgr.STATUS=1
LEFT JOIN
    RELATIVES familyRel
ON
    p.CENTER = familyRel.CENTER
AND p.ID = familyRel.ID
AND familyRel.RTYPE = 4
AND familyRel.STATUS=1
LEFT JOIN
    RELATIVES referRel
ON
    p.CENTER = referRel.CENTER
AND p.ID = referRel.ID
AND referRel.RTYPE = 13
AND referRel.STATUS=1
LEFT JOIN
    PERSONS op
ON
    op.CENTER = op_rel.CENTER
AND op.ID = op_rel.ID
AND op.center IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
LEFT JOIN
    RELATIVES friend
ON
    p.CENTER = friend.CENTER
AND p.ID = friend.ID
AND friend.RTYPE = 1
AND friend.STATUS=1
LEFT JOIN
    zipcodes zip
ON
    zip.zipcode = p.zipcode
AND zip.country = p.country
AND zip.city = p.city
WHERE
    p.status IN (0,
                 1,
                 2,
                 3,
                 6,
                 9)
AND p.sex != 'C'
AND p.center IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)