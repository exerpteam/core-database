WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT DISTINCT
            t.id AS "TASK_ID",
            CASE
                WHEN tld.VALUE IS NULL
                    AND bk.CENTER IS NOT NULL
                THEN 'WEB_LEAD'
                ELSE tld.VALUE
            END AS "ENQUIRY_TYPE",
            CASE
                WHEN rank() over (partition BY cp.EXTERNAL_ID ORDER BY t.CREATION_TIME) >1
                    OR scl.STATEID NOT IN (0,6,9)
                THEN 1
                ELSE 0
            END                                           AS "REENQUIRY",
            greatest(t.LAST_UPDATE_TIME,bk.LAST_MODIFIED) AS "ETS"
        FROM
            TASKS t
        LEFT JOIN
            TASK_LOG tl
        ON
            tl.TASK_ID = t.id
            AND tl.TASK_ACTION_ID =11 --Choose Inquiry Type
        LEFT JOIN
            VU.TASK_LOG_DETAILS tld
        ON
            tld.TASK_LOG_ID = tl.id
            AND tld.name = 'RequirementType.USER_CHOICE'
        JOIN
            PERSONS p
        ON
            p.center = t.PERSON_CENTER
            AND p.id = t.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = p.center
            AND scl.id = p.id
            AND scl.ENTRY_TYPE = 1
            AND scl.ENTRY_START_TIME<=t.CREATION_TIME
            AND (
                scl.ENTRY_END_TIME > t.CREATION_TIME
                OR scl.ENTRY_END_TIME IS NULL)
        LEFT JOIN
            VU.PARTICIPATIONS par
        ON
            par.PARTICIPANT_CENTER = p.center
            AND par.PARTICIPANT_ID = p.id
            AND par.USER_INTERFACE_TYPE = 2 --Web Booking
        LEFT JOIN
            VU.BOOKINGS bk
        ON
            bk.center = par.BOOKING_CENTER
            AND bk.id = par.BOOKING_ID
            AND bk.ACTIVITY IN (402,
                                403,
                                405,
                                404,
                                3821) ) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE