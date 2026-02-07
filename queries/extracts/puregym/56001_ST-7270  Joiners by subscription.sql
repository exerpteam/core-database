WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                   AS STARTTIME ,
            $$FromDate$$ + 86400 * 1000    AS ENDTIME,
            $$FromDate$$ + 86400 * 1000 *2 AS HARDCLOSETIME
        FROM
            dual
    )
    ,
    INCLUDED_ST AS
    (
        SELECT
            /*+ materialize */
            DISTINCT st1.center,
            st1.id
        FROM
            SUBSCRIPTIONTYPES st1
        CROSS JOIN
            params
        WHERE
            st1.center IN ($$Scope$$)
            AND (
                st1.center, st1.id) NOT IN
            (
                SELECT
                    center,
                    id
                FROM
                    V_EXCLUDED_SUBSCRIPTIONS
                WHERE
                    center IN ($$Scope$$) )
    )
    ,
    SCL_TEMP AS
    (
        SELECT
            /*+ materialize */
            per.fullname                                                                                                                                                AS FULLNAME,
            per.CENTER                                                                                                                                                  AS CENTER,
            per.ID                                                                                                                                                      AS ID,
            su.center                                                                                                                                                   AS SUB_CENTER,
            su.id                                                                                                                                                       AS SUB_ID,
            curper.external_id                                                                                                                                          AS EXTERNAL_ID,
            DECODE ( per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            TO_CHAR(longtodatec(su.creation_time, su.center), 'YYYY-MM-DD')                                                                                             AS SUB_CREATION_DATE,
            c.shortname                                                                                                                                                 AS CENTER_NAME,
            pd.name                                                                                                                                                     AS PROD_NAME,
            CASE
                WHEN ( SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                THEN 1
                ELSE 0
            END AS "IN_OUTGOING" ,
            CASE
                WHEN ( SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                THEN 1
                ELSE 0
            END AS "IN_INCOMING"
        FROM
            PARAMS,
            INCLUDED_ST ST
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
            centers c
        ON
            c.id = per.center
        JOIN
            products pd
        ON
            pd.center = su.subscriptiontype_center
            AND pd.id = su.subscriptiontype_id
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
                OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
            AND SCL.ENTRY_TYPE = 2
            AND SCL.STATEID IN ( 2,4,8 )
    )
SELECT
    tmp1.FULLNAME                          AS "Name",
    tmp1.PERSONTYPE                        AS "Person Type",
    tmp1.SUB_CREATION_DATE                 AS "Subscription Creation Date",
    tmp1.CENTER                            AS "Center ID",
    tmp1.CENTER_NAME                       AS "Club Name",
    tmp1.EXTERNAL_ID                       AS "External ID",
    tmp1.CENTER || 'p'|| tmp1.ID           AS "Person ID",
    tmp1.SUB_CENTER || 'ss' || tmp1.SUB_ID AS "Subscription ID",
    tmp1.PROD_NAME                         AS "Product Name"
FROM
    SCL_TEMP tmp1
WHERE
    tmp1."IN_OUTGOING" = 1
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