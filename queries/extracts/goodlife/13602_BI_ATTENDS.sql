-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    ( SELECT ((att.center || 'att'::text) || att.id) AS "ATTEND_ID", cp.external_id AS "PERSON_ID", to_char(longtodatec((att.start_time)::double precision, (att.center)::double precision), 'yyyy-MM-dd HH24:MI:SS'::text) AS "START_TIME", to_char(longtodatec((att.stop_time)::double precision, (att.center)::double precision), 'yyyy-MM-dd HH24:MI:SS'::text) AS "STOP_TIME", ((att.booking_resource_center || 'br'::text) || att.booking_resource_id) AS "RESOURCE_ID", att.center AS "CENTER_ID", att.last_modified AS "ETS" FROM ((attends att LEFT JOIN persons p ON (((p.center = att.person_center) AND (p.id = att.person_id)))) LEFT JOIN persons cp ON (((cp.center = p.transfers_current_prs_center) AND (cp.id = p.transfers_current_prs_id)))) ) biview
WHERE
    biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000  