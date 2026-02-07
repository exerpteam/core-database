 SELECT
     biview.*
 FROM
     BI_KPI_LOG biview
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
     NULL AS "KPI_FIELD",
     NULL AS "CENTER_ID",
     NULL AS "FOR_DATE",
     NULL AS "KPI_VALUE",
     NULL AS "TYPE",
     NULL AS "ETS"