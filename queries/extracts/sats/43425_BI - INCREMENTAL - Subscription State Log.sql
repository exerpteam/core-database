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
    ssl.SUB_STATE_CHANGE_ID
  , ssl.SUBSCRIPTION_CENTER_ID
  , ssl.SUSBCRIPTION_ID
  , ssl.STATE
  , ssl.SUB_STATE
  , ssl.ENTRY_START_TIME
  , ssl.ENTRY_END_TIME
  , ssl.NEXT_SUB_STATE_CHANGE_ID
  , ssl.ETS
FROM
    BI_SUBSCRIPTION_STATE_LOG ssl
CROSS JOIN
    PARAMS
WHERE
    ssl.SUBSCRIPTION_CENTER_ID IN ($$scope$$)
    AND ssl.ETS >= PARAMS.FROMDATE
    AND ssl.ETS < PARAMS.TODATE