-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.id,
    members.day_pass  AS "Day Pass Member",
    members.recurring AS "Recurring membership members",
    ch.att_members    AS "checked in members",
    ch.rec_home       AS "home checkins recurring",
    ch.rec_other      AS "secondary checkins recurring"
FROM
    PUREGYM.CENTERS c
JOIN
    (
        SELECT DISTINCT
            s.OWNER_CENTER,
            SUM(
				case when (ST.CENTER, ST.ID) in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) then 1 else 0 end) AS day_pass,
            SUM(
				case when (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) then 1 else 0 end) AS recurring
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            s.START_DATE <longtodate($$to_date$$)
            AND (
                s.END_DATE >longtodate($$from_date$$)
                OR s.END_DATE IS NULL)
            AND s.CENTER IN ($$scope$$)
        GROUP BY
            OWNER_CENTER) members
ON
    members.OWNER_CENTER = c.id
JOIN
    (
        SELECT
            CHECKIN_CENTER,
            COUNT(DISTINCT memberID) AS att_members,
            SUM(rec_home)            AS rec_home,
            SUM(rec_other)           AS rec_other,
            SUM(dp_home)             AS dp_home,
            SUM(dp_other)            AS dp_other
        FROM
            (
                SELECT DISTINCT
                    ch.CHECKIN_CENTER,
                    ch.ID,
                    ch.PERSON_CENTER||'p'||ch.PERSON_ID MemberID,
                    CASE
                        WHEN CHECKIN_CENTER = s.CENTER
                            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
                        THEN 1
                        ELSE 0
                    END AS rec_home,
                    CASE
                        WHEN CHECKIN_CENTER != s.CENTER
                            AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                        THEN 1
                        ELSE 0
                    END AS rec_other,
                    CASE
                        WHEN CHECKIN_CENTER = s.CENTER
                            AND (ST.CENTER, ST.ID) in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
                        THEN 1
                        ELSE 0
                    END AS dp_home,
                    CASE
                        WHEN CHECKIN_CENTER != s.CENTER
                            AND (ST.CENTER, ST.ID) in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
                        THEN 1
                        ELSE 0
                    END AS dp_other
                FROM
                    PUREGYM.SUBSCRIPTIONS s
                JOIN
                    PUREGYM.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PUREGYM.CHECKINS ch
                ON
                    ch.PERSON_CENTER = s.OWNER_CENTER
                    AND ch.PERSON_ID = s.OWNER_ID
                WHERE
                    ch.CHECKIN_TIME BETWEEN $$from_date$$ AND $$to_date$$
                    AND s.START_DATE <longtodate($$to_date$$)
                    AND (
                        s.END_DATE >longtodate($$from_date$$)
                        OR s.END_DATE IS NULL)
                    AND ch.CHECKIN_CENTER IN ($$scope$$))
        GROUP BY
            CHECKIN_CENTER) ch
ON
    ch.CHECKIN_CENTER = c.ID