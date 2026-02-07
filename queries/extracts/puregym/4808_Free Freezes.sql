 SELECT
     *
 FROM
     (
         SELECT
             SU.OWNER_CENTER                                                   AS Member_Center,
             SU.OWNER_ID                                                       AS Member_ID,
             PARAMS.P_DATE                                                     AS REP_DATE,
             SU.CENTER                                                         AS SU_CENTER,
             C.NAME                                                            AS C_NAME,
             SU.ID                                                             AS SU_ID,
             SU.START_DATE                                                     AS SU_START_DATE,
             SU.SUBSCRIPTION_PRICE                                             AS SU_SUBSCRIPTION_PRICE,
             ST.ST_TYPE                                                        AS ST_ST_TYPE,
             ST.PERIODCOUNT                                                    AS ST_PERIODCOUNT,
             ST.PERIODUNIT                                                     AS ST_PERIODUNIT,
             SPP.SUBSCRIPTION_PRICE                                            AS SPP_SUBSCRIPTION_PRICE,
             SP.PRICE                                                          AS SP_PRICE,
             SCL1.STATEID                                                      AS SCL1_STATEID,
             COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)) AS PRICE,
             SCL1.EMPLOYEE_CENTER||'emp'||scl1.EMPLOYEE_ID as staff
             --    case when SPP.SUBSCRIPTION_PRICE is not null then SPP.SUBSCRIPTION_PRICE else
             -- SP_PRICE end as Price
         FROM
             SUBSCRIPTIONS SU
         CROSS JOIN
             (
                 SELECT
                     TRUNC(CURRENT_TIMESTAMP-1 -:offset ,'DDD')                                                      p_date,
                     datetolongTZ(TO_CHAR(CURRENT_TIMESTAMP -:offset ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
                 ) params
         JOIN
             CENTERS c
         ON
             c.id = su.center
         INNER JOIN
             SUBSCRIPTIONTYPES ST
         ON
             (
                 SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                 AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
         INNER JOIN
             STATE_CHANGE_LOG SCL1
         ON
             (
                 SCL1.CENTER = SU.CENTER
                 AND SCL1.ID = SU.ID
                 AND SCL1.ENTRY_TYPE = 2 )
         LEFT JOIN
             SUBSCRIPTIONPERIODPARTS SPP
         ON
             (
                 SPP.CENTER = SU.CENTER
                 AND SPP.ID = SU.ID
                 AND SPP.FROM_DATE <= params.p_date
                 AND SPP.TO_DATE >= params.p_date
                 AND SPP.SPP_STATE = 1
                 AND SPP.ENTRY_TIME < params.p_start_next_day)
         LEFT JOIN
             SUBSCRIPTION_PRICE SP
         ON
             (
                 SP.SUBSCRIPTION_CENTER = SU.CENTER
                 AND SP.SUBSCRIPTION_ID = SU.ID
                 AND sp.CANCELLED = 0
                 AND SP.FROM_DATE <= greatest(params.p_date, su.start_date)
                 AND (
                     SP.TO_DATE IS NULL
                     OR SP.TO_DATE >= greatest(params.p_date, su.start_date)))
         WHERE
             (
                 SCL1.STATEID IN (2,4,8)
                 AND SCL1.BOOK_START_TIME < params.p_start_next_day
                 AND (
                     SCL1.BOOK_END_TIME IS NULL
                     OR SCL1.BOOK_END_TIME >= params.p_start_next_day)
                 AND SCL1.ENTRY_START_TIME < params.p_start_next_day
                 AND st.ST_TYPE = 1
                 AND SU.OWNER_CENTER IN (:scope)) )results

 GROUP BY
     results.Member_Center,
     results.Member_ID,
     results.REP_DATE,
     results.SU_CENTER,
     results.C_NAME,
     results.SU_ID,
     results.SU_START_DATE,
     results.SU_SUBSCRIPTION_PRICE,
     results.ST_ST_TYPE,
     results.ST_PERIODCOUNT,
     results.ST_PERIODUNIT,
     results.SPP_SUBSCRIPTION_PRICE,
     results.SP_PRICE,
     results.SCL1_STATEID,
     results.PRICE,
     results.staff

 HAVING
     results.PRICE = 0