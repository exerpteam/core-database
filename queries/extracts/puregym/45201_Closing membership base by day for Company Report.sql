-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3394
WITH temp1 AS (
    SELECT * FROM
        generate_series(CAST($$END_DATE$$ AS DATE), CAST($$START_DATE$$ AS DATE), '-1 day') AS d1  
    ),
	dates as Materialized 
	(
	   SELECT CAST(datetolongTZ(to_char(d1, 'YYYY-MM-DD HH24:MI'),'Europe/London') AS BIGINT) dt,  d1 as start_date from temp1
	),
    V_EXCLUDED_SUBSCRIPTIONS AS Materialized
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
    longtodatetz(dt,'Europe/London') AS "Date",
    CENTER                           AS "Club ID",
    C_NAME                           AS "Club Name",
	CASE  PERSON_TYPE  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 
         'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END  AS "Person Type",
    ROUND(PRICE,2)                                                  AS "Price",
    SU_GLOBALID                                                     AS "Product Group",
    CAMPAIGN_OR_COMPANY                                             AS "Company/Student with discount",
    COUNT(*)                                                        AS "Count"
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
                WHEN c.STARTUPDATE> CURRENT_TIMESTAMP
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
            COALESCE(prg.NAME, comp.FULLNAME) AS CAMPAIGN_OR_COMPANY
          FROM
            SUBSCRIPTIONS SU
        CROSS JOIN
            dates
        JOIN
            CENTERS c
        ON
            c.id = su.center
        LEFT JOIN
           relatives r
        ON
           su.owner_center = r.center
           AND su.owner_id = r.id
           AND r.rtype = 3
           AND r.status = 1
        LEFT JOIN
            PERSONS comp
        ON
            comp.center = r.relativecenter
            AND comp.id = r.relativeid
            AND r.rtype = 3
            AND comp.persontype = 4
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
            AND SPP.FROM_DATE <= dates.start_date
            AND SPP.TO_DATE >= dates.start_date
            AND SPP.SPP_STATE = 1
            AND SPP.ENTRY_TIME < dates.dt + 1000*60*60*24)
        LEFT JOIN
            SUBSCRIPTION_PRICE SP
        ON
            (
                SP.SUBSCRIPTION_CENTER = SU.CENTER
            AND SP.SUBSCRIPTION_ID = SU.ID
            AND sp.CANCELLED = 0
            AND SP.FROM_DATE <= greatest(dates.start_date , su.start_date)
            AND (
                    SP.TO_DATE IS NULL
                OR  SP.TO_DATE >= greatest(dates.start_date , su.start_date)))
        LEFT JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.TARGET_SERVICE = 'SubscriptionPrice'
        AND sp.ID = pu.TARGET_ID
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.ID = pu.GRANT_ID
        LEFT JOIN
            PRIVILEGE_SETS ps
        ON
            ps.ID = pg.PRIVILEGE_SET
        LEFT JOIN
            CAMPAIGN_CODES cc
        ON
            cc.id = pu.CAMPAIGN_CODE_ID
        LEFT JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.ID = cc.CAMPAIGN_ID
        AND cc.CAMPAIGN_TYPE = 'STARTUP'
        LEFT JOIN
            PRIVILEGE_RECEIVER_GROUPS prg
        ON
            prg.ID = cc.CAMPAIGN_ID
        AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
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
        WHERE
            (
                SCL1.STATEID IN (2,4,8)
            AND SCL1.BOOK_START_TIME < dates.dt + 1000*60*60*24
            AND (
                    SCL1.BOOK_END_TIME IS NULL
                OR  SCL1.BOOK_END_TIME >= dates.dt + 1000*60*60*24)
            AND SCL1.ENTRY_START_TIME < dates.dt + 1000*60*60*24
            AND SCL2.BOOK_START_TIME < dates.dt + 1000*60*60*24
            AND (
                    SCL2.BOOK_END_TIME IS NULL
                OR  SCL2.BOOK_END_TIME >= dates.dt + 1000*60*60*24)
            AND SCL2.ENTRY_START_TIME < dates.dt + 1000*60*60*24
                --AND ST.ST_TYPE IN (1)
            AND (
                    ST.CENTER, ST.ID) NOT IN
                (
                    SELECT
                        center,
                        id
                    FROM
                        V_EXCLUDED_SUBSCRIPTIONS) ) 
        AND c.id IN ($$scope$$)
        ) t1
GROUP BY
    CENTER,
    C_NAME,
    PERSON_TYPE, 
    PRICE,
    SU_GLOBALID,
    CAMPAIGN_OR_COMPANY,
    dt
ORDER BY
    dt,
    SU_GLOBALID,
    CENTER