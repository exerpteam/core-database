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
    f.FREEZE_ID
  , f.SUBSCRIPTION_ID
  , f.SUBSCRIPTION_CENTER_ID
  , f.START_DATE
  , f.END_DATE
  , f.STATE
  , f.TYPE
  , f.REASON
  , f.ENTRY_DATE
  , f.CANCEL_DATE
  , f.ETS
FROM
    BI_FREEZES f
CROSS JOIN
    PARAMS
WHERE
    f.SUBSCRIPTION_CENTER_ID IN ($$scope$$)
    AND f.ETS >= PARAMS.FROMDATE
    AND f.ETS < PARAMS.TODATE
