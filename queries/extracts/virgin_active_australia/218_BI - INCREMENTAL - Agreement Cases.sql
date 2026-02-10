-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS Materialized
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
     ( SELECT ((cc.center || 'ccol'::text) || cc.id) AS "AGREEMENT_CASE_ID", cc.center AS "CENTER_ID", CASE WHEN ((p.sex)::text <> 'C'::text) THEN CASE WHEN ((p.center <> p.transfers_current_prs_center) OR (p.id <> p.transfers_current_prs_id)) THEN ( SELECT persons.external_id FROM persons WHERE ((persons.center = p.transfers_current_prs_center) AND (persons.id = p.transfers_current_prs_id))) ELSE p.external_id END ELSE NULL::character varying END AS "PERSON_ID", CASE WHEN ((p.sex)::text = 'C'::text) THEN CASE WHEN ((p.center <> p.transfers_current_prs_center) OR (p.id <> p.transfers_current_prs_id)) THEN ( SELECT persons.external_id FROM persons WHERE ((persons.center = p.transfers_current_prs_center) AND (persons.id = p.transfers_current_prs_id))) ELSE p.external_id END ELSE NULL::character varying END AS "COMPANY_ID", to_char(longtodatec((cc.start_datetime)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "START_DATE", CASE WHEN (cc.closed = 0) THEN 'FALSE'::text WHEN (cc.closed = 1) THEN 'TRUE'::text ELSE NULL::text END AS "CLOSED", to_char(longtodatec((cc.closed_datetime)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "CLOSED_DATE", cc.last_modified AS "ETS" FROM ((cashcollectioncases cc JOIN persons p ON (((p.center = cc.personcenter) AND (p.id = cc.personid)))) JOIN persons cp ON (((cp.center = p.current_person_center) AND (cp.id = p.current_person_id)))) WHERE (cc.missingpayment = 0) ) biview
 JOIN
     PARAMS
 ON
     params.id = biview."CENTER_ID"
 WHERE
     biview."ETS" >= PARAMS.FROMDATE
 AND biview."ETS" < PARAMS.TODATE
