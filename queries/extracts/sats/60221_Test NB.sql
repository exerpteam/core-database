WITH
    params AS
    (
        SELECT
        1
            /*+ materialize */
        --    $$From_Date$$                      AS FromDate,
        --    ($$To_Date$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
    ,
    v_checkinCount AS
    (
        SELECT
            floor((dateToLong(TO_CHAR(s.END_DATE, 'YYYY-MM-dd HH24:MI'))-c.CHECKIN_TIME)/1000/60/60/24) AS checkin_date,
            TO_CHAR(s.END_DATE,'YYYY-MM-dd')                                                            AS subscription_stop_date,
            --           dateToLong(TO_CHAR(s.END_DATE, 'YYYY-MM-dd HH24:MI')) AS stop_long,
            --           s.CENTER||'ss'|| s.ID                                 AS subscription_id,
            s.OWNER_CENTER||'p'||s.OWNER_ID AS owner,
            c.CHECKIN_RESULT                AS checkin_result
        FROM
            SATS.CHECKINS c
        JOIN
            SATS.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = c.PERSON_CENTER
            AND s.OWNER_ID = c.PERSON_ID
            AND s.STATE = 3
            AND s.SUB_STATE = 1
        JOIN
            SATS.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
           -- c.PERSON_CENTER = 714
            s.owner_center IN ($$Scope$$)
            --AND c.PERSON_ID in (438,643)
            AND st.ST_TYPE = 1
            AND c.CHECKIN_RESULT = 1
            AND c.CHECKIN_TIME <= dateToLong(TO_CHAR(s.END_DATE, 'YYYY-MM-dd HH24:MI'))
            AND c.CHECKIN_TIME >= dateToLong(TO_CHAR(s.END_DATE, 'YYYY-MM-dd HH24:MI')) - 1000*60*60*24*60
            AND s.END_DATE >= $$From_Date$$
            AND s.END_DATE <= $$To_Date$$
    )
SELECT
    *
FROM
    v_checkinCount PIVOT (MIN(checkin_result) FOR checkin_date IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60))
ORDER BY
    1