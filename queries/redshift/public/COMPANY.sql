SELECT
    p.EXTERNAL_ID "ID",
    p.center      "HOME_CENTER_ID",
    p.LASTNAME AS "NAME",
    p.COUNTRY     "COUNTRY_ID",
    p.ZIPCODE     "POSTAL_CODE",
    p.CITY AS     "CITY",
    CASE
        WHEN (account_manager.CENTER != account_manager.TRANSFERS_CURRENT_PRS_CENTER
                OR account_manager.id != account_manager.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = account_manager.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = account_manager.TRANSFERS_CURRENT_PRS_ID)
        ELSE account_manager.EXTERNAL_ID
    END "ACCOUNT_MANAGER_PERSON_ID",
    CASE
        WHEN p.STATUS = 7
        THEN 'DELETED'
        ELSE 'ACTIVE'
    END         "STATUS",
    z.COUNTY                   AS "COUNTY",
    z.PROVINCE                 AS "STATE",
    mother_comapny.EXTERNAL_ID AS "PARENT_COMPANY_ID",
    p.SSN                      AS "EXTERNAL_ID",
    p.LAST_MODIFIED            AS "ETS",
	p.CENTER||'p'||p.ID        AS "COMPANY_ID",
	pea.TXTVALUE   			   AS "EMAIL",
	pea2.TXTVALUE   		   AS "MOBILE_PHONE",
	p.ADDRESS1       		   AS "ADDRESS",
	CASE
	WHEN (contact_person.CENTER != contact_person.TRANSFERS_CURRENT_PRS_CENTER
			OR contact_person.id != contact_person.TRANSFERS_CURRENT_PRS_ID )
	THEN
		(
			SELECT
				EXTERNAL_ID
			FROM
				PERSONS
			WHERE
				CENTER = contact_person.TRANSFERS_CURRENT_PRS_CENTER
				AND ID = contact_person.TRANSFERS_CURRENT_PRS_ID)
        ELSE contact_person.EXTERNAL_ID
    END "CONTACT_PERSON"
FROM
    PERSONS p
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 10
    AND rel.STATUS = 1
LEFT JOIN
    PERSONS account_manager
ON
    rel.RELATIVECENTER = account_manager.CENTER
    AND rel.RELATIVEID = account_manager.ID
LEFT JOIN
    RELATIVES rel2
ON
    rel2.CENTER = p.CENTER
    AND rel2.ID = p.ID
    AND rel2.RTYPE = 7
    AND rel2.STATUS = 1
LEFT JOIN
    PERSONS contact_person
ON
    rel2.RELATIVECENTER = contact_person.CENTER
    AND rel2.RELATIVEID = contact_person.ID	
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = p.COUNTRY
    AND z.ZIPCODE = p.ZIPCODE
    AND z.CITY = p.CITY
LEFT JOIN
    RELATIVES mother_comapny_rel
ON
    mother_comapny_rel.RELATIVECENTER = p.CENTER
    AND mother_comapny_rel.RELATIVEID = p.ID
    AND mother_comapny_rel.RTYPE = 6
    AND mother_comapny_rel.STATUS = 1
LEFT JOIN
    PERSONS mother_comapny
ON
    mother_comapny.center = mother_comapny_rel.CENTER
    AND mother_comapny.id = mother_comapny_rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.name ='_eClub_Email'
    AND pea.PERSONCENTER = p.center
    AND pea.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.name ='_eClub_PhoneSMS'
    AND pea2.PERSONCENTER = p.center
    AND pea2.PERSONID =p.id
WHERE
    p.SEX = 'C'
