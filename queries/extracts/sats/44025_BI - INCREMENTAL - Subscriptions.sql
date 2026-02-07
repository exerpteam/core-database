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
    s.PERSON_ID
  , s.SUBSCRIPTION_ID
  , s.SUBSCRIPTION_CENTER
  , s.STATE
  , s.SUB_STATE
  , s.RENEWAL_TYPE
  , s.PRODUCT_ID
  , s.START_DATE
  , s.STOP_DATE
  , s.END_DATE
  , s.BILLED_UNTIL_DATE
  , s.BINDING_END_DATE
  , s.CREATION_DATE
  , s.SUBSCRIPTION_PRICE
  , s.BINDING_PRICE
  , s.REQUIRES_MAIN
  , s.SUB_PRICE_UPDATE_EXCLUDED
  , s.TYPE_PRICE_UPDATE_EXCLUDED
  , s.FREEZE_PERIOD_PRODUCT_ID
  , s.TRANSFERRED_TO
  , s.EXTENDED_TO
  , s.ETS
FROM
   BI_SUBSCRIPTIONS s
CROSS JOIN
    PARAMS
WHERE
    s.SUBSCRIPTION_CENTER in ($$scope$$)
    AND s.ETS >= PARAMS.FROMDATE
    AND s.ETS < PARAMS.TODATE