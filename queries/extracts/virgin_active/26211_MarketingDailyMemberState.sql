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
 "PERSON_ID",
 "CENTER_ID",
 "HOME_CENTER_PERSON_ID",
 "CHANGE_DATETIME",
 "CHANGE",
 "MEMBER_NUMBER_DELTA",
 "EXTRA_NUMBER_DELTA",
 "SECONDARY_MEMBER_NUMBER_DELTA"
 FROM
     params,
     ( SELECT dms.id AS "ID", cp.external_id AS "PERSON_ID", dms.person_center AS "CENTER_ID", dms.person_id AS "HOME_CENTER_PERSON_ID", (to_char((dms.change_date)::timestamp with time zone, 'yyyy-MM-dd '::text) || to_char(longtodatec((dms.entry_start_time)::double precision, (dms.person_center)::double precision), 'HH24:MI'::text)) AS "CHANGE_DATETIME", bi_decode_field('DAILY_MEMBER_STATUS_CHANGES'::character varying, 'CHANGE'::character varying, dms.change) AS "CHANGE", dms.member_number_delta AS "MEMBER_NUMBER_DELTA", dms.extra_number_delta AS "EXTRA_NUMBER_DELTA", dms.secondary_member_number_delta AS "SECONDARY_MEMBER_NUMBER_DELTA", dms.entry_start_time AS "ETS" FROM ((daily_member_status_changes dms JOIN persons p ON (((p.center = dms.person_center) AND (p.id = dms.person_id)))) JOIN persons cp ON (((cp.center = p.transfers_current_prs_center) AND (cp.id = p.transfers_current_prs_id)))) WHERE (dms.entry_stop_time IS NULL) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
         and biview."CENTER_ID" in ($$scope$$)
