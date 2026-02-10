-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    ( SELECT (scl.member_state_log_id)::character varying(255) AS "MEMBER_STATE_LOG_ID", scl.person_id AS "PERSON_ID", bi_decode_field('PERSONS'::character varying, 'MEMBER_STATUS'::character varying, scl.stateid) AS "MEMBER_STATE", to_char(longtodatec((floor(((scl.start_time / 1000))::double precision) * (1000)::double precision), (scl.center)::double precision), 'yyyy-MM-dd'::text) AS "FROM_DATE", to_char(longtodatec((floor(((scl.start_time / 1000))::double precision) * (1000)::double precision), (scl.center)::double precision), 'hh24:mi:ss'::text) AS "FROM_TIME", scl.center AS "CENTER_ID", scl.ets AS "ETS" FROM ( SELECT scl_1.key AS member_state_log_id, cp.external_id AS person_id, scl_1.stateid, scl_1.center, CASE WHEN (scl_1.stateid = ANY (ARRAY[1, 5, 6])) THEN scl_1.book_start_time ELSE scl_1.entry_start_time END AS start_time, CASE WHEN (scl_1.stateid = ANY (ARRAY[1, 5])) THEN scl_1.book_start_time ELSE scl_1.entry_start_time END AS ets FROM ((state_change_log scl_1 JOIN persons p ON (((p.center = scl_1.center) AND (p.id = scl_1.id)))) JOIN persons cp ON (((cp.center = p.transfers_current_prs_center) AND (cp.id = p.transfers_current_prs_id)))) WHERE ((scl_1.entry_type = 5) AND (p.sex <> 'C'::text))) scl ) biview
WHERE
    biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000    