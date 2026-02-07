SELECT
    PERIOD_START,
    PERIOD_END,
    "CENTER" || 'ss' || "ID" ssid,
    "OWNER_CENTER" || 'p' || "OWNER_ID" pid,
    checkins_in_period,
    SUM(checkins_in_period) OVER ( ORDER BY PERIOD_START) accumulated_checkins
FROM
    (
        SELECT
            periods."CENTER",
            periods."ID",
            periods."period_start" PERIOD_START,
            periods."period_end" PERIOD_END,
            periods."OWNER_CENTER",
            periods."OWNER_ID",
            COUNT(ci.CHECKIN_CENTER) checkins_in_period
        FROM
            (
                SELECT
                    lev.start_date,
                    lev.end_date,
                    lev.CENTER,
                    lev.ID,
                    OWNER_CENTER,
                    OWNER_ID,
                    CASE
                        WHEN REMAINDER(COUNT(lev.start_date) OVER ( ORDER BY lev.start_date)-1,10) = 0
                        THEN lev.start_date
                        ELSE NULL
                    END AS "period_start",
                    CASE
                        WHEN REMAINDER(COUNT(lev.start_date) OVER ( ORDER BY lev.start_date)-1,10) = 0
                        THEN NVL( lead(lev.start_date,10) OVER ( ORDER BY lev.start_date),sysdate)
                        ELSE NULL
                    END AS "period_end"
                FROM
                    (
                        SELECT
                            LEVEL,
                            START_DATE -1 + LEVEL start_date,
                            START_DATE + LEVEL end_date,
                            CENTER,
                            ID,
                            OWNER_CENTER,
                            OWNER_ID
                        FROM
                            (
                                SELECT
                                    s.START_DATE,
                                    s.CENTER,
                                    s.ID,
                                    s.OWNER_CENTER,
                                    s.OWNER_ID
                                FROM
                                    HP.SUBSCRIPTIONS s
                                WHERE
                                    (
                                        s.CENTER,s.ID
                                    )
                                    IN
                                    (
                                        SELECT
                                            *
                                        FROM
                                            HP.SUBSCRIPTIONS s2


                                    )
                            )
                            CONNECT BY LEVEL <= 40
                        ORDER BY
                            LEVEL
                    )
                    lev
                LEFT JOIN HP.SUBSCRIPTION_BLOCKED_PERIOD sbp
                ON
                    sbp.SUBSCRIPTION_CENTER = lev.center
                    AND sbp.SUBSCRIPTION_ID = lev.id
                    AND lev.start_date BETWEEN sbp.START_DATE AND sbp.END_DATE
                    AND sbp.STATE = 'ACTIVE'
                WHERE
                    sbp.ID IS NULL
                ORDER BY
                    lev.start_date
            )
            periods
        LEFT JOIN HP.CHECKINS ci
        ON
            ci.PERSON_CENTER = periods."OWNER_CENTER"
            AND ci.PERSON_ID = periods."OWNER_ID"
            AND ci.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(periods."period_start",'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(periods."period_end",'YYYY-MM-dd HH24:MI'))
        WHERE
            periods."period_start" IS NOT NULL
        GROUP BY
            periods."CENTER",
            periods."ID",
            periods."period_start",
            periods."period_end",
            periods."OWNER_CENTER",
            periods."OWNER_ID"
        ORDER BY
            periods."period_start"
    )