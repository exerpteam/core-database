-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.txtvalue AS PersonId,
        p.center AS NewPersonCenter,
        p.firstname AS FirstName,
        p.lastname AS LastName,
        p.birthdate AS BirthDate,
        p.sex AS Gender,
        p.address1 AS AddressLine1,
        p.address2 AS AddressLine2,
        p.address3 AS AddressLine3,
        p.zipcode AS Zipcode,
        p.city AS City,
        p.country AS Country,
        email.txtvalue AS Email,
        com.txtvalue AS PersonComment,
        (CASE p.persontype 
                WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' 
                WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' 
                WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' 
                WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' 
                ELSE 'Undefined' 
        END) AS PersonType,
        (CASE WHEN barcode.id IS NOT NULL THEN 'BARCODE' ELSE NULL END) AS MembercardType1,
        barcode.identity AS MembercardId1,
        (CASE WHEN rfid.id IS NOT NULL THEN 'RFID' ELSE NULL END) AS MembercardType2,
        rfid.identity AS MembercardId2,
        comp.SSN AS CompanyId,
        cag.name AS CompanyAgreementName,
        ch_nl.txtvalue AS AllowNewsLetter, 
        ch_tpo.txtvalue AS AllowThirdPartyOffers,
        ch_email.txtvalue AS AllowChannelEmail,
        ch_sms.txtvalue AS AllowChannelSMS,
        ch_phone.txtvalue AS AllowChannelPhone,
        ch_letter.txtvalue AS AllowChannelLetter,
        (CASE p.BLACKLISTED WHEN 0 THEN 'NONE' WHEN 1 THEN 'Blacklisted' WHEN 2 THEN 'Suspended' WHEN 3 THEN 'Blocked' END) AS BlackListed,
        emergPhone.txtvalue AS EmergencyContactNumber,
        emergName.txtvalue AS EmergencyContactName,
        p.external_id AS ExternalId,
        (CASE p.status 
                WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' 
        END) AS Exerp_person_status
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN evolutionwellness.person_ext_attrs email ON p.center = email.personcenter AND p.id = email.personid AND email.name = '_eClub_Email'
LEFT JOIN evolutionwellness.person_ext_attrs com ON p.center = com.personcenter AND p.id = com.personid AND com.name = '_eClub_Comment'
LEFT JOIN evolutionwellness.entityidentifiers barcode ON barcode.ref_center = p.center AND barcode.ref_id = p.id AND barcode.idmethod=1 
LEFT JOIN evolutionwellness.entityidentifiers rfid ON rfid.ref_center = p.center AND rfid.ref_id = p.id AND rfid.idmethod=4
LEFT JOIN evolutionwellness.relatives relcom ON relcom.relativecenter = p.center AND relcom.relativeid = p.id AND relcom.rtype = 2
LEFT JOIN evolutionwellness.persons comp ON relcom.center = comp.center AND relcom.id = comp.id
LEFT JOIN evolutionwellness.relatives relcomagr ON relcomagr.center = p.center AND relcomagr.id = p.id AND relcomagr.rtype = 3
LEFT JOIN evolutionwellness.companyagreements cag ON relcomagr.relativecenter = cag.center AND relcomagr.relativeid = cag.id AND relcomagr.relativesubid = cag.subid
LEFT JOIN evolutionwellness.person_ext_attrs ch_nl ON p.center = ch_nl.personcenter AND p.id = ch_nl.personid AND ch_nl.name = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN evolutionwellness.person_ext_attrs ch_tpo ON p.center = ch_tpo.personcenter AND p.id = ch_tpo.personid AND ch_tpo.name = 'eClubIsAcceptingThirdPartyOffers'
LEFT JOIN evolutionwellness.person_ext_attrs ch_email ON p.center = ch_email.personcenter AND p.id = ch_email.personid AND ch_email.name = '_eClub_AllowedChannelEmail'
LEFT JOIN evolutionwellness.person_ext_attrs ch_sms ON p.center = ch_sms.personcenter AND p.id = ch_sms.personid AND ch_sms.name = '_eClub_AllowedChannelSMS'
LEFT JOIN evolutionwellness.person_ext_attrs ch_phone ON p.center = ch_phone.personcenter AND p.id = ch_phone.personid AND ch_phone.name = '_eClub_AllowedChannelPhone'
LEFT JOIN evolutionwellness.person_ext_attrs ch_letter ON p.center = ch_letter.personcenter AND p.id = ch_letter.personid AND ch_letter.name = '_eClub_AllowedChannelLetter'
LEFT JOIN evolutionwellness.person_ext_attrs emergName ON p.center = emergName.personcenter AND p.id = emergName.personid AND emergName.name = 'SGEmergencyContactName'
LEFT JOIN evolutionwellness.person_ext_attrs emergPhone ON p.center = emergPhone.personcenter AND p.id = emergPhone.personid AND emergPhone.name = 'SGEmergencyContactPhone'
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')