-- The extract is extracted from Exerp on 2026-02-08
--  


WITH
    PARAMS AS
    (
        SELECT
            datetolong(TO_CHAR(date_trunc('day', par.currentdate), 'YYYY-MM-DD HH24:MI')) -1                         AS STARTTIME ,
            datetolong(TO_CHAR(date_trunc('day', par.currentdate+1), 'YYYY-MM-DD HH24:MI')) -1                       AS ENDTIME ,
            datetolong(TO_CHAR(date_trunc('day', par.currentdate +2), 'YYYY-MM-DD HH24:MI'))                         AS HARDCLOSETIME,
            datetolong(TO_CHAR(date_trunc('day', par.currentdate +1) - interval '3 month', 'YYYY-MM-DD HH24:MI')) -1 AS REJOINCUTDATE
        FROM
            (
                SELECT
                    CAST($$for_date$$ AS DATE) AS currentdate) par
    )
    ,
    SCL_TEMP AS
    (
        SELECT
            per.CENTER             AS center,
            per.ID                 AS id ,
            curper.CENTER          AS CCENTER,
            curper.ID              AS CID,
            su.center||'ss'||su.id AS SUB_ID,
            CASE
                WHEN ( SCL.BOOK_END_TIME IS NULL
                        --     OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
                    AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                    AND SCL.STATEID IN ( 2,4,8)
                THEN 1
                ELSE 0
            END AS "IN_INCOMING",
            CASE
                WHEN ( SCL.BOOK_END_TIME IS NULL
                        --   OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND SCL.STATEID IN (2,4,8)
                THEN 1
                ELSE 0
            END AS "IN_OUTGOING",
            CASE
                WHEN SCL.STATEID IN (3,7)
                    AND SCL.SUB_STATE NOT IN (8)
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND SCL.BOOK_START_TIME >= PARAMS.REJOINCUTDATE
                THEN 1
                ELSE 0
            END AS "IS_REJOIN"
        FROM
            PARAMS,
            SUBSCRIPTIONTYPES ST
        JOIN
            SUBSCRIPTIONS su
        ON
            su.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND su.SUBSCRIPTIONTYPE_ID = ST.ID
        JOIN
            persons per
        ON
            per.center = su.owner_center
            AND per.id = su.owner_id
        JOIN
            persons curper
        ON
            curper.center = per.transfers_current_prs_center
            AND curper.id = per.transfers_current_prs_id
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2
        WHERE
            SU.CENTER IN ($$Scope$$)
            AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
            AND (
                SCL.BOOK_END_TIME IS NULL
                --   OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
            AND SCL.STATEID IN ( 2,4,8,3,7 )
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    ppg.product_center = ST.CENTER
                    AND ppg.product_id = ST.ID
                    AND ppg.PRODUCT_GROUP_ID = 1201 )
            -- Exclude add-on memberships
            AND st.IS_ADDON_SUBSCRIPTION = 0
            --and su.center = 11 and su.id = 38603
            AND NOT EXISTS
            (
                -- Not person type staff at end of day
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL2
                WHERE
                    SCL2.CENTER = SU.OWNER_CENTER
                    AND SCL2.ID = SU.OWNER_ID
                    AND SCL2.ENTRY_TYPE = 3
                    AND SCL2.BOOK_START_TIME < PARAMS.STARTTIME
                    AND (
                        SCL2.BOOK_END_TIME IS NULL
                        -- OR  SCL2.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL2.BOOK_END_TIME >= PARAMS.STARTTIME )
                    AND SCL2.ENTRY_TYPE = 3
                    -- Not staff
                    AND SCL2.STATEID = 2
                    -- Time safety
                    AND SCL2.ENTRY_START_TIME < PARAMS.STARTTIME )
    )
SELECT
    a.*
FROM
    (
        SELECT DISTINCT
            CENTER||'p'||ID,
            CASE
                WHEN tmp1."IN_INCOMING" = 1
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.center = tmp2.center
                            AND tmp1.id = tmp2.id
                            AND tmp2."IN_OUTGOING" = 1)
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.CCENTER = tmp2.CCENTER
                            AND tmp1.CID = tmp2.CID
                            AND tmp2."IN_OUTGOING" = 1)
                THEN 'TRANSFER_OUT'
                WHEN tmp1."IN_INCOMING" = 1
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.center = tmp2.center
                            AND tmp1.id = tmp2.id
                            AND tmp2."IN_OUTGOING" = 1)
                THEN 'LEAVER'
                WHEN tmp1."IN_OUTGOING" = 1
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.center = tmp2.center
                            AND tmp1.id = tmp2.id
                            AND tmp2."IN_INCOMING" = 1)
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.ccenter = tmp2.ccenter
                            AND tmp1.cid = tmp2.cid
                            AND tmp2."IN_INCOMING" = 1)
                THEN 'TRANSFER_IN'
                WHEN tmp1."IN_OUTGOING" = 1
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.center = tmp2.center
                            AND tmp1.id = tmp2.id
                            AND tmp2."IN_INCOMING" = 1)
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.ccenter = tmp2.ccenter
                            AND tmp1.cid = tmp2.cid
                            AND tmp2."IS_REJOIN" = 1 )
                THEN 'REJOINER'
                WHEN tmp1."IN_OUTGOING" = 1
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            SCL_TEMP tmp2
                        WHERE
                            tmp1.center = tmp2.center
                            AND tmp1.id = tmp2.id
                            AND tmp2."IN_INCOMING" = 1)
                THEN 'JOINER'
                WHEN tmp1."IN_OUTGOING" = 1
                THEN 'MEMBER'
            END AS type,
            "IN_INCOMING",
            "IN_OUTGOING"
        FROM
            SCL_TEMP tmp1 ) a
WHERE
    a.TYPE IS NOT NULL

