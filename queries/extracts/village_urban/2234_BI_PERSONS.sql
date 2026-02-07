 SELECT
     biview.*,
 cp.FULLNAME as "FULL_NAME"
 FROM
     BI_PERSONS biview
 join persons cp on cp.EXTERNAL_ID = biview."PERSON_ID"
   WHERE
     biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 