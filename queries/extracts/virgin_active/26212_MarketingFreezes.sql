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
 "FREEZE_ID",
 "SUBSCRIPTION_ID",
 "SUBSCRIPTION_CENTER_ID",
 "START_DATE",
 "END_DATE",
 "STATE",
 "TYPE",
 "REASON",
 "ENTRY_DATE",
 "CANCEL_DATE"
 FROM
     params,
     	( SELECT (f.id)::character varying(255) AS "FREEZE_ID", ((f.subscription_center || 'ss'::text) || f.subscription_id) AS "SUBSCRIPTION_ID", (f.subscription_center)::character varying(255) AS "SUBSCRIPTION_CENTER_ID", to_char((f.start_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "START_DATE", to_char((f.end_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "END_DATE", f.state AS "STATE", f.type AS "TYPE", f.text AS "REASON", to_char(longtodatec((f.entry_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "ENTRY_DATE", to_char(longtodatec((f.cancel_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "CANCEL_DATE", f.last_modified AS "ETS" FROM subscription_freeze_period f ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
