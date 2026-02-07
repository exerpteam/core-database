SELECT
    c.SHORTNAME             AS "Club Name",
    p.CENTER || 'p' || p.ID AS "P Number",
    p.FULLNAME              AS "Lead name",
    mobile.TXTVALUE         AS "Mobile phone number"
FROM
    PERSONS p
JOIN
    PERSON_EXT_ATTRS pea
ON
    p.CENTER = pea.PERSONCENTER
    AND p.ID = pea.PERSONID
    AND pea.NAME='CREATION_DATE'
JOIN
    CENTERS c
ON
    p.CENTER = c.ID
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.CENTER = mobile.PERSONCENTER
    AND p.ID = mobile.PERSONID
    AND mobile.NAME='_eClub_PhoneSMS'
WHERE
    p.center IN (:scope)
    AND p.STATUS=0
    AND pea.TXTVALUE=TO_CHAR(CURRENT_TIMESTAMP-1,'yyyy-mm-dd')
    AND mobile.TXTVALUE IS NOT NULL
    AND p.BLACKLISTED=0