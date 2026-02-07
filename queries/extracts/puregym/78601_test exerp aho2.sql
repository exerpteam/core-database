WITH
    dates AS materialized
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(cast(d1 as date), 'YYYY-MM-DD HH24:MI') , 100) AS BIGINT) AS dt,
           cast(d1 as date)                                                                  AS d,
           CAST(dateToLongC(TO_CHAR(cast(d1 as date), 'YYYY-MM-DD HH24:MI') , 100) AS BIGINT) + 1000*60*60*24 as dt_end
        FROM
            generate_series(CAST(:start AS DATE), CAST(:end AS DATE), '1 day') AS d1
    )

    ,
    subs_states AS materialized
    (
        SELECT
            su.center,
            SU.ID,
            dates.dt,
           dates.d ,
            su.start_date,
            pr.globalid,
            SCL1.ENTRY_TYPE,
            SCL1.STATEID,
            ST.ST_TYPE,
            su.OWNER_CENTER,
            su.OWNER_id,
            ST.PERIODCOUNT,
            ST.PERIODUNIT,
            SU.SUBSCRIPTION_PRICE,
            SCL1.ENTRY_START_TIME,
           SCL1.CENTER as scl1_center,
           SCL2.STATEID AS PERSON_TYPE,
           SCL1.STATEID          AS SCL1_STATEID,
           dt_end
        FROM
            SUBSCRIPTIONS SU
        CROSS JOIN
            dates
        JOIN
            STATE_CHANGE_LOG SCL1
        ON
            SCL1.CENTER = SU.CENTER
        AND SCL1.ID = SU.ID
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
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
            su.center IN (:scope)
        AND SCL1.ENTRY_TYPE = 2 AND SCL2.ENTRY_TYPE=3
        AND (
                SCL1.STATEID IN (2,4,8)
            AND SCL1.BOOK_START_TIME < dates.dt_end
            AND (
                    SCL1.BOOK_END_TIME IS NULL
                OR  SCL1.BOOK_END_TIME >= dates.dt_end)
            AND SCL1.ENTRY_START_TIME < dates.dt_end )
            AND SCL2.BOOK_START_TIME < dates.dt_end
            AND (
                    SCL2.BOOK_END_TIME IS NULL
                OR  SCL2.BOOK_END_TIME >= dates.dt_end)
            AND SCL2.ENTRY_START_TIME < dates.dt_end
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    product_and_product_group_link ppgl
                JOIN
                    product_group pg
                ON
                    pg.id = ppgl.product_group_id
                WHERE
                    pr.center=ppgl.product_center
                AND pr.id=ppgl.product_id
                AND pg.exclude_from_member_count=1)
    )
SELECT
    longtodatetz(dt,'Europe/London') AS "Date",
    CENTER                           AS "ClubId",
    C_NAME                           AS "Club",
    CASE PERSON_TYPE
        WHEN 0
        THEN 'Private'
        WHEN 1
        THEN 'Student'
        WHEN 2
        THEN 'Staff'
        WHEN 3
        THEN 'Friend'
        WHEN 4
        THEN 'Corporate'
        WHEN 5
        THEN 'Onemancorporate'
        WHEN 6
        THEN 'Family'
        WHEN 7
        THEN 'Senior'
        WHEN 8
        THEN 'Guest'
        ELSE 'Unknown'
    END            AS "PersonType",
    ROUND(PRICE,2) AS "Price",
    SU_GLOBALID    AS "ProductGlobalId",
    CAMPAIGN       AS "CAMPAIGN",
    COUNT(*)       AS "Count"
FROM
    (
        SELECT
            sub.CENTER,
            sub.ID,
            sub.dt     AS REP_DATE,
            sub.CENTER    AS SU_CENTER,
            C.NAME       AS C_NAME,
            sub.globalid AS SU_GLOBALID,
            PERSON_TYPE,
            CASE
                WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                THEN 'Pre-Join'
                ELSE 'Open'
            END                   AS C_STATUS,
            sub.ID                 AS SU_ID,
            sub.OWNER_CENTER       AS SU_OWNER_CENTER,
            sub.OWNER_ID           AS SU_OWNER_ID,
            sub.SUBSCRIPTION_PRICE AS SU_SUBSCRIPTION_PRICE,
            sub.PERIODCOUNT        AS ST_PERIODCOUNT,
             SCL1_STATEID,
            CASE
                WHEN sub.ST_TYPE = 1
                THEN COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, sub.SUBSCRIPTION_PRICE))
                ELSE
                    CASE
                        WHEN (sub.PERIODCOUNT=1
                            AND sub.PERIODUNIT=3)
                        THEN (sub.SUBSCRIPTION_PRICE / 12)
                        ELSE (sub.SUBSCRIPTION_PRICE / sub.PERIODCOUNT)
                    END
            END AS PRICE,
            sub.ST_TYPE,
            TRUNC(longtodateC(sub.ENTRY_START_TIME,sub.scl1_center)) AS SU_CREATION_DATE,
            sub.dt,
            COALESCE(sc.NAME,prg.NAME) AS CAMPAIGN
        FROM
            subs_states sub
        JOIN
            CENTERS c
        ON
            c.id = sub.center
        LEFT JOIN
            SUBSCRIPTIONPERIODPARTS SPP
        ON
            (
                SPP.CENTER = sub.CENTER
            AND SPP.ID = sub.ID
            AND SPP.FROM_DATE <= sub.d
            AND SPP.TO_DATE >= sub.d
            AND SPP.SPP_STATE = 1
            AND SPP.ENTRY_TIME < sub.dt_end)
        LEFT JOIN
            SUBSCRIPTION_PRICE SP
        ON
            (
                SP.SUBSCRIPTION_CENTER = sub.CENTER
            AND SP.SUBSCRIPTION_ID = sub.ID
            AND sp.CANCELLED = 0
            AND SP.FROM_DATE <= greatest(sub.d , sub.start_date)
            AND (
                    SP.TO_DATE IS NULL
                OR  SP.TO_DATE >= greatest(sub.d , sub.start_date)))
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
        AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP' ) t
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