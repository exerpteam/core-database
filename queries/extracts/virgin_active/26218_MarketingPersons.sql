WITH
    params AS
    (
        SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
    )
SELECT
    biview."PERSON_ID",
    "HOME_CENTER_ID",
    REPLACE("HOME_CENTER_PERSON_ID", ',','') AS "HOME_CENTER_PERSON_ID",
    "DUPLICATE_OF_PERSON_ID",
    "TITLE",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(biPersonDetails.FULLNAME, CHR(13), '[CR]'), CHR(10),
    '[LF]'),';',''),'"','[qt]'), '''' , '') AS "FULL_NAME",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(biPersonDetails.FIRSTNAME, CHR(13), '[CR]'), CHR(10),
    '[LF]'),';',''),'"','[qt]'), '''' , '') AS "FIRSTNAME",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(biPersonDetails.LASTNAME, CHR(13), '[CR]'), CHR(10),
    '[LF]'),';',''),'"','[qt]'), '''' , '') AS "LASTNAME",
    "COUNTRY_ID",
    "POSTAL_CODE",
    "CITY",
    "DATE_OF_BIRTH",
    "GENDER",
    "PERSON_TYPE",
    "PERSON_STATUS",
    "CREATION_DATE",
    "PAYER_PERSON_ID",
    "COMPANY_ID",
    "COUNTY",
    "STATE",
    "CAN_EMAIL",
    "CAN_SMS",
    biview."CENTER_ID",
    UPPER(biThirdParty.TXTVALUE) AS "IS_ACCEPTING_THIRDPARTY_OFFERS",
    UPPER(biEmail.TXTVALUE)      AS "IS_ACCEPTING_EMAIL_NEWSLETTERS"
FROM
    params,
    BI_PERSONS biview
JOIN
    PERSON_EXT_ATTRS biThirdParty
ON
    biThirdParty.personcenter = CAST(biview."HOME_CENTER_ID" AS INT)
AND biThirdParty.personid = CAST(biview."HOME_CENTER_PERSON_ID" AS INT)
AND biThirdParty.name ='eClubIsAcceptingThirdPartyOffers'
JOIN
    PERSON_EXT_ATTRS biEmail
ON
    biEmail.personcenter = CAST(biview."HOME_CENTER_ID" AS INT)
AND biEmail.personid = CAST(biview."HOME_CENTER_PERSON_ID" AS INT)
AND biEmail.name ='eClubIsAcceptingEmailNewsLetters'
JOIN
    PERSONS biPersonDetails
ON
    biPersonDetails.center = CAST(biview."HOME_CENTER_ID" AS INT)
AND biPersonDetails.id = CAST(biview."HOME_CENTER_PERSON_ID" AS INT)
WHERE
    biView."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND biview."CENTER_ID" IN ($$scope$$)