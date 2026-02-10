-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH PARAMS as
 (
                 SELECT
                     /*+ materialize */
                     TRUNC(CURRENT_TIMESTAMP-1 ,'DDD')                                                      p_date,
                     datetolongTZ(TO_CHAR(CURRENT_TIMESTAMP ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
                 ),
	V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 SELECT
     /*+ NO_BIND_AWARE */
     --        COALESCE(to_char(su_center), 'TOTAL') as "Club Id",
     --        c_name as "Club Name",
     COALESCE(c_name, 'TOTAL')                      AS "Club Name",
     C_ID as "CLUB ID",
     C_STATUS                                  AS "Status",
     TO_CHAR(MAX(rep_date), 'dd-mm-yyyy')      AS "Date (End of play)",
     COUNT(*)                                  AS "Total",
     TO_CHAR(SUM(price)/COUNT(*),'FM99990.00') AS "Average Yield £",
     SUM(
         CASE
             WHEN SCL1_STATEID != 4
                 AND Price = 5
             THEN 1
             ELSE 0
         END)                        AS "£5.00",
	 SUM(CASE WHEN Price = 6.99 THEN 1 ELSE 0 END)  AS "£6.99",
	 SUM(CASE WHEN Price = 9.99 THEN 1 ELSE 0 END)  AS "£9.99",
     SUM(CASE WHEN Price = 10.99 THEN 1 ELSE 0 END) AS "£10.99",
     SUM(CASE WHEN Price = 11.99 THEN 1 ELSE 0 END) AS "£11.99",
     SUM(CASE WHEN Price = 12.99 THEN 1 ELSE 0 END) AS "£12.99",
     SUM(CASE WHEN Price = 13.99 THEN 1 ELSE 0 END) AS "£13.99",
     SUM(CASE WHEN Price = 14.99 THEN 1 ELSE 0 END) AS "£14.99",
     SUM(CASE WHEN Price = 15.99 THEN 1 ELSE 0 END) AS "£15.99",
     SUM(CASE WHEN Price = 16.99 THEN 1 ELSE 0 END) AS "£16.99",
     SUM(CASE WHEN Price = 17.99 THEN 1 ELSE 0 END) AS "£17.99",
     SUM(CASE WHEN Price = 18.49 THEN 1 ELSE 0 END) AS "£18.49",
     SUM(CASE WHEN Price = 18.99 THEN 1 ELSE 0 END) AS "£18.99",
     SUM(CASE WHEN Price = 19.49 THEN 1 ELSE 0 END) AS "£19.49",
     SUM(CASE WHEN Price = 19.99 THEN 1 ELSE 0 END) AS "£19.99",
     SUM(CASE WHEN Price = 20.99 THEN 1 ELSE 0 END) AS "£20.99",
     SUM(CASE WHEN Price = 21.99 THEN 1 ELSE 0 END) AS "£21.99",
     SUM(CASE WHEN Price = 22.99 THEN 1 ELSE 0 END) AS "£22.99",
     SUM(CASE WHEN Price = 24.99 THEN 1 ELSE 0 END) AS "£24.99",
     SUM(CASE WHEN Price = 25.99 THEN 1 ELSE 0 END) AS "£25.99",
     SUM(CASE WHEN Price = 26.99 THEN 1 ELSE 0 END) AS "£26.99",
    SUM(
         CASE
             WHEN SU_GLOBALID in ('GYMFLEX_12M_EFT','GYMFLEX_9M_EFT') AND SCL1_STATEID != 4
             THEN 1
             ELSE 0
         END)                       AS "GYMFLEX",
    SUM(
         CASE
             WHEN SU_GLOBALID in ('9_MONTH_DAY_PASS') AND SCL1_STATEID != 4
             THEN 1
             ELSE 0
         END)                       AS "9 Months Pass",
             SUM(
         CASE
             WHEN SU_GLOBALID in ('9_MONTH_DAY_PASS') AND SCL1_STATEID != 4 THEN 0
             WHEN price NOT IN (0,
                                3.99,
                                5,
                                5.99,
                                6.99,
                                9.99,
                                10.99,
                                11.99,
                                12.99,
                                13.95,
                                13.99,
                                14.99,
                                15.99,
                                16.99,
                                17.99,
                                18.49,
                                18.99,
                                19.49,
                                19.99,
                                20.99,
                                21.99,
                                22.99,
                                24.99,
                                25.99,
                                26.99)
                 OR (SCL1_STATEID != 4
                     AND Price = 0
                     AND SU_GLOBALID NOT IN ('GYMFLEX_12M_EFT',
                                             'GYMFLEX_9M_EFT'))
             THEN 1
             ELSE 0
         END)                                             AS "Other",
     to_number(TO_CHAR(SUM(price),'FM99999990'),'99999990') AS "Total £"
 FROM
     (
         SELECT
             PARAMS.P_DATE AS REP_DATE,
             SU.CENTER     AS SU_CENTER,
             C.NAME        AS C_NAME,
 c.id as C_ID,
             pr.GLOBALID   AS SU_GLOBALID,
             CASE
                 WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                 THEN 'Pre-Join'
                 ELSE 'Open'
             END             AS C_STATUS,
             SU.ID           AS SU_ID,
             SU.OWNER_CENTER AS SU_OWNER_CENTER,
             SU.OWNER_ID     AS SU_OWNER_ID,
             --            SU.START_DATE                                              AS
             -- SU_START_DATE,
             SU.SUBSCRIPTION_PRICE AS SU_SUBSCRIPTION_PRICE,
             --            ST.ST_TYPE                                                        AS
             -- ST_ST_TYPE,
             ST.PERIODCOUNT AS ST_PERIODCOUNT,
             --           ST.PERIODUNIT                                                     AS
             -- ST_PERIODUNIT,
             SPP.SUBSCRIPTION_PRICE                                            AS SPP_SUBSCRIPTION_PRICE,
             SP.PRICE                                                          AS SP_PRICE,
             SCL1.STATEID                                                      AS SCL1_STATEID,
             CASE when ST.ST_TYPE = 1 THEN COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)) ELSE (SU.SUBSCRIPTION_PRICE / ST.PERIODCOUNT) END AS PRICE, ST.ST_TYPE
             --    case when SPP.SUBSCRIPTION_PRICE is not null then SPP.SUBSCRIPTION_PRICE else
             -- SP_PRICE end as Price
         FROM
             SUBSCRIPTIONS SU
         CROSS JOIN
              params
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
                 AND SPP.SPP_STATE = 1
                 AND SPP.ENTRY_TIME >= datetolongTZ(TO_CHAR(params.p_date ,'YYYY-MM-DD') || ' 00:00', 'Europe/London')
                 AND SPP.ENTRY_TIME < params.p_start_next_day)
         LEFT JOIN
             SUBSCRIPTION_PRICE SP
         ON
             (
                 SP.SUBSCRIPTION_CENTER = SU.CENTER
                 AND SP.SUBSCRIPTION_ID = SU.ID
                 AND sp.CANCELLED = 0
                 AND SP.ENTRY_TIME >= datetolongTZ(TO_CHAR(params.p_date ,'YYYY-MM-DD') || ' 00:00', 'Europe/London')
                 AND SP.ENTRY_TIME < params.p_start_next_day)
         JOIN
             PRODUCTS pr
         ON
             st.CENTER = pr.CENTER
             AND st.ID = pr.ID
         WHERE
             (
                 SCL1.STATEID IN (8)
                 AND SCL1.ENTRY_START_TIME < params.p_start_next_day
                 AND SCL1.ENTRY_START_TIME > datetolongTZ(TO_CHAR(params.p_date ,'YYYY-MM-DD') || ' 00:00', 'Europe/London')
                 AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
             )
		) t
 GROUP BY
     grouping sets ( (C_ID,c_name,C_STATUS), () )
     --, price
 ORDER BY
     COALESCE(c_name, 'ZZZZZ')
     --,2
