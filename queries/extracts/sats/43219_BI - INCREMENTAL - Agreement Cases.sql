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
            datetolongC(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    ac.AGREEMENT_CASE_ID
  , ac.CENTER_ID
  , ac.PERSON_ID
  , ac.START_DATE
  , ac.CLOSED
  , ac.ETS
FROM
    BI_AGREEMENT_CASES ac
CROSS JOIN
    PARAMS
WHERE
    ac.CENTER_ID IN ($$scope$$)
    AND ac.ETS >= PARAMS.FROMDATE
    AND ac.ETS < PARAMS.TODATE