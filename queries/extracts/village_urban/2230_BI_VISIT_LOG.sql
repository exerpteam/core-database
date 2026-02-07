 SELECT
     biview.*
 FROM
     BI_VISIT_LOG biview
  WHERE
     biview."ETS" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
 UNION ALL
 SELECT
         NULL AS "VISIT_ID",
         NULL AS "CENTER_ID",
         NULL AS "PERSON_ID",
         NULL AS "HOME_CENTER_ID",
         NULL AS "CHECK_IN_DATE",
         NULL AS "CHECK_IN_TIME",
         NULL AS "CHECK_OUT_DATE",
         NULL AS "CHECK_OUT_TIME",
         NULL AS "CHECK_IN_RESULT",
         NULL AS "CARD_CHECKED_IN",
         NULL AS "ETS"
