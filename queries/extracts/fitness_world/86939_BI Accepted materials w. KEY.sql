-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*, 'p.EXTERNAL_ID'&'acceptedMaterial.name,'eClub' as KEY
FROM
    params,
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
    AND p.STATUS NOT IN (4)
	AND p.EXTERNAL_ID is not null
	) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE