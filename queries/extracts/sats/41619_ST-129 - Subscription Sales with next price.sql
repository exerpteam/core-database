WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                         AS FROMDATE
          , $$ToDate$$ + (1000 * 60 * 60 * 24) AS TODATE
        FROM
            dual
    )
SELECT DISTINCT

  st.CENTER
  ,st.id
  ,prod.GLOBALID
  ,ss.SUBSCRIPTION_CENTER
  , ss.SUBSCRIPTION_CENTER || 'ss' || ss.SUBSCRIPTION_ID            SUBSCRIPTION_ID
  , prod.NAME                                                       SUB_NAME
  , pg.NAME                                                         PRODUCT_GROUP
  , s.OWNER_CENTER || 'p' || s.OWNER_ID                             OWNER_ID
  , DECODE(ss.TYPE, 1, 'NEW', 2, 'RENEWAL', 3, 'CHANGE', 'UNKNOWN') SALES_TYPE
  , TO_CHAR(ss.SALES_DATE, 'YYYY-MM-DD')                            SALES_DATE
  , TO_CHAR(ss.START_DATE, 'YYYY-MM-DD')                            START_DATE
  , TO_CHAR(ss.END_DATE, 'YYYY-MM-DD')                              END_DATE
    --                                                              INITIAL PERIOD
  ,CASE
        WHEN st.ST_TYPE = 1
        THEN prod.PRICE
        ELSE
            CASE
                    -- Months unit
                WHEN st.PERIODUNIT = 2
                THEN ROUND(prod.PRICE / st.PERIODCOUNT, 2)
                    -- Year unit
                WHEN st.PERIODUNIT = 3
                THEN ROUND(prod.PRICE / st.PERIODCOUNT / 12, 2)
                ELSE prod.price
            END
    END CURR_PROD_LIST_PRICE
  /*,CASE
        WHEN st.ST_TYPE = 1
        THEN ROUND(((ss.PRICE_INITIAL + ss.PRICE_INITIAL_DISCOUNT) / (last_day(ss.START_DATE ) - ss.START_DATE +1 )) * extract (DAY FROM last_day(ss.START_DATE)),1)
        ELSE
            CASE
                    -- Months unit
                WHEN st.PERIODUNIT = 2
                THEN ROUND((ss.PRICE_INITIAL + ss.PRICE_INITIAL_DISCOUNT) / st.PERIODCOUNT, 2)
                    -- Year unit
                WHEN st.PERIODUNIT = 3
                THEN ROUND((ss.PRICE_INITIAL + ss.PRICE_INITIAL_DISCOUNT) / st.PERIODCOUNT / 12, 2)
                ELSE NULL
            END
    END LIST_PRICE_AT_SALES_TIME
	*/
  ,CASE
        WHEN st.ST_TYPE = 1
        THEN nvl2(ss.PRICE_INITIAL,ROUND(((ss.PRICE_INITIAL ) / (last_day(ss.START_DATE ) - ss.START_DATE +1 )) * extract (DAY FROM last_day(ss.START_DATE)),1),ss.PRICE_PERIOD)
        ELSE
            CASE
                    -- Months unit
                WHEN st.PERIODUNIT = 2
                THEN ROUND((ss.PRICE_INITIAL) / st.PERIODCOUNT, 2)
                    -- Year unit
                WHEN st.PERIODUNIT = 3
                THEN ROUND((ss.PRICE_INITIAL) / st.PERIODCOUNT / 12, 2)
                ELSE NULL
            END
    END                                     SALES_CUSTOMER_PERIOD_PRICE
  , DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT')                                      SUBSCRIPTION_TYPE
  , st.PERIODCOUNT                                                               PERIOD_COUNT
  , DECODE(st.PERIODUNIT, 0, 'WEEK', 1, 'DAY', 2, 'MONTH', 3, 'YEAR', 'UNKNOWN') PERIOD_UNIT
  ,CASE
        WHEN st.st_type = 0
        THEN NULL
        ELSE sps_curr.PRICE
    END CURRENT_MONTHLY_PRICE
  ,CASE
        WHEN st.st_type = 0
        THEN NULL
        ELSE MAX(sps_on.PRICE) KEEP (DENSE_RANK FIRST ORDER BY sps_on.FROM_DATE) over (PARTITION BY sps_on.SUBSCRIPTION_CENTER, sps_on.SUBSCRIPTION_ID)
    END              FUTURE_PRICE
  ,CASE
        WHEN st.st_type = 0
        THEN NULL
        ELSE MAX(TO_CHAR(sps_on.FROM_DATE, 'YYYY-MM-DD')) KEEP (DENSE_RANK FIRST ORDER BY sps_on.FROM_DATE) over (PARTITION BY sps_on.SUBSCRIPTION_CENTER, sps_on.SUBSCRIPTION_ID)
    END FUTURE_PRICE_FROM_DATE
FROM
    SUBSCRIPTION_SALES ss
CROSS JOIN
    PARAMS
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = ss.SUBSCRIPTION_CENTER
    AND s.ID = ss.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
    PRODUCTS prod
ON
    s.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = prod.ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
    /* Get price and report run */
LEFT JOIN
    SUBSCRIPTION_PRICE sps_curr
ON
    sps_curr.SUBSCRIPTION_CENTER = s.CENTER
    AND sps_curr.SUBSCRIPTION_ID = s.ID
    AND sps_curr.from_date <= greatest(exerpsysdate(),ss.START_DATE)
    AND (
        sps_curr.to_date IS NULL
        OR sps_curr.to_date > exerpsysdate())
    AND sps_curr.CANCELLED = 0
LEFT JOIN
    SUBSCRIPTION_PRICE sps_on
ON
    sps_on.SUBSCRIPTION_CENTER = s.CENTER
    AND sps_on.SUBSCRIPTION_ID = s.ID
    AND sps_on.from_date > exerpsysdate()
    AND sps_on.CANCELLED = 0
WHERE
    s.CREATION_TIME >= params.FROMDATE
    AND s.CREATION_TIME < params.TODATE
    AND s.CENTER IN ($$Scope$$)
    AND ss.CANCELLATION_DATE IS NULL
    --AND ss.SUBSCRIPTION_CENTER = 573
    --and ss.SUBSCRIPTION_ID = 226818
    --and sps_on.ID is not null
    --AND ss.SUBSCRIPTION_ID IN (100003,8463)
    
ORDER BY
    2