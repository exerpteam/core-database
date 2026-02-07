SELECT
        p.firstname,
        p.lastname,
        p.address1,
        p.zipcode,
        p.city,
        email.txtvalue AS email,
        sms.txtvalue AS phone_number
FROM PERSONS p
LEFT JOIN virginactive.person_ext_attrs email ON p.center = email.personcenter AND p.id = email.personid AND email.name = '_eClub_Email'
LEFT JOIN virginactive.person_ext_attrs sms ON p.center = sms.personcenter AND p.id = sms.personid AND sms.name = '_eClub_PhoneSMS'
WHERE 
        p.status IN (1,3)
        AND p.persontype = 0
        AND p.center IN (:scope)