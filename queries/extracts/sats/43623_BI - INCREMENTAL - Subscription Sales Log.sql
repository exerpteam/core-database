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
    ssl.SUBSCRIPTION_ID
  , ssl.SUBSCRIPTION_CENTER
  , ssl.PRODUCT_ID
  , ssl.SALES_TYPE
  , ssl.SALES_DATE
  , ssl.START_DATE
  , ssl.END_DATE
  , ssl.SALES_PERSON_ID
  , ssl.JF_NORMAL_PRICE
  , ssl.JF_DISCOUNT
  , ssl.JF_PRICE
  , ssl.JF_SPONSORED
  , ssl.JF_MEMBER
  , ssl.PRO_RATA_PERIOD_NORMAL_PRICE
  , ssl.PRORATA_PERIOD_DISCOUNT
  , ssl.PRORATA_PERIOD_PRICE
  , ssl.PRORATA_PERIOD_SPONSORED
  , ssl.PRORATA_PERIOD_MEMBER
  , ssl.INIT_PERIOD_NORMAL_PRICE
  , ssl.INIT_PERIOD_DISCOUNT
  , ssl.INIT_PERIOD_PRICE
  , ssl.INIT_PERIOD_SPONSORED
  , ssl.INIT_PERIOD_MEMBER
  , ssl.ADMIN_FEE_NORMAL_PRICE
  , ssl.ADMIN_FEE_DISCOUNT
  , ssl.ADMIN_FEE_PRICE
  , ssl.ADMIN_FEE_SPONSORED
  , ssl.ADMIN_FEE_MEMBER
  , ssl.BINDING_DAYS
  , ssl.ETS
FROM
    BI_SUBSCRIPTION_SALES_LOG ssl
CROSS JOIN
    PARAMS
WHERE
    ssl.SUBSCRIPTION_CENTER IN ($$scope$$)
    AND ssl.ETS >= PARAMS.FROMDATE
    AND ssl.ETS < PARAMS.TODATE