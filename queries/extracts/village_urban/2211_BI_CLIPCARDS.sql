-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     biview."CLIPCARD_ID",biview."PERSON_ID",biview."COMPANY_ID",biview."CLIPS_LEFT",biview."CLIPS_INITIAL",biview."SALES_LINE_ID",
     biview."VALID_FROM_DATE",biview."VALID_UNTIL_DATE",biview."BLOCKED",biview."CANCELLED",biview."CANCELLATION_TIME",biview."ASSIGNED_EMPLOYEE_ID",biview."CENTER_ID",biview."ETS"
 FROM
     (
SELECT ((((cc.center || 'cc'::text) || cc.id) || 'cc'::text) || cc.subid) AS "CLIPCARD_ID",
        CASE
            WHEN ((cp.sex)::text <> 'C'::text) THEN cp.external_id
            ELSE NULL::character varying
        END AS "PERSON_ID",
        CASE
            WHEN ((cp.sex)::text = 'C'::text) THEN cp.external_id
            ELSE NULL::character varying
        END AS "COMPANY_ID",
    cc.clips_left AS "CLIPS_LEFT",
    cc.clips_initial AS "CLIPS_INITIAL",
    ((((cc.invoiceline_center || 'inv'::text) || cc.invoiceline_id) || 'ln'::text) || cc.invoiceline_subid) AS "SALES_LINE_ID",
    to_char(longtodatec((cc.valid_from)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "VALID_FROM_DATE",
    to_char(longtodatec((cc.valid_until)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "VALID_UNTIL_DATE",
        CASE
            WHEN (cc.blocked = 1) THEN 'true'::text
            WHEN (cc.blocked = 0) THEN 'false'::text
            ELSE 'UNKNOWN'::text
        END AS "BLOCKED",
        CASE
            WHEN (cc.cancelled = 1) THEN 'true'::text
            WHEN (cc.cancelled = 0) THEN 'false'::text
            ELSE 'UNKNOWN'::text
        END AS "CANCELLED",
    to_char(longtodatec((cc.cancellation_time)::double precision, (cc.center)::double precision), 'yyyy-MM-dd HH24:MM'::text) AS "CANCELLATION_TIME",
    cstaff.external_id AS "ASSIGNED_EMPLOYEE_ID",
    cc.cc_comment AS "COMMENT",
    cc.center AS "CENTER_ID",
    cc.last_modified AS "ETS"
   FROM ((((clipcards cc
     JOIN persons p ON (((p.center = cc.owner_center) AND (p.id = cc.owner_id))))
     JOIN persons cp ON (((cp.center = p.transfers_current_prs_center) AND (cp.id = p.transfers_current_prs_id))))
     LEFT JOIN persons staff ON (((staff.center = cc.assigned_staff_center) AND (staff.id = cc.assigned_staff_id))))
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
 null AS CLIPCARD_ID,null AS PERSON_ID,null AS COMPANY_ID,null AS CLIPS_LEFT,null AS CLIPS_INITIAL,null AS SALES_LINE_ID,null AS VALID_FROM_DATE,null AS VALID_UNTIL_DATE,null AS BLOCKED,null AS CANCELLED,null AS CANCELLATION_TIME,null AS ASSIGNED_EMPLOYEE_ID,null AS CENTER_ID,null AS ETS
  
 
 
 