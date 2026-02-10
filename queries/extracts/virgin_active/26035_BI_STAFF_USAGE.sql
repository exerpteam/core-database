-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS Materialized
     (
         SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     ( SELECT (s.id)::character varying(255) AS "STAFF_USAGE_ID", ((s.booking_center || 'book'::text) || s.booking_id) AS "BOOKING_ID", s.booking_center AS "CENTER_ID", cp.external_id AS "PERSON_ID", s.state AS "STATE", to_char(longtodatec((s.starttime)::double precision, (s.booking_center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "START_DATE_TIME", to_char(longtodatec((s.stoptime)::double precision, (s.booking_center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "STOP_DATE_TIME", s.salary AS "SALARY", CASE WHEN ((sub_of.center <> sub_of.transfers_current_prs_center) OR (sub_of.id <> sub_of.transfers_current_prs_id)) THEN ( SELECT persons.external_id FROM persons WHERE ((persons.center = sub_of.transfers_current_prs_center) AND (persons.id = sub_of.transfers_current_prs_id))) ELSE sub_of.external_id END AS "SUBSTITUTE_OF_PERSON_ID", b.last_modified AS "ETS" FROM (((((staff_usage s LEFT JOIN bookings b ON (((s.booking_center = b.center) AND (s.booking_id = b.id)))) LEFT JOIN centers c ON ((s.booking_center = c.id))) LEFT JOIN persons per ON (((per.center = s.person_center) AND (per.id = s.person_id)))) LEFT JOIN persons cp ON (((cp.center = per.transfers_current_prs_center) AND (cp.id = per.transfers_current_prs_id)))) LEFT JOIN persons sub_of ON (((sub_of.center = s.original_staff_center) AND (sub_of.id = s.original_staff_id)))) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 and biview."CENTER_ID" in ($$scope$$)
