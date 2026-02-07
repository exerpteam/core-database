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
    dc.DEBT_CASE_ID
  , dc.CENTER_ID
  , dc.PERSON_ID
  , dc.START_DATE
  , dc.AMOUNT
  , dc.CLOSED
  , dc.ETS
FROM
    BI_DEBT_CASES dc
CROSS JOIN
    PARAMS
WHERE
    dc.CENTER_ID IN ($$scope$$)
    AND dc.ETS >= PARAMS.FROMDATE
    AND dc.ETS < PARAMS.TODATE