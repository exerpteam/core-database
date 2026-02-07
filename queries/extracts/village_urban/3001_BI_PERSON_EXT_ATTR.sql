 WITH
     params AS
     (
        SELECT     
           CASE
              WHEN $$offset$$=-1 THEN 0
              ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
           END FROMDATE,
           CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 TODATE  
     )
 SELECT
     biview.*
 FROM
     params,
     BI_PERSON_EXT_ATTR biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 UNION ALL
 SELECT
         NULL AS "PERSON_ID",
         NULL AS "NAME",
         NULL AS "VALUE",
         NULL AS "CENTER_ID",
         NULL AS "ETS"

