/*SELECT
    OWNER_CENTER CENTER,
    NAME,
    STATE,
    COUNT(*)
FROM
    (*/
        SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID,
            SU.OWNER_CENTER || 'p' || SU.OWNER_ID personId,
            SU.CENTER || 'ss' || SU.ID subscriptionId,
            PG.NAME,
            SU.START_DATE,
            CASE
                WHEN SU.SUB_STATE IN (9)
                THEN 'BLOCKED'
                WHEN SCL1.STATEID IN (4)
                THEN 'FROZEN'
                WHEN SCL1.STATEID IN (8) AND SU.START_DATE  > longtodate($$CutDate$$)
                THEN 'DEFERRED'                
                ELSE NULL
            END STATE
        FROM
            SUBSCRIPTIONS SU
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
        JOIN
            STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2
                AND SCL1.STATEID IN (2,
			     4,8) 
                AND SCL1.BOOK_START_TIME < $$CutDate$$ + (1000*60*60*24) + 2000
                AND (
                    SCL1.BOOK_END_TIME IS NULL
                    OR SCL1.BOOK_END_TIME >= $$CutDate$$ + (1000*60*60*24) + 2000)
                AND SCL1.ENTRY_START_TIME < $$CutDate$$ + (1000*60*60*24) )
        LEFT JOIN
            PRODUCTS PR
        ON
            (
                ST.CENTER = PR.CENTER
                AND ST.ID = PR.ID )
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = PR.PRIMARY_PRODUCT_GROUP_ID
        WHERE
            (
                SU.CENTER IN ($$Scope$$)
                AND (
                    SU.SUB_STATE IN (9)
                    OR SCL1.STATEID IN (4,8) ))
/*)
GROUP BY
    OWNER_CENTER,
    NAME,
    STATE*/
