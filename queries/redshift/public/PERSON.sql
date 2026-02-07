SELECT
    p.EXTERNAL_ID AS "ID",
    p.CENTER         "HOME_CENTER_ID",
    p.ID             "HOME_CENTER_PERSON_ID",
    CASE
        WHEN p.CURRENT_PERSON_CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
        OR  p.CURRENT_PERSON_ID != p.TRANSFERS_CURRENT_PRS_ID
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.CURRENT_PERSON_CENTER
                AND ID = p.CURRENT_PERSON_ID)
        ELSE NULL
    END                 AS "DUPLICATE_OF_PERSON_ID",
    salutation.TXTVALUE AS "TITLE",
    p.COUNTRY              "COUNTRY_ID",
    p.ZIPCODE              "POSTAL_CODE",
    p.CITY AS              "CITY",
    p.BIRTHDATE            "DATE_OF_BIRTH",
    CASE
        WHEN p.SEX = 'M'
        THEN 'MALE'
        WHEN p.SEX = 'F'
        THEN 'FEMALE'
        ELSE 'UNKNOWN'
    END                                                   AS "GENDER",
   CASE 
	WHEN p.PERSONTYPE = 0 THEN 'PRIVATE'
	WHEN p.PERSONTYPE = 1 THEN 'STUDENT'
	WHEN p.PERSONTYPE = 2 THEN 'STAFF'
	WHEN p.PERSONTYPE = 3 THEN 'FRIEND'
	WHEN p.PERSONTYPE = 4 THEN 'CORPORATE'
	WHEN p.PERSONTYPE = 5 THEN 'ONEMANCORPORATE'
	WHEN p.PERSONTYPE = 6 THEN 'FAMILY'
	WHEN p.PERSONTYPE = 7 THEN 'SENIOR'
	WHEN p.PERSONTYPE = 8 THEN 'GUEST'
	WHEN p.PERSONTYPE = 9 THEN 'CHILD'
	WHEN p.PERSONTYPE = 10 THEN 'EXTERNAL_STAFF'
	ELSE 'UNKNOWN'
   END AS "PERSON_TYPE",
   CASE 
	WHEN p.STATUS = 0 THEN 'LEAD'
	WHEN p.STATUS = 1 THEN 'ACTIVE'
	WHEN p.STATUS = 2 THEN 'INACTIVE'
	WHEN p.STATUS = 3 THEN 'TEMPORARYINACTIVE'
	WHEN p.STATUS = 4 THEN 'TRANSFERED'
	WHEN p.STATUS = 5 THEN 'DUPLICATE'
	WHEN p.STATUS = 6 THEN 'PROSPECT'
	WHEN p.STATUS = 7 THEN 'DELETED'
	WHEN p.STATUS = 8 THEN 'ANONYMIZED'
	WHEN p.STATUS = 9 THEN 'CONTACT'
	ELSE 'UNKNOWN'
    END AS "PERSON_STATUS",  
    to_date(creationDate.TXTVALUE,'yyyy-MM-dd')           AS "CREATION_DATE",
    CASE
        WHEN payer.SEX != 'C'
        THEN
            CASE
                WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                    OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                ELSE payer.EXTERNAL_ID
            END
        ELSE NULL
    END AS "PAYER_PERSON_ID",
    CASE
        WHEN payer.SEX = 'C'
        THEN
            CASE
                WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                    OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                ELSE payer.EXTERNAL_ID
            END
        ELSE NULL
    END AS              "PAYER_COMPANY_ID",
    company.EXTERNAL_ID "COMPANY_ID",
    z.COUNTY   AS         "COUNTY",
    z.PROVINCE AS         "STATE",
    CAST(
        CASE
            WHEN UPPER(channelEmail.TXTVALUE) = 'TRUE'
            THEN 1
            ELSE 0
        END AS SMALLINT) AS "CAN_EMAIL",
    CAST(
        CASE
            WHEN UPPER(channelSMS.TXTVALUE) = 'TRUE'
            THEN 1
            ELSE 0
        END AS SMALLINT) AS     "CAN_SMS",
    p.CENTER             AS     "CENTER_ID",
    p.LAST_MODIFIED             "ETS",
    --GREATEST(p.LAST_MODIFIED, channelSMS.LAST_EDIT_TIME, channelEmail.LAST_EDIT_TIME)    AS "ETS",    
    staffExternalId.TXTVALUE AS "STAFF_EXTERNAL_ID",
    employeeTitle.TXTVALUE   AS "EMPLOYEE_TITLE",
    CASE
        WHEN p.BLACKLISTED = 0
        THEN 'NONE'
        WHEN p.BLACKLISTED = 1
        THEN 'BLACKLISTED'
        WHEN p.BLACKLISTED = 2
        THEN 'SUSPENDED'
        WHEN p.BLACKLISTED = 3
        THEN 'BLOCKED'
    END AS "BLACKLISTED",
 legacyPersonId.TXTVALUE   AS "LEGACY_PERSON_ID",
 p.last_active_start_date  AS "LAST_ACTIVE_START_DATE",
 p.last_active_end_date    AS "LAST_ACTIVE_END_DATE"
FROM
    PERSONS p
JOIN
    PERSONS dup_of
ON
    dup_of.CENTER = p.CURRENT_PERSON_CENTER
AND dup_of.ID = p.CURRENT_PERSON_ID
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER = p.CENTER
AND op_rel.RELATIVEID = p.ID
AND op_rel.RTYPE = 12
AND op_rel.STATUS < 3
LEFT JOIN
    persons payer
ON
    payer.CENTER = op_rel.CENTER
AND payer.ID = op_rel.ID
LEFT JOIN
    RELATIVES com_rel
ON
    com_rel.RELATIVECENTER = p.CENTER
AND com_rel.RELATIVEID = p.ID
AND com_rel.RTYPE = 2
AND com_rel.STATUS < 3
LEFT JOIN
    persons company
ON
    company.CENTER = com_rel.CENTER
AND company.ID = com_rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS creationDate
ON
    creationDate.personcenter = p.center
AND creationDate.personid = p.id
AND creationDate.name = 'CREATION_DATE'
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = p.COUNTRY
AND z.ZIPCODE = p.ZIPCODE
AND z.CITY = p.CITY
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
AND p.id=channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
AND p.id=salutation.PERSONID
AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS staffExternalId
ON
    p.center=staffExternalId.PERSONCENTER
AND p.id=staffExternalId.PERSONID
AND staffExternalId.name='_eClub_StaffExternalId'
LEFT JOIN
    PERSON_EXT_ATTRS employeeTitle
ON
    p.center=employeeTitle.PERSONCENTER
AND p.id=employeeTitle.PERSONID
AND employeeTitle.name='_eClub_EmployeeTitle'
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
WHERE
    p.SEX != 'C'
AND p.EXTERNAL_ID IS NOT NULL
