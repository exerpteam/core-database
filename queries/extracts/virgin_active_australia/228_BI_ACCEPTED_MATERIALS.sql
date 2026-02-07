-- This is the version from 2026-02-05
--  
 WITH
     params AS materialized
     (
         SELECT

             c.id,
             datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '5 days', 'YYYY-MM-DD HH24:MI'), c.time_zone) AS FROMDATE,
             datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 days', 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TODATE
         FROM
             centers c
         WHERE
             id IN ($$scope$$)
     )
 SELECT
     biview.*
 FROM
     ( SELECT p.external_id AS "PERSON_ID", replace((acceptedmaterial.name)::text, 'eClub'::text, ''::text) AS "TYPE", upper((acceptedmaterial.txtvalue)::text) AS "VALUE", p.center AS "CENTER_ID", acceptedmaterial.last_edit_time AS "ETS" FROM (person_ext_attrs acceptedmaterial JOIN persons p ON (((p.center = acceptedmaterial.personcenter) AND (p.id = acceptedmaterial.personid)))) WHERE (((acceptedmaterial.name)::text = ANY ((ARRAY['eClubIsAcceptingThirdPartyOffers'::character varying, 'eClubIsAcceptingEmailNewsLetters'::character varying])::text[])) AND (p.external_id IS NOT NULL) AND ((p.sex)::text <> 'C'::text) AND (p.status <> 4)) ) biview
 JOIN
     PARAMS
 ON
     params.id = biview."CENTER_ID"
 WHERE
     biview."ETS" >= PARAMS.FROMDATE
 AND biview."ETS" < PARAMS.TODATE
