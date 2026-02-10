-- The extract is extracted from Exerp on 2026-02-08
-- List of freezes with start & end date
 SELECT
     biview.*
 FROM
     (
      SELECT (f.id)::character varying(255) AS "FREEZE_ID",
    ((f.subscription_center || 'ss'::text) || f.subscription_id) AS "SUBSCRIPTION_ID",
    (f.subscription_center)::character varying(255) AS "SUBSCRIPTION_CENTER_ID",
    to_char((f.start_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "START_DATE",
    to_char((f.end_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "END_DATE",
    f.state AS "STATE",
    f.type AS "TYPE",
    f.text AS "REASON",
    f.text AS "REASON",
	
    to_char(longtodatec((f.entry_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "ENTRY_DATE",
    to_char(longtodatec((f.cancel_time)::double precision, (f.subscription_center)::double precision), 'YYYY-MM-DD'::text) AS "CANCEL_DATE",
    f.last_modified AS "ETS"
   FROM subscription_freeze_period f
     
     ) biview
  WHERE
     biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
     
 
