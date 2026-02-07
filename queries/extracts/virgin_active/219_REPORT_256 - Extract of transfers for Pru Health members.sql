SELECT
    scl.CENTER "Old Club",
    p.CENTER "New Club",
    '?' "Pru Entity Number",
    p.SEX "Gender",
    SUBSTR(p.FIRSTNAME,0,1) || SUBSTR(p.LASTNAME,0,1) "Initials",
    p.FULLNAME "Full Name",
    p.BIRTHDATE "Date of Birth",
    p.CENTER || 'p' || p.ID "Exerp Member ID",
    p.ZIPCODE "Address Postcode",
    phone.TXTVALUE "Home Telephone Number",
    mob.TXTVALUE "Mobile Telephone Number",
    'Extended attribute? ' "Plan ID",
    'For just one membership or all?' "Discount",
    'For just one membership or all?' "Monthly MEMBERSHIP Dues Amount",
    longToDateC(scl.BOOK_START_TIME,scl.center) "Effective Date"
FROM
    STATE_CHANGE_LOG scl
JOIN PERSON_EXT_ATTRS attTo
ON
    attTo.PERSONCENTER = scl.CENTER
    AND attTo.PERSONID = scl.ID
    AND attTo.NAME = '_eClub_TransferredToId'
JOIN PERSONS pOld
ON
    pOld.CENTER = scl.CENTER
    AND pOld.ID = scl.ID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_EXT_ATTRS phone
ON
    phone.PERSONCENTER = p.CENTER
    AND phone.PERSONID = p.ID
    AND phone.NAME = '_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS mob
ON
    mob.PERSONCENTER = p.CENTER
    AND mob.PERSONID = p.ID
    AND mob.NAME = '_eClub_PhoneSMS'
WHERE
    scl.ENTRY_TYPE = 1
    AND scl.STATEID = 4
    AND scl.BOOK_START_TIME >= dateToLongC(TO_CHAR(add_months(sysdate,-1),'yyyy-MM') || '-01 00:00',scl.center)
    AND scl.BOOK_START_TIME < dateToLongC(TO_CHAR(sysdate,'yyyy-MM') || '-01 00:00',scl.center)