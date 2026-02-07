-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    (SELECT
    p.EXTERNAL_ID                                  "PERSON_ID",
    REPLACE(acceptedMaterial.name,'eClub','') AS "TYPE",
    UPPER(acceptedMaterial.TXTVALUE)            AS "VALUE",
    p.CENTER                                    AS "CENTER_ID",
    p.LAST_MODIFIED                                "ETS"
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
    AND p.SEX != 'C'
    -- Exclude Transferred
    AND p.STATUS NOT IN (4)) biview