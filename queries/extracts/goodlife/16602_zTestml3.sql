WITH
    PARAMS AS
    (
        SELECT
            CASE
                WHEN $$offset$$=-1
                THEN 0
                ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
            END AS FROMDATE,
--             CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS TODATE
             CAST((CURRENT_DATE+31-$$offset$$-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS TODATE
    )
SELECT DISTINCT
    p.external_id AS ExternalId,
    p.center || 'p' || p.id AS PersonId,
    p.firstname AS Firstname,
    p.lastname AS Lastname,
    p.ADDRESS1 AS "Home Address Line 1",
    p.ADDRESS2 AS "Home Address Line 2",
    p.ADDRESS3 AS "Home Address Line 3",
    p.city AS "Home City",
    zipcode.province AS "Home Province",
    p.zipcode AS "Postal Code",
    p.sex AS Gender,
    TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS Birthdate,
    home.txtvalue AS "Home Phone",
    mobile.txtvalue AS "Mobile Phone",
    workphone.txtvalue AS "Work Phone",
    barcode.IDENTITY AS Barcode,
    rfid.IDENTITY AS RFID,
    p.center AS "Home Club Number",
    TO_CHAR(longtodatec(p.last_modified, p.center), 'YYYY-MM-DD HH24:MI') AS "Last Updated Time",
    p.middlename AS "Middle Name",
    driverLicence.txtvalue AS "Drivers License Number",
    p.country AS "Home Country",
    email.txtvalue AS "Email",
    emergencyPhone.txtvalue AS "Emergency Phone Number",
    emergencyPerson.txtvalue AS "Emergency Contact Person",
    emailNewsLetter.txtvalue AS "Allow News Letter",
    thirdPartyOffers.txtvalue AS "Allow Third Party Offers",
    channelEmail.txtvalue AS "Allow Channel Email",
    channelSMS.txtvalue AS "Allow Channel SMS",
    channelPhone.txtvalue AS "Allow Channel Phone",
    channelLetter.txtvalue AS "Allow Channel Letter",
    isVIP.txtvalue AS "Is VIP",
    OldPersonID.txtvalue AS "Legacy Member Number"
FROM
    persons p
CROSS JOIN
    params
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
    AND zipcode.zipcode = p.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS driverLicence
ON
    p.center=driverLicence.PERSONCENTER
    AND p.id=driverLicence.PERSONID
    AND driverLicence.name='DRIVERSLICENSE'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS emergencyPhone
ON
    p.center=emergencyPhone.PERSONCENTER
    AND p.id=emergencyPhone.PERSONID
    AND emergencyPhone.name='EMERGENCYPHONE'
LEFT JOIN
    PERSON_EXT_ATTRS emergencyPerson
ON
    p.center=emergencyPerson.PERSONCENTER
    AND p.id=emergencyPerson.PERSONID
    AND emergencyPerson.name='EMERGENCYNAME'
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
    AND emailNewsLetter.name='eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    p.center=thirdPartyOffers.PERSONCENTER
    AND p.id=thirdPartyOffers.PERSONID
    AND thirdPartyOffers.name='eClubIsAcceptingThirdPartyOffers'
LEFT JOIN
    PERSON_EXT_ATTRS isVIP
ON
    p.center=isVIP.PERSONCENTER
    AND p.id=isVIP.PERSONID
    AND isVIP.name='PTCHAMPION'
LEFT JOIN
    PERSON_EXT_ATTRS OldPersonID
ON
    p.center=OldPersonID.PERSONCENTER
    AND p.id=OldPersonID.PERSONID
    AND OldPersonID.name='_eClub_OldSystemPersonId'
LEFT JOIN
    ENTITYIDENTIFIERS rfid
ON
    rfid.IDMETHOD = 4
    AND rfid.ENTITYSTATUS = 1
    AND rfid.REF_CENTER=p.CENTER
    AND rfid.REF_ID = p.ID
    AND rfid.REF_TYPE = 1
LEFT JOIN
    ENTITYIDENTIFIERS barcode
ON
    barcode.IDMETHOD = 1
    AND barcode.ENTITYSTATUS = 1
    AND barcode.REF_CENTER=p.CENTER
    AND barcode.REF_ID = p.ID
    AND barcode.REF_TYPE = 1
WHERE
    p.center IN ($$scope$$)
    AND p.last_modified BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
	-- Exclude transfered members
    AND p.center = p.transfers_current_prs_center
    AND p.id = p.transfers_current_prs_id	
	-- Exclude fake CARE MEMBERS
	AND (p.center,p.id) not in (
		(990,8802), 
		(990,8803), 
		(990,8804), 
		(990,8805), 
		(990,8806), 
		(990,8807),
(100,2001),
(100,2002),
(100,1405),
(100,1407),
(100,1410),
(100,1411),
(100,1412),
(100,1413),
(100,1601),
(100,1602),
(100,1804),
(100,1803)
	)
