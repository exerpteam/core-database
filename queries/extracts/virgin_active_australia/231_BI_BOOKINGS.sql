-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'
                    ) )
            END                                                                       AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE   
     )
 SELECT
     biview.*
 FROM
     params,
     ( SELECT ((b.center || 'book'::text) || b.id) AS "BOOKING_ID", b.name AS "NAME", b.center AS "CENTER_ID", (b.activity)::character varying(255) AS "ACTIVITY_ID", cg.name AS "COLOR", to_char(longtodatec((b.starttime)::double precision, (b.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "START_DATE_TIME", to_char(longtodatec((b.stoptime)::double precision, (b.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "STOP_DATE_TIME", to_char(longtodatec((b.creation_time)::double precision, (b.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) AS "CREATION_DATE_TIME", b.state AS "STATE", COALESCE(b.class_capacity, 0) AS "CLASS_CAPACITY", COALESCE(b.waiting_list_capacity, 0) AS "WAITING_LIST_CAPACITY", CASE WHEN (b.cancelation_time IS NOT NULL) THEN to_char(longtodatec((b.cancelation_time)::double precision, (b.center)::double precision), 'YYYY-MM-DD HH24:MI:SS'::text) ELSE NULL::text END AS "CANCEL_DATE_TIME", CASE WHEN (b.cancelation_time IS NOT NULL) THEN b.cancellation_reason ELSE NULL::character varying END AS "CANCEL_REASON", (b.class_capacity)::character varying(255) AS "MAX_CAPACITY_OVERRIDE", CASE WHEN (b.main_booking_center IS NULL) THEN ((b.center || 'book'::text) || b.id) ELSE ((b.main_booking_center || 'book'::text) || b.main_booking_id) END AS "MAIN_BOOKING_ID", b.description AS "DESCRIPTION", b.coment AS "COMMENT", CASE WHEN (b.one_off_cancellation = 0) THEN 'FALSE'::text WHEN (b.one_off_cancellation = 1) THEN 'TRUE'::text ELSE NULL::text END AS "SINGLE_CANCELLATION", CASE WHEN (b.min_age_strict = 1) THEN 'TRUE'::text ELSE 'FALSE'::text END AS "STRICT_AGE_LIMIT", CASE WHEN (b.min_age >= 24) THEN (b.min_age / 12) ELSE b.min_age END AS "MINIMUM_AGE", CASE WHEN (b.max_age >= 24) THEN (b.max_age / 12) ELSE b.max_age END AS "MAXIMUM_AGE", CASE WHEN (b.min_age >= 24) THEN 'YEAR'::text WHEN (b.min_age < 24) THEN 'MONTH'::text ELSE NULL::text END AS "MINIMUM_AGE_UNIT", CASE WHEN (b.max_age >= 24) THEN 'YEAR'::text WHEN (b.max_age < 24) THEN 'MONTH'::text ELSE NULL::text END AS "MAXIMUM_AGE_UNIT", ( CASE WHEN (b.min_age >= 24) THEN ((b.min_age / 12) || ' - '::text) ELSE CASE WHEN (b.max_age >= 24) THEN (b.min_age || ' months - '::text) ELSE (b.min_age || ' - '::text) END END || CASE WHEN (b.max_age >= 24) THEN ((b.max_age / 12) || ' years'::text) ELSE (b.max_age || ' months'::text) END) AS "AGE_TEXT", b.booking_program_id AS "COURSE_ID", b.last_modified AS "ETS" FROM (((bookings b JOIN centers c ON ((c.id = b.center))) JOIN activity a ON ((a.id = b.activity))) LEFT JOIN colour_groups cg ON (((b.colour_group_id = cg.id) AND (b.colour_group_id IS NOT NULL)))) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 and biview."CENTER_ID" in ($$scope$$)
