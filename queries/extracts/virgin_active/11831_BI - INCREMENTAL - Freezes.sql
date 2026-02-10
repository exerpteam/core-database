-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS Materialized
     (
         SELECT 
             c.id AS CENTER_ID,
             datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '5 days', 'YYYY-MM-DD HH24:MI'), c.time_zone) AS FROMDATE,
             datetolongtz(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 days', 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TODATE
         FROM
             centers c
         WHERE
             c.id IN ($$scope$$)
     )
 SELECT
     biview.*
 FROM
     ( SELECT (f.id)::character varying(255) AS "FREEZE_ID", ((f.subscription_center || 'ss'::text) || f.subscription_id) AS "SUBSCRIPTION_ID", (f.subscription_center)::character varying(255) AS "SUBSCRIPTION_CENTER_ID", to_char((f.start_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "START_DATE", to_char((f.end_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "END_DATE", f.state AS "STATE", f.type AS "TYPE", f.text AS "REASON", to_char(longtodatec((f.entry_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "ENTRY_DATE", to_char(longtodatec((f.cancel_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "CANCEL_DATE", f.last_modified AS "ETS" FROM subscription_freeze_period f ) biview
 JOIN
     PARAMS
     on CAST(biview."SUBSCRIPTION_CENTER_ID" AS INT) = params.CENTER_ID
WHERE
     biview."ETS" >= PARAMS.FROMDATE
     AND biview."ETS" < PARAMS.TODATE
