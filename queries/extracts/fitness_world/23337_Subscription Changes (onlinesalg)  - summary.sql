-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 40509
SELECT
    COUNT(OWNER_CENTER) cnt,
    owner_center center
FROM
    (
        SELECT DISTINCT
            s1.OWNER_CENTER,
            s1.OWNER_ID ,
            s1.CREATOR_CENTER || 'emp' || s1.CREATOR_ID empid,
            scl2.CENTER || 'ss' || scl2.ID prev_SSID,
            p2.NAME prevName,
            longToDate(scl3.BOOK_END_TIME) prev_started,
            longToDate(scl2.ENTRY_END_TIME)-1 prev_Ended,
            scl1.CENTER || 'ss' || scl1.ID curr_SSID,
            p1.NAME currName,
            longToDate(scl1.ENTRY_START_TIME) curr_started
        FROM
            FW.STATE_CHANGE_LOG scl1
        JOIN FW.SUBSCRIPTIONS s1
        ON
            s1.CENTER = scl1.CENTER
            AND s1.ID = scl1.ID
        JOIN FW.SUBSCRIPTIONTYPES st1
        ON
            st1.CENTER = s1.SUBSCRIPTIONTYPE_CENTER
            AND st1.ID = s1.SUBSCRIPTIONTYPE_ID
        JOIN FW.PRODUCTS p1
        ON
            p1.CENTER = st1.CENTER
            AND p1.ID = st1.ID
        JOIN FW.SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = s1.OWNER_CENTER
            AND s2.OWNER_ID = s1.OWNER_ID
            AND s2.ID != s1.ID
        JOIN FW.SUBSCRIPTIONTYPES st2
        ON
            st2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
            AND st2.ID = s2.SUBSCRIPTIONTYPE_ID
        JOIN FW.PRODUCTS p2
        ON
            p2.CENTER = st2.CENTER
            AND p2.ID = st2.ID
        JOIN FW.STATE_CHANGE_LOG scl2
        ON
            scl2.CENTER = s2.CENTER
            AND scl2.ID = s2.ID
            AND scl2.ENTRY_TYPE = 2
            AND scl2.STATEID = 2
            AND scl2.ENTRY_END_TIME BETWEEN (scl1.ENTRY_START_TIME - 60*1000) AND scl1.ENTRY_START_TIME
        LEFT JOIN FW.STATE_CHANGE_LOG scl3
        ON
            scl3.CENTER = scl2.CENTER
            AND scl3.ID = scl2.ID
            AND scl2.ENTRY_TYPE = 2
            AND scl3.STATEID = 8
        JOIN FW.EMPLOYEES emp
        ON
            emp.CENTER = s1.CREATOR_CENTER
            AND emp.ID = s1.CREATOR_ID
            AND emp.USE_API = 1
        WHERE
            s1.OWNER_CENTER IN(:scope)
            AND scl1.ENTRY_TYPE = 2
            AND scl1.STATEID = 2
            AND
            (
                scl2.BOOK_END_TIME - (1000*60*60*24)
            )
            BETWEEN :startDate AND :endDate
    )
GROUP BY
    owner_center