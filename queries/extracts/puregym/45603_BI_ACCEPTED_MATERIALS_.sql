 WITH
     params AS
     (
         SELECT
             (CASE $$offset$$ WHEN -1 THEN 0 ELSE ((TRUNC(CURRENT_TIMESTAMP)-$$offset$$-date('1970-01-01'))*24*3600*1000::bigint) END)    AS FROMDATE,
             (TRUNC(CURRENT_TIMESTAMP+1)-date('1970-01-01'))*24*3600*1000::bigint                                                         AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     (
 SELECT
     p.EXTERNAL_ID                                  "PERSON_ID",
     REPLACE(acceptedMaterial.name,'_eClub_','') AS "TYPE",
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
 ) biview
 WHERE
     biview."ETS" >= PARAMS.FROMDATE
         AND biview."ETS" < PARAMS.TODATE
     AND biview."CENTER_ID" in ($$scope$$)
