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
 "PERSON_ID",
 "PERSON_TYPE",
 "FROM_DATE",
 "CENTER_ID"
 FROM
     params,
     ( SELECT (scl.key)::character varying(255) AS "PERSON_TYPE_LOG_ID", cp.external_id AS "PERSON_ID", bi_decode_field('PERSONS'::character varying, 'PERSONTYPE'::character varying, scl.stateid) AS "PERSON_TYPE", to_char(longtodatec((scl.book_start_time)::double precision, (scl.center)::double precision), 'yyyy-MM-dd'::text) AS "FROM_DATE", to_char(longtodatec((scl.book_start_time)::double precision, (scl.center)::double precision), 'hh24:mi:ss'::text) AS "FROM_TIME", scl.center AS "CENTER_ID", scl.book_start_time AS "ETS" FROM ((state_change_log scl JOIN persons p ON (((p.center = scl.center) AND (p.id = scl.id)))) JOIN persons cp ON (((cp.center = p.transfers_current_prs_center) AND (cp.id = p.transfers_current_prs_id)))) WHERE ((scl.entry_type = 3) AND ((p.sex)::text <> 'C'::text)) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
     and biview."CENTER_ID" in ($$scope$$)
