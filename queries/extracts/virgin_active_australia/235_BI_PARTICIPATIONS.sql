-- This is the version from 2026-02-05
--  
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
     biview.*
 FROM
     params,
     ( SELECT ((p.center || 'pa'::text) || p.id) AS "PARTICIPATION_ID", ((p.booking_center || 'book'::text) || p.booking_id) AS "BOOKING_ID", p.center AS "CENTER_ID", cp.external_id AS "PERSON_ID", to_char(longtodatec((p.creation_time)::double precision, (p.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "CREATION_DATE_TIME", p.state AS "STATE", bi_decode_field('PARTICIPATIONS'::character varying, 'USER_INTERFACE_TYPE'::character varying, p.user_interface_type) AS "USER_INTERFACE_TYPE", to_char(longtodatec((p.showup_time)::double precision, (p.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "SHOW_UP_TIME", bi_decode_field('PARTICIPATIONS'::character varying, 'SHOWUP_INTERFACE_TYPE'::character varying, p.showup_interface_type) AS "SHOW_UP_INTERFACE_TYPE", CASE p.showup_using_card WHEN 1 THEN 'TRUE'::text ELSE 'FALSE'::text END AS "SHOWUP_USING_CARD", to_char(longtodatec((p.cancelation_time)::double precision, (p.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "CANCEL_TIME", bi_decode_field('PARTICIPATIONS'::character varying, 'CANCELATION_INTERFACE_TYPE'::character varying, p.cancelation_interface_type) AS "CANCEL_INTERFACE_TYPE", p.cancelation_reason AS "CANCEL_REASON", CASE p.on_waiting_list WHEN 1 THEN 'TRUE'::text ELSE 'FALSE'::text END AS "WAS_ON_WAITING_LIST", to_char(longtodatec((p.moved_up_time)::double precision, (p.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "SEAT_OBTAINED_DATETIME", (p.participation_number)::character varying(255) AS "PARTICIPANT_NUMBER", p.last_modified AS "ETS", bs.ref AS "SEAT_ID", p.seat_state AS "SEAT_STATE" FROM (((((participations p JOIN bookings b ON (((p.booking_center = b.center) AND (p.booking_id = b.id)))) JOIN centers c ON ((p.center = c.id))) LEFT JOIN persons per ON (((per.center = p.participant_center) AND (per.id = p.participant_id)))) LEFT JOIN persons cp ON (((cp.center = per.transfers_current_prs_center) AND (cp.id = per.transfers_current_prs_id)))) LEFT JOIN booking_seats bs ON ((bs.id = p.seat_id))) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 and biview."CENTER_ID" in ($$scope$$)
