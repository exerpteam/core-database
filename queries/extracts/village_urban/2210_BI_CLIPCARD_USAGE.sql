-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     biview.*
 FROM
     (
         SELECT (cc_usage.id)::character varying(255) AS "ID",
            ((((cc_usage.card_center || 'cc'::text) || cc_usage.card_id) || 'cc'::text) || cc_usage.card_subid) AS "CLIPCARD_ID",
            cc_usage.type AS "TYPE",
            cc_usage.state AS "STATE",
            cstaff.external_id AS "EMPLOYEE_ID",
            cc_usage.clips AS "CLIPS",
            cc_usage.clipcard_usage_commission AS "COMMISSION_UNITS",
            to_char(longtodatec((cc_usage."time")::double precision, (cc_usage.card_center)::double precision), 'yyyy-MM-dd HH24:MI:SS'::text) AS "USAGE_TIME",
            cc_usage.card_center AS "CENTER_ID",
            cc_usage.last_modified AS "ETS"
           FROM (((card_clip_usages cc_usage
             LEFT JOIN employees emp ON (((emp.center = cc_usage.employee_center) AND (emp.id = cc_usage.employee_id))))
             LEFT JOIN persons staff ON (((staff.center = emp.personcenter) AND (staff.id = emp.personid))))
             LEFT JOIN persons cstaff ON (((cstaff.center = staff.transfers_current_prs_center) AND (cstaff.id = staff.transfers_current_prs_id))))     
     )
      biview
 WHERE
     biview."ETS" BETWEEN 
      CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000
     
   
     
 union all
 SELECT
 NULL AS "ID", NULL AS "CLIPCARD_ID",NULL AS "TYPE", NULL AS "STATE", NULL AS "EMPLOYEE_ID", NULL AS "CLIPS", NULL AS "COMMISSION_UNITS", NULL AS "USAGE_TIME", NULL AS "CENTER_ID", NULL AS "ETS"
 
 
 

