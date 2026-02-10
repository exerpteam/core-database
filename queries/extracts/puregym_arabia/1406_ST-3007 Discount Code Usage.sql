-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    dates_series AS
    (
        SELECT
            *
        FROM
            generate_series(CAST($$START_DATE$$ AS DATE), CAST($$END_DATE$$ AS DATE), '1 day') AS d1
    )
    ,
    dates AS
    (
        SELECT
            c.id,
            CAST(dateToLongC(TO_CHAR(s.d1, 'YYYY-MM-DD HH24:MI') , c.id) AS BIGINT) AS dt,
            s.d1                                                                    AS d
        FROM
            dates_series s
        CROSS JOIN
            centers c
    )
SELECT
    longtodateC(dt,CENTER) AS "Date",
    CENTER                 AS "ClubId",
    C_NAME                 AS "Club",
    CASE PERSON_TYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END            AS "PersonType",
    ROUND(PRICE,2) AS "Price",
    SU_GLOBALID    AS "ProductGlobalId",
    COUNT(*)       AS "Count"
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
                WHEN c.STARTUPDATE>now()
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
            TO_CHAR(longtodateC(SCL1.ENTRY_START_TIME,scl1.center), 'YYYY-MM-DD') AS SU_CREATION_DATE,
            dates.dt,
            COALESCE(sc.NAME,prg.NAME) AS CAMPAIGN
        FROM
            SUBSCRIPTIONS SU
        JOIN
            dates
        ON
            dates.id = su.center
        JOIN
            CENTERS c
        ON
            c.id = su.center
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
        JOIN
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
                AND SPP.ENTRY_TIME < dates.dt + 1000*60*60*24)
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
                    OR SCL1.BOOK_END_TIME >= dates.dt + 1000*60*60*24)
                AND SCL1.ENTRY_START_TIME < dates.dt + 1000*60*60*24
                AND SCL2.BOOK_START_TIME < dates.dt + 1000*60*60*24
                AND (
                    SCL2.BOOK_END_TIME IS NULL
                    OR SCL2.BOOK_END_TIME >= dates.dt + 1000*60*60*24)
                AND SCL2.ENTRY_START_TIME < dates.dt + 1000*60*60*24 )
            AND c.id IN ($$scope$$) ) t
GROUP BY
    CENTER,
    C_NAME,
    PERSON_TYPE,
    PRICE,
    SU_GLOBALID,
    CAMPAIGN,
    dt
ORDER BY
    dt,
    SU_GLOBALID,
    CENTER