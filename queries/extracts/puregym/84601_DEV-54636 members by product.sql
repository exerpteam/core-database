-- The extract is extracted from Exerp on 2026-02-08
--  

WITH
    dates AS MATERIALIZED
    (   SELECT
            CAST(dateToLongC(TO_CHAR(d1, 'YYYY-MM-DD HH24:MI'), 100) AS BIGINT) AS dt,
            CAST(dateToLongC(TO_CHAR((d1 + interval '1' day), 'YYYY-MM-DD HH24:MI'), 100) AS BIGINT) AS dt_end,
            d1 AS d
        FROM
            generate_series(CAST($$START_DATE$$ AS DATE), CAST($$END_DATE$$ AS DATE), '1 day') AS d1
    )
    ,
	V_EXCLUDED_SUBSCRIPTIONS AS materialized
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
     longtodatetz(dt,'Europe/London')                                                                                                                       AS "Date",
     CENTER                                                                                                                                                 AS "ClubId",
     C_NAME                                                                                                                                                 AS "Club",
     CASE  PERSON_TYPE  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS "PersonType",
     ROUND(PRICE,2)                                                                                                                                         AS "Price",
     SU_GLOBALID                                                                                                                                            AS "ProductGlobalId",
     COUNT(*)                                                                                                                                               AS "Count"
 FROM
     (
         SELECT
             SU.CENTER,
             SU.ID,
             dates.dt     AS REP_DATE,
             SU.CENTER    AS SU_CENTER,
             C.NAME       AS C_NAME,
             pr.GLOBALID  AS SU_GLOBALID,
             SCL2.STATEID AS PERSON_TYPE,
             CASE
                 WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                 THEN 'Pre-Join'
                 ELSE 'Open'
             END                   AS C_STATUS,
             SU.ID                 AS SU_ID,
             SU.OWNER_CENTER       AS SU_OWNER_CENTER,
             SU.OWNER_ID           AS SU_OWNER_ID,
             SU.SUBSCRIPTION_PRICE AS SU_SUBSCRIPTION_PRICE,
             ST.PERIODCOUNT        AS ST_PERIODCOUNT,
             SCL1.STATEID          AS SCL1_STATEID,
             CASE
                 WHEN ST.ST_TYPE = 1
                 THEN COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE))
                 ELSE
                     CASE
                         WHEN (ST.PERIODCOUNT=1
                                 AND ST.PERIODUNIT=3)
                         THEN (SU.SUBSCRIPTION_PRICE / 12)
                         ELSE (SU.SUBSCRIPTION_PRICE / ST.PERIODCOUNT)
                     END
             END AS PRICE,
             ST.ST_TYPE,
             TRUNC(longtodateC(SCL1.ENTRY_START_TIME,scl1.center)) AS SU_CREATION_DATE,
             dates.dt,
                         /* Members has more than 1 subscription then show only active subscription */
             rank() over (partition BY SU.OWNER_CENTER, SU.OWNER_ID ORDER BY su.state, su.creation_time) AS rnk,
             rank() over (partition BY SCL2.center, SCL2.id ORDER BY SCL2.entry_start_time desc) AS rnk2
         FROM
             SUBSCRIPTIONS SU
         CROSS JOIN
             dates
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
                 AND SPP.FROM_DATE <= dates.d
                 AND SPP.TO_DATE >= dates.d
                 AND SPP.SPP_STATE = 1
                 AND SPP.ENTRY_TIME < dates.dt_end)
         LEFT JOIN
             SUBSCRIPTION_PRICE SP
         ON
             (
                 SP.SUBSCRIPTION_CENTER = SU.CENTER
                 AND SP.SUBSCRIPTION_ID = SU.ID
                 AND sp.CANCELLED = 0
                 AND SP.FROM_DATE <= greatest(dates.d , su.start_date)
                 AND (
                     SP.TO_DATE IS NULL
                     OR SP.TO_DATE >= greatest(dates.d , su.start_date)))
         JOIN
             PRODUCTS pr
         ON
             st.CENTER = pr.CENTER
             AND st.ID = pr.ID
         JOIN
             STATE_CHANGE_LOG scl2
         ON
             scl2.center = su.OWNER_CENTER
             AND scl2.id = su.OWNER_ID
             AND scl2.ENTRY_TYPE=3
        LEFT JOIN
            V_EXCLUDED_SUBSCRIPTIONS ES
            ON  ST.CENTER = ES.CENTER
                AND ST.ID = ES.ID
         WHERE
             (
                 SCL1.STATEID IN (2,4,8)
                 AND SCL1.BOOK_START_TIME < dates.dt_end
                 AND (
                     SCL1.BOOK_END_TIME IS NULL
                     OR SCL1.BOOK_END_TIME >= dates.dt_end)
                 AND SCL1.ENTRY_START_TIME < dates.dt_end
                 AND SCL2.BOOK_START_TIME < dates.dt_end
                 AND (
                     SCL2.BOOK_END_TIME IS NULL
                     OR SCL2.BOOK_END_TIME >= dates.dt)
                 AND SCL2.ENTRY_START_TIME < dates.dt_end
                 --AND ST.ST_TYPE IN (1)
                 AND ES.CENTER IS NULL)
             AND c.id IN ($$scope$$) ) t
 WHERE
     rnk = 1
         AND rnk2 = 1
 GROUP BY
     CENTER,
     C_NAME,
     PERSON_TYPE,
     PRICE,
     SU_GLOBALID,
     dt
 ORDER BY
     dt,
     SU_GLOBALID,
     CENTER
