-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI')) AS BIGINT) END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS BIGINT) AS TODATE
)

SELECT
   p.EXTERNAL_ID                                  "PERSON_ID",
    REPLACE(acceptedMaterial.name,'eClub','') AS "TYPE",
    UPPER(acceptedMaterial.TXTVALUE)            AS "VALUE",
    p.CENTER                                    AS "CENTER_ID",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS",
    p.EXTERNAL_ID||REPLACE(acceptedMaterial.name,'eClub',''),
    'eClub' as "KEY"
FROM
    PARAMS, PERSON_EXT_ATTRS acceptedMaterial
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
