-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                  AS TODATE
        
    )
SELECT
    p.EXTERNAL_ID                                  "PERSON_ID",
    REPLACE(acceptedMaterial.name,'eClub','') AS "TYPE",
    UPPER(acceptedMaterial.TXTVALUE)            AS "VALUE",
    p.CENTER                                    AS "CENTER_ID",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'fm999G999G999G999G999'),',','.') AS  "ETS"
FROM
     params,
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
    AND p.STATUS NOT IN (4)
    AND p.EXTERNAL_ID is not null
    AND p.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
