WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            CAST(now() AS DATE)-1 - $$offset$$                                                             p_date,
            datetolongTZ(TO_CHAR(CAST(now() AS DATE) -$$offset$$ ,'YYYY-MM-DD HH24:MI'), 'Asia/Riyadh') AS p_start_next_day
    )
SELECT
    /*+ NO_BIND_AWARE */
    COALESCE(TO_CHAR(su_center, '99999'), 'TOTAL')     		  AS "Club Id",
    COALESCE(c_name, 'TOTAL')                 AS "Club Name",
    C_STATUS                                  AS "Status",
    TO_CHAR(MAX(rep_date), 'dd-mm-yyyy')      AS "Date (End of play)",
    COUNT(*)                                  AS "Total (incl. freeze)",
    TO_CHAR(SUM(price)/COUNT(*),'FM99990.00') AS "Average Yield",
    SUM(
        CASE
            WHEN SCL1_STATEID = 2
                AND (Price = 0
                    OR ST_TYPE = 0)
                AND (SPP_TYPE = 3)
            THEN 1
            WHEN SCL1_STATEID IN (2,8)
                AND Price = 0
                AND ST_TYPE = 1
                AND (SPP_TYPE IN (8)
                    OR (SPP_TYPE IS NULL
                        AND SP_TYPE IN ('INITIAL',
                                        'PRORATA')))
            THEN 1
            ELSE 0
        END) AS "Free period 0.00",
    SUM(
        CASE
            WHEN SCL1_STATEID = 4
                AND (Price = 0
                    OR ST_TYPE = 0)
            THEN 1
            ELSE 0
        END)                       AS "Freeze 0.00",
    SUM(
        CASE
            WHEN SCL1_STATEID = 4
                AND Price = 25
            THEN 1
            ELSE 0
        END)                       AS "Freeze 25.00",
    SUM(
	   CASE
	      WHEN Price = 0 THEN 1
		  ELSE 0
		END  ) AS "0.00",
    SUM(
	   CASE
	      WHEN Price = 25 THEN 1
		  ELSE 0
		END  ) AS "25.00",
    SUM(
	   CASE
	      WHEN Price = 30 THEN 1
		  ELSE 0
		END  ) AS "30.00",
    SUM(
	   CASE
	      WHEN Price = 35 THEN 1
		  ELSE 0
		END  ) AS "35.00",
    SUM(
	   CASE
	      WHEN Price = 99 THEN 1
		  ELSE 0
		END  ) AS "99.00",
    SUM(
	   CASE
	      WHEN Price = 100 THEN 1
		  ELSE 0
		END  ) AS "100.00",
    SUM(
	   CASE
	      WHEN Price = 149 THEN 1
		  ELSE 0
		END  ) AS "149.00",
    SUM(
	   CASE
	      WHEN Price = 199 THEN 1
		  ELSE 0
		END  ) AS "199.00",
    SUM(
	   CASE
	      WHEN Price = 200 THEN 1
		  ELSE 0
		END  ) AS "200.00",		
    SUM(
	   CASE
	      WHEN Price = 249 THEN 1
		  ELSE 0
		END  ) AS "249.00",
    SUM(
	   CASE
	      WHEN Price = 300 THEN 1
		  ELSE 0
		END  ) AS "300.00",		
    SUM(
	   CASE
	      WHEN Price = 350 THEN 1
		  ELSE 0
		END  ) AS "350.00",
    SUM(
	   CASE
	      WHEN Price = 500 THEN 1
		  ELSE 0
		END  ) AS "500.00",
    SUM(
        CASE
            WHEN SCL1_STATEID = 4
                AND ST_TYPE = 0
            THEN 0
            WHEN price NOT IN (0,
                               25,
                               30,
                               35,
                               99,
                               100,
                               149,
                               199,
                               200,
                               249,
                               300,
                               350,
                               500)
            THEN 1
            ELSE 0
        END)                                               AS "Other",
    to_number(TO_CHAR(SUM(price),'FM99999990'),'99999990') AS "Total"
FROM
    (
        SELECT
            PARAMS.P_DATE AS REP_DATE,
            SU.CENTER     AS SU_CENTER,
            C.NAME        AS C_NAME,
            pr.GLOBALID   AS SU_GLOBALID,
            CASE
                WHEN c.STARTUPDATE>CURRENT_DATE
                THEN 'Pre-Join'
                ELSE 'Open'
            END                    AS C_STATUS,
            SU.ID                  AS SU_ID,
            SU.OWNER_CENTER        AS SU_OWNER_CENTER,
            SU.OWNER_ID            AS SU_OWNER_ID,
            SU.SUBSCRIPTION_PRICE  AS SU_SUBSCRIPTION_PRICE,
            ST.PERIODCOUNT         AS ST_PERIODCOUNT,
            SPP.SUBSCRIPTION_PRICE AS SPP_SUBSCRIPTION_PRICE,
            SP.PRICE               AS SP_PRICE,
            SCL1.STATEID           AS SCL1_STATEID,
            CASE
                WHEN ST.ST_TYPE = 1
                THEN COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE))
                ELSE (SU.SUBSCRIPTION_PRICE / ST.PERIODCOUNT)
            END AS PRICE,
            ST.ST_TYPE ,
            SPP.SPP_TYPE ,
            SP.TYPE AS SP_TYPE
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
                AND (
                    ST.CENTER, ST.ID) NOT IN
               (
                    SELECT
                        ppgl.product_center,
                        ppgl.product_id
                    FROM
                        puregym_arabia.product_and_product_group_link ppgl
                    JOIN
                        puregym_arabia.product_group pg
                    ON
                        pg.id = ppgl.product_group_id
                    WHERE
                        pg.exclude_from_member_count = true
                        AND ppgl.product_center = c.id)
						) ) t
GROUP BY
    grouping sets ( (t.su_center,t.c_name,t.C_STATUS), () )
ORDER BY
    COALESCE(t.c_name, 'ZZZZZ')