SELECT
    p.EXTERNAL_ID                             AS "PERSON_ID",
    REPLACE(acceptedMaterial.name,'eClub','') AS "TYPE",
    UPPER(acceptedMaterial.TXTVALUE)          AS "VALUE",
    p.CENTER                                  AS "CENTER_ID",
    acceptedMaterial.LAST_EDIT_TIME           AS "ETS"
FROM
    PERSON_EXT_ATTRS acceptedMaterial
JOIN
    PERSONS p
ON
    p.center=acceptedMaterial.PERSONCENTER
AND p.id=acceptedMaterial.PERSONID
WHERE
    acceptedMaterial.name IN('eClubIsAcceptingThirdPartyOffers',
                             'eClubIsAcceptingEmailNewsLetters')
AND p.EXTERNAL_ID IS NOT NULL
AND p.SEX != 'C'
    -- Exclude Transferred
AND p.STATUS NOT IN (4)
