-- The extract is extracted from Exerp on 2026-02-08
--  
--$$START_DATE$$
--$$END_DATE$$
WITH
    dates AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR($$END_DATE$$ - ROWNUM+1,'YYYY-MM-DD') || ' 00:00', 'Europe/London') dt
        FROM
            DUAL CONNECT BY ROWNUM < $$END_DATE$$ - $$START_DATE$$+2
    )
SELECT
    /*+ NO_BIND_AWARE */
    SU_CREATION_DATE,
    SU_CENTER,
    C_NAME,
    DECODE (PERSON_TYPE, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "PersonType",
    SU.owner_center|| 'ss' ||SU.id AS "Subscription",
	pr.NAME AS "Name"
FROM
    (
        SELECT
            dates.dt    AS REP_DATE,
            SU.CENTER   AS SU_CENTER,
            C.NAME      AS C_NAME,
            c.id        AS C_ID,
            pr.GLOBALID AS SU_GLOBALID,
            CASE
                WHEN c.STARTUPDATE>SYSDATE
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
            SCL2.STATEID           AS PERSON_TYPE,
            CASE
                WHEN ST.ST_TYPE = 1
                THEN NVL(SPP.SUBSCRIPTION_PRICE, NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE))
                ELSE (SU.SUBSCRIPTION_PRICE / ST.PERIODCOUNT)
            END AS PRICE,
            ST.ST_TYPE ,
            TRUNC(longtodateC(SCL1.ENTRY_START_TIME,scl1.CENTER)) AS SU_CREATION_DATE
            --    case when SPP.SUBSCRIPTION_PRICE is not null then SPP.SUBSCRIPTION_PRICE else
            -- SP_PRICE end as Price
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
                AND SPP.SPP_STATE = 1
                AND SPP.ENTRY_TIME >=dates.dt
                AND SPP.ENTRY_TIME < dates.dt + 1000*60*60*24)
        LEFT JOIN
            SUBSCRIPTION_PRICE SP
        ON
            (
                SP.SUBSCRIPTION_CENTER = SU.CENTER
                AND SP.SUBSCRIPTION_ID = SU.ID
                AND sp.CANCELLED = 0
                AND SP.ENTRY_TIME >= dates.dt 
                AND SP.ENTRY_TIME < dates.dt + 1000*60*60*24)
        JOIN
            PUREGYM.PRODUCTS pr
        ON
            st.CENTER = pr.CENTER
            AND st.ID = pr.ID
        JOIN
            PUREGYM.STATE_CHANGE_LOG scl2
        ON
            scl2.center = su.OWNER_CENTER
            AND scl2.id = su.OWNER_ID
            AND scl2.ENTRY_TYPE=3
        WHERE
            (
                SCL1.STATEID IN (8)
                AND su.center IN ($$scope$$)
                AND SCL1.ENTRY_START_TIME < dates.dt + 1000*60*60*24
                AND SCL1.ENTRY_START_TIME > dates.dt 
                AND SCL2.BOOK_START_TIME < dates.dt + 1000*60*60*24
                AND (
                    SCL2.BOOK_END_TIME IS NULL
                    OR SCL2.BOOK_END_TIME >= dates.dt + 1000*60*60*24)
                AND SCL2.ENTRY_START_TIME < dates.dt + 1000*60*60*24
                AND (
                    ST.CENTER, ST.ID) NOT IN
                (
                    SELECT
                        center,
                        id
                    FROM
                        V_EXCLUDED_SUBSCRIPTIONS) ))

ORDER BY
    NVL(c_name, 'ZZZZZ')
    --,2