-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS as (
                SELECT /*+ materialize */
                    TRUNC(SYSDATE-1 -$$offset$$ ,'DDD')                                                      p_date,
                    datetolongTZ(TO_CHAR(SYSDATE -$$offset$$ ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
                FROM
                    dual)
SELECT
    /*+ NO_BIND_AWARE */
            nvl(to_char(su_center), 'TOTAL') as "Club Id",
    --        c_name as "Club Name",
    NVL(c_name, 'TOTAL')                      AS "Club Name",
    C_STATUS                                  AS "Status",
    TO_CHAR(MAX(rep_date), 'dd-mm-yyyy')      AS "Date (End of play)",
    COUNT(*)                                  AS "Total (incl. freeze)",
    TO_CHAR(SUM(price)/COUNT(*),'FM99990.00') AS "Average Yield £",
    --        sum(case when SCL1_STATEID = 4 and Price = 0 then 1 else 0 end) as "Freeze £0.00",
    SUM(
        CASE
            WHEN SCL1_STATEID = 2
                AND (Price = 0 or ST_TYPE = 0) AND (SPP_TYPE = 3) 
            THEN 1
            WHEN SU_GLOBALID in ('GYMFLEX_12M_EFT','GYMFLEX_9M_EFT') THEN 0 -- Free GYMFLEX included in Gym Flex column instead ST-1192
            WHEN SCL1_STATEID in (2,8) AND Price = 0 and ST_TYPE = 1 AND (SPP_TYPE in (8) or (SPP_TYPE is null and SP_TYPE in ('INITIAL','PRORATA'))) THEN 1 -- Initial price of 0. ST-1192    

            ELSE 0
        END)                       AS "Free period £0.00",    
    SUM(
        CASE
            WHEN SCL1_STATEID = 4
                AND (Price = 0 or ST_TYPE = 0)  
            THEN 1
            ELSE 0
        END)                       AS "Freeze £0.00",
    SUM(DECODE(Price, 3.99, 1, 0)) AS "Freeze £3.99",
    --    SUM(DECODE(Price, 5, 1, 0))    AS "Freeze £5.00",
    SUM(
        CASE
            WHEN SCL1_STATEID = 4
                AND Price = 5
            THEN 1
            ELSE 0
        END)                       AS "Freeze £5.00",
    SUM(DECODE(Price, 5.99, 1, 0)) AS "Freeze £5.99",
    SUM(
        CASE
            WHEN SCL1_STATEID != 4
                AND Price = 5
            THEN 1
            ELSE 0
        END)                        AS "£5.00",
    SUM(DECODE(Price, 6.99, 1, 0))  AS "£6.99",
    SUM(DECODE(Price, 8.99, 1, 0))  AS "£8.99",
    SUM(DECODE(Price, 9.99, 1, 0))  AS "£9.99",
    SUM(DECODE(Price, 10.99, 1, 0)) AS "£10.99",
    SUM(DECODE(Price, 11.99, 1, 0)) AS "£11.99",
    SUM(DECODE(Price, 12.99, 1, 0)) AS "£12.99",
    SUM(DECODE(Price, 13.99, 1, 0)) AS "£13.99",
    SUM(DECODE(Price, 13.95, 1, 0)) AS "£13.95",
    SUM(DECODE(Price, 14.99, 1, 0)) AS "£14.99",
    SUM(DECODE(Price, 15.99, 1, 0)) AS "£15.99",
    SUM(DECODE(Price, 16.99, 1, 0)) AS "£16.99",
    SUM(DECODE(Price, 17.99, 1, 0)) AS "£17.99",
    SUM(DECODE(Price, 18.49, 1, 0)) AS "£18.49",
    SUM(DECODE(Price, 18.99, 1, 0)) AS "£18.99",
    SUM(DECODE(Price, 19.49, 1, 0)) AS "£19.49",
    SUM(DECODE(Price, 19.99, 1, 0)) AS "£19.99",
    SUM(DECODE(Price, 20.99, 1, 0)) AS "£20.99",
    SUM(DECODE(Price, 21.99, 1, 0)) AS "£21.99",
    SUM(DECODE(Price, 22.99, 1, 0)) AS "£22.99",
    SUM(DECODE(Price, 23.99, 1, 0)) AS "£23.99",    
    SUM(DECODE(Price, 24.99, 1, 0)) AS "£24.99",
    SUM(DECODE(Price, 25.99, 1, 0)) AS "£25.99",
    SUM(DECODE(Price, 26.99, 1, 0)) AS "£26.99",
    SUM(DECODE(Price, 27.99, 1, 0)) AS "£27.99",
    SUM(DECODE(Price, 28.99, 1, 0)) AS "£28.99",
    SUM(DECODE(Price, 29.99, 1, 0)) AS "£29.99",
    SUM(DECODE(Price, 30.99, 1, 0)) AS "£30.99",
    SUM(DECODE(Price, 31.99, 1, 0)) AS "£31.99",
    SUM(DECODE(Price, 32.99, 1, 0)) AS "£32.99",
    SUM(DECODE(Price, 33.99, 1, 0)) AS "£33.99",
    SUM(DECODE(Price, 34.99, 1, 0)) AS "£34.99",
    SUM(DECODE(Price, 35.99, 1, 0)) AS "£35.99",
    SUM(DECODE(Price, 36.99, 1, 0)) AS "£36.99",
    SUM(DECODE(Price, 37.99, 1, 0)) AS "£37.99",
    SUM(DECODE(Price, 38.99, 1, 0)) AS "£38.99",
    SUM(DECODE(Price, 39.99, 1, 0)) AS "£39.99",
    SUM(DECODE(Price, 40.99, 1, 0)) AS "£40.99",
    SUM(DECODE(Price, 41.99, 1, 0)) AS "£41.99",
    SUM(DECODE(Price, 42.99, 1, 0)) AS "£42.99",
    SUM(DECODE(Price, 43.99, 1, 0)) AS "£43.99",
    SUM(DECODE(Price, 44.99, 1, 0)) AS "£44.99",
    SUM(DECODE(Price, 45.99, 1, 0)) AS "£45.99",
    SUM(DECODE(Price, 46.99, 1, 0)) AS "£46.99",
    SUM(DECODE(Price, 47.99, 1, 0)) AS "£47.99",
    SUM(DECODE(Price, 48.99, 1, 0)) AS "£48.99",
    SUM(DECODE(Price, 49.99, 1, 0)) AS "£49.99",
    SUM(DECODE(Price, 50.99, 1, 0)) AS "£50.99",
    SUM(DECODE(Price, 51.99, 1, 0)) AS "£51.99",
    SUM(DECODE(Price, 52.99, 1, 0)) AS "£52.99",
    SUM(DECODE(Price, 53.99, 1, 0)) AS "£53.99",
    SUM(DECODE(Price, 54.99, 1, 0)) AS "£54.99",
    SUM(DECODE(Price, 55.99, 1, 0)) AS "£55.99",
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
            WHEN SU_GLOBALID in ('9_MONTH_DAY_PASS') THEN 0 
            WHEN SCL1_STATEID = 4 and ST_TYPE = 0 THEN 0  -- PIF frozen are counted in free freezes. ST-1192
            WHEN price NOT IN (0,
                               3.99,
                               5,
                               5.99,
                               6.99,
                               8.99,	
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
                               23.99,
                               24.99,
                               25.99,
                               26.99,
                               27.99,
                               28.99,
                               29.99,
                               30.99,
                               31.99,
                               32.99,
                               33.99,
                               34.99,
                               35.99,
                               36.99,
                               37.99,
                               38.99,
                               39.99,
                               40.99,
                               41.99,
                               42.99,
                               43.99,
                               44.99,
                               45.99,
                               46.99,
                               47.99,
                               48.99,
                               49.99,
                               50.99,
                               51.99,
                               52.99,
                               53.99,
                               54.99,
                               55.99)
                OR (SCL1_STATEID != 4
                    AND Price = 0
		      AND ((ST_TYPE = 0 and SPP_TYPE not in (3)) or (ST_TYPE = 1 and SPP_TYPE not in (3,8) and not ((SPP_TYPE is null and SP_TYPE in ('INITIAL','PRORATA'))))) -- ST-1192
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
            pr.GLOBALID AS SU_GLOBALID,
            CASE
                WHEN c.STARTUPDATE>SYSDATE
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
            SPP.SUBSCRIPTION_PRICE                                        AS SPP_SUBSCRIPTION_PRICE,
            SP.PRICE                                                          AS SP_PRICE,
            SCL1.STATEID                                                      AS SCL1_STATEID,
            CASE when ST.ST_TYPE = 1 THEN NVL(SPP.SUBSCRIPTION_PRICE, NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE)) ELSE (SU.SUBSCRIPTION_PRICE / ST.PERIODCOUNT) END AS PRICE, ST.ST_TYPE
            , SPP.SPP_TYPE , SP.TYPE as SP_TYPE 
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
        JOIN
            PRODUCTS pr
        ON
            st.CENTER = pr.CENTER
            AND st.ID = pr.ID
        WHERE
            (
                SCL1.STATEID IN (2,4,8)
                AND SCL1.BOOK_START_TIME < params.p_start_next_day
                AND (
                    SCL1.BOOK_END_TIME IS NULL
                    OR SCL1.BOOK_END_TIME >= params.p_start_next_day)
                AND SCL1.ENTRY_START_TIME < params.p_start_next_day
                --AND ST.ST_TYPE IN (1) 
            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
            ) --and c.id in (1, 12, 33)
            )
GROUP BY
    grouping sets ( (su_center,c_name,C_STATUS), () )
    --, price
ORDER BY
    NVL(c_name, 'ZZZZZ')
    --,2