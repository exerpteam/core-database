WITH
    any_club_in_scope AS
    (
        SELECT id 
          FROM centers 
         WHERE id IN ($$scope$$)
           AND rownum = 1
    )
    , params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    vl.VISIT_ID
  , vl.CENTER_ID
  , vl.PERSON_ID
  , vl.HOME_CENTER_ID
  , vl.CHECK_IN_DATE
  , vl.CHECK_IN_TIME
  , vl.CHECK_OUT_DATE
  , vl.CHECK_OUT_TIME
  , vl.CHECK_IN_RESULT
  , vl.ETS
FROM
    BI_VISIT_LOG vl
CROSS JOIN
    PARAMS
WHERE

 vl.ETS >= PARAMS.FROMDATE
    AND vl.ETS < PARAMS.TODATE