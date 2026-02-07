SELECT
    pcl.id AS "ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS "PERSON_ID",
    CASE
        WHEN pcl.CHANGE_ATTRIBUTE = 'eClubIsAcceptingThirdPartyOffers'
            OR pcl.CHANGE_ATTRIBUTE = 'ACCEPTING_THIRD_PARTY_OFFERS'
        THEN 'IsAcceptingThirdPartyOffers'
        WHEN pcl.CHANGE_ATTRIBUTE = 'eClubIsAcceptingEmailNewsLetters'
            OR pcl.CHANGE_ATTRIBUTE = 'ACCEPTING_EMAIL_NEWS_LETTERS'
        THEN 'IsAcceptingEmailNewsLetters'
        ELSE pcl.CHANGE_ATTRIBUTE
    END               AS "ATTRIBUTE",
    pcl.NEW_VALUE     AS "VALUE",
    pcl.ENTRY_TIME    AS "FROM_DATETIME",
    pcl.PERSON_CENTER AS "CENTER_ID",
    pcl.ENTRY_TIME    AS "ETS",
    CASE WHEN pcl.employee_center IS NOT NULL 
         THEN pcl.employee_center||'emp'||employee_id 
         ELSE null
    END AS "UPDATE_EMPLOYEE_ID",
    pcl.CHANGE_SOURCE   AS "UPDATE_SOURCE",
    pcl.PREVIOUS_ENTRY_ID  AS "PREVIOUS_ENTRY_ID"
FROM
    PERSON_CHANGE_LOGS pcl
JOIN
    PERSONS p
ON
    p.center = pcl.PERSON_CENTER
    AND p.id = pcl.PERSON_ID
    AND p.SEX != 'C'
WHERE
   pcl.CHANGE_ATTRIBUTE <> '_eClub_LastActivityDate'
