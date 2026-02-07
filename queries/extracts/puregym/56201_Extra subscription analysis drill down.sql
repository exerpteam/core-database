WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                                                                                 AS StartDate,
            $$EndDate$$                                                                                 AS EndDate,
            datetolongTZ(TO_CHAR($$StartDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR($$EndDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
        FROM
            dual
    )
    ,
    v_open_close AS
    (
        SELECT DISTINCT
            s.OWNER_CENTER || 'p' || s.OWNER_ID                                                                                           AS PersonId,
            longToDatec((MIN(scl.book_start_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time )), scl.center)      AS change_time_open,
            longToDatec((MAX(scl.book_start_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time DESC )), scl.center) AS change_time_close,
            c.shortname                                                                                                                   AS ClubName,
            MIN(scl.book_start_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time )                                 AS book_start_time_open,
            MIN(scl.book_end_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time )                                   AS book_end_time_open,
            MAX(scl.book_start_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time DESC )                            AS book_start_time_close,
            MAX(scl.book_end_time) over (partition BY scl.center, scl.id ORDER BY scl.book_start_time DESC)                               AS book_end_time_close
        FROM
            subscriptions s
        CROSS JOIN
            params
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            scl.center = s.center
            AND scl.id = s.id
            AND SCL.ENTRY_TYPE = 2
            AND SCL.stateid IN (2,4,8)
        JOIN
            products pd
        ON
            pd.center = s.subscriptiontype_center
            AND pd.id = s.subscriptiontype_id
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = pd.center
            AND pglink.product_id = pd.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        JOIN
            centers c
        ON
            c.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
            AND pg.name = 'Plus Subscriptions MS'
            AND scl.book_start_time <= params.EndDateLong
            AND NVL(scl.book_end_time+5000, params.StartDateLong ) >= params.StartDateLong
    )
    ,
    v_open AS
    (
        SELECT DISTINCT
            openclose.PersonId,
            openclose.change_time_open AS change_time,
            openclose.ClubName,
            'Extra Open Member' AS feature
        FROM
            v_open_close openclose
        CROSS JOIN
            params
        WHERE
            openclose.book_start_time_open <= params.StartDateLong
            AND NVL(openclose.book_end_time_open+5000, params.StartDateLong ) >= params.StartDateLong
    )
    ,
    v_close AS
    (
        SELECT DISTINCT
            openclose.PersonId,
            openclose.change_time_close AS change_time,
            openclose.ClubName,
            'Extra Close Member' AS feature
        FROM
            v_open_close openclose
        CROSS JOIN
            params
        WHERE
            openclose.book_start_time_close <= params.EndDateLong
            AND NVL(openclose.book_end_time_close+5000, params.EndDateLong ) >= params.EndDateLong
    )
    ,
    v_joiner AS
    (
        SELECT DISTINCT
            s.OWNER_CENTER || 'p' || s.OWNER_ID    AS PersonId,
            longToDatec(s.creation_time, s.center) AS change_time,
            c.shortname                            AS ClubName,
            'Extra Joiner Member'                  AS feature
        FROM
            subscriptions s
        CROSS JOIN
            params
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            scl.center = s.center
            AND scl.id = s.id
            AND SCL.ENTRY_TYPE = 2
            AND SCL.stateid = 8
            /* Created */
            AND scl.book_start_time BETWEEN params.StartDateLong AND params.EndDateLong
            /* Member should be either lead, inactive or prospect during time of change or transferred one another club */
        JOIN
            STATE_CHANGE_LOG SCL2
        ON
            scl2.center = s.OWNER_CENTER
            AND scl2.id = s.OWNER_ID
            AND SCL2.ENTRY_TYPE = 1
            AND ((
                    scl2.stateid IN (0,
                                     2,
                                     6)
                    AND scl.book_start_time BETWEEN scl2.book_start_time AND NVL(scl2.book_end_time, scl.book_start_time))
                OR (
                    scl2.stateid = 4
                    AND scl.book_start_time BETWEEN scl2.book_start_time AND NVL(scl2.book_end_time, scl.book_start_time)+(60*1000)))
        JOIN
            products pd
        ON
            pd.center = s.subscriptiontype_center
            AND pd.id = s.subscriptiontype_id
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = pd.center
            AND pglink.product_id = pd.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        JOIN
            centers c
        ON
            c.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
            AND pg.name = 'Plus Subscriptions MS'
			/* Exclude switcher */
			AND NOT EXISTS ( select 1 from subscription_change sc where sc.new_subscription_center = s.center AND sc.new_subscription_id = s.id AND sc.type = 'TYPE')
    )
    ,
    v_switch AS
    (
        SELECT
            PersonId,
            change_time,
            ClubName,
            'Extra Switch Member' AS feature
        FROM
            (
                SELECT DISTINCT
                    s_new.OWNER_CENTER || 'p' || s_new.OWNER_ID AS PersonId,
                    longToDate(sc.CHANGE_TIME)                  AS change_time,
                    scl.stateid,
                    c.shortname                                                                      AS ClubName,
                    rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
                FROM
                    subscription_change sc
                CROSS JOIN
                    params
                JOIN
                    subscriptions s_new
                ON
                    s_new.CENTER = sc.NEW_SUBSCRIPTION_CENTER
                    AND s_new.ID = sc.NEW_SUBSCRIPTION_ID
                JOIN
                    centers c
                ON
                    c.id = s_new.owner_center
                JOIN
                    products pro_new
                ON
                    pro_new.center = s_new.subscriptiontype_center
                    AND pro_new.id = s_new.subscriptiontype_id
                JOIN
                    subscriptions s_old
                ON
                    s_old.CENTER = sc.OLD_SUBSCRIPTION_CENTER
                    AND s_old.ID = sc.OLD_SUBSCRIPTION_ID
                JOIN
                    products pro_old
                ON
                    pro_old.center = s_old.subscriptiontype_center
                    AND pro_old.id = s_old.subscriptiontype_id
                    /* Member should be active during time of change or transfered from another club */
                JOIN
                    STATE_CHANGE_LOG SCL
                ON
                    scl.center = s_new.OWNER_CENTER
                    AND scl.id = s_new.OWNER_ID
                    AND SCL.ENTRY_TYPE = 1
                    AND ((
                            scl.stateid = 1
                            AND sc.CHANGE_TIME BETWEEN scl.entry_start_time AND NVL(scl.entry_end_time, sc.CHANGE_TIME))
                        OR (
                            scl.stateid = 4
                            AND sc.CHANGE_TIME BETWEEN scl.entry_start_time AND NVL(scl.entry_end_time, sc.CHANGE_TIME)+(60*1000)))
                WHERE
                    s_new.owner_center IN ($$Scope$$)
                    AND sc.type LIKE 'TYPE'
                    AND sc.cancel_time IS NULL
                    /* Subscription change from non 'Plus Subscriptions MS' products to 'Plus Subscriptions MS' product */
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            product_and_product_group_link pglink_old,
                            product_group pg_old
                        WHERE
                            pglink_old.product_center = pro_old.center
                            AND pglink_old.product_id = pro_old.id
                            AND pg_old.id = pglink_old.product_group_id
                            AND pg_old.name = 'Plus Subscriptions MS')
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            product_and_product_group_link pglink_new,
                            product_group pg_new
                        WHERE
                            pglink_new.product_center = pro_new.center
                            AND pglink_new.product_id = pro_new.id
                            AND pg_new.id = pglink_new.product_group_id
                            AND pg_new.name = 'Plus Subscriptions MS')
                    AND sc.CHANGE_TIME BETWEEN params.StartDateLong AND params.EndDateLong
                    /* Member should have an active subscription during the change */
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL
                        WHERE
                            SCL.CENTER = s_new.CENTER
                            AND SCL.ID = s_new.ID
                            AND SCL.ENTRY_TYPE = 2
                            AND SCL.STATEID IN (2,4,
                                                8)
                            AND SCL.ENTRY_START_TIME <= sc.CHANGE_TIME
                            AND (
                                SCL.ENTRY_END_TIME IS NULL
                                OR SCL.ENTRY_END_TIME > sc.CHANGE_TIME ) ))
        WHERE
            rnk = 1
            AND stateid = 1
    )
    ,
    v_leaver AS
    (
        SELECT DISTINCT
            s.OWNER_CENTER || 'p' || s.OWNER_ID         AS PersonId,
            longToDatec(scl.book_start_time, scl.center) AS change_time,
            c.shortname                                 AS ClubName,
            'Extra Leaver Member'                       AS feature
        FROM
            subscriptions s
        CROSS JOIN
            params
        JOIN
            STATE_CHANGE_LOG SCL
        ON
            scl.center = s.center
            AND scl.id = s.id
            AND SCL.ENTRY_TYPE = 2
            AND SCL.stateid = 3
            /* ENDED */
            AND scl.book_start_time+5000 BETWEEN params.StartDateLong AND params.EndDateLong
        JOIN
            products pd
        ON
            pd.center = s.subscriptiontype_center
            AND pd.id = s.subscriptiontype_id
        JOIN
            product_and_product_group_link pglink
        ON
            pglink.product_center = pd.center
            AND pglink.product_id = pd.id
        JOIN
            product_group pg
        ON
            pg.id = pglink.product_group_id
        JOIN
            centers c
        ON
            c.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
            AND pg.name = 'Plus Subscriptions MS'
            /*Do not count members who still have an active subscription within the product group 'Active subscriptions MS' unless they are transferred during filter period. Do not count same subscription from above */
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    subscriptions sub,
					STATE_CHANGE_LOG SCL2,
                    products pd1,
                    product_and_product_group_link pglink1,
                    product_group pg1
                WHERE
                    sub.owner_center = s.owner_center
                    AND sub.owner_id = s.owner_id
					AND sub.id != s.id
                    AND scl2.center = sub.center
                    AND scl2.id = sub.id
                    AND scl2.ENTRY_TYPE = 2
                    AND scl2.stateid = 2	
                    AND scl2.entry_start_time BETWEEN params.StartDateLong AND params.EndDateLong										
                    AND pd1.center = sub.subscriptiontype_center
                    AND pd1.id = sub.subscriptiontype_id
                    AND pglink1.product_center = pd1.center
                    AND pglink1.product_id = pd1.id
                    AND pg1.id = pglink1.product_group_id
                    AND pg1.name = 'Plus Subscriptions MS'
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL1
                        WHERE
                            scl1.center = s.owner_center
                            AND scl1.id = s.owner_id
                            AND scl1.entry_type = 1
                            AND scl1.stateid = 4
                            AND scl1.entry_start_time BETWEEN params.StartDateLong AND params.EndDateLong))
    )
    ,
    v_bolton_all AS
    (
        SELECT DISTINCT
            s.OWNER_CENTER || 'p' || s.OWNER_ID                         AS PersonId,
            sa.start_date                                               AS start_date,
            NVL(longtodatec(sa.ending_time, sa.center_id), sa.end_date) AS end_date,
            c.shortname                                                 AS ClubName,
            CASE
                WHEN sa.start_date+1 <= params.StartDate
                    AND TRUNC(NVL(NVL(longtodatec(sa.ending_time, sa.center_id), sa.end_date), params.StartDate)) >= params.StartDate
                THEN 'Extra Bolt On Open Member'
                ELSE NULL
            END AS OPEN_MEMBER,
            CASE
                WHEN sa.start_date BETWEEN params.StartDate AND params.EndDate
                THEN 'Extra Bolt On Joiner Member'
                ELSE NULL
            END AS JOIN_MEMBER,
            CASE
                WHEN TRUNC(NVL(longtodatec(sa.ending_time, sa.center_id), sa.end_date)) BETWEEN params.StartDate AND params.EndDate
                THEN 'Extra Bolt On Leaver Member'
                ELSE NULL
            END AS LEAVE_MEMBER,
            CASE
                WHEN sa.start_date <= params.EndDate
                    AND TRUNC(NVL(NVL(longtodatec(sa.ending_time, sa.center_id), sa.end_date)-1, params.StartDate)) >= params.EndDate
                THEN 'Extra Bolt On Close Member'
                ELSE NULL
            END AS CLOSE_MEMBER
        FROM
            SUBSCRIPTION_ADDON sa
        CROSS JOIN
            params
        JOIN
            subscriptions s
        ON
            s.center = sa.subscription_center
            AND s.id = sa.subscription_id
        JOIN
            masterproductregister mpr
        ON
            mpr.id = sa.addon_product_id
            AND mpr.globalid = 'DD_PREMIUM'
        JOIN
            centers c
        ON
            c.id = s.owner_center
        WHERE
            s.owner_center IN ($$Scope$$)
			AND sa.start_date <= NVL(sa.end_date, sa.start_date)			
            AND sa.start_date <= params.EndDate
            AND NVL(NVL(longtodatec(sa.ending_time, sa.center_id), sa.end_date), params.StartDate) >= params.StartDate
    )
    ,
    v_bolton AS
    (
        SELECT
            open_bolton.PersonId,
            open_bolton.start_date AS change_time,
            open_bolton.ClubName,
            open_bolton.OPEN_MEMBER AS feature
        FROM
            v_bolton_all open_bolton
        WHERE
            open_bolton.OPEN_MEMBER IS NOT NULL
        UNION ALL
        SELECT
            join_bolton.PersonId,
            join_bolton.start_date AS change_time,
            join_bolton.ClubName,
            join_bolton.JOIN_MEMBER AS feature
        FROM
            v_bolton_all join_bolton
        WHERE
            join_bolton.JOIN_MEMBER IS NOT NULL
        UNION ALL
        SELECT
            leave_bolton.PersonId,
            leave_bolton.end_date+1 AS change_time,
            leave_bolton.ClubName,
            leave_bolton.LEAVE_MEMBER AS feature
        FROM
            v_bolton_all leave_bolton
        WHERE
            leave_bolton.LEAVE_MEMBER IS NOT NULL
        UNION ALL
        SELECT
            close_bolton.PersonId,
            close_bolton.end_date+1 AS change_time,
            close_bolton.ClubName,
            close_bolton.CLOSE_MEMBER AS feature
        FROM
            v_bolton_all close_bolton
        WHERE
            close_bolton.CLOSE_MEMBER IS NOT NULL
    )
SELECT
    *
FROM
    v_open
UNION ALL
SELECT
    *
FROM
    v_close
UNION ALL
SELECT
    *
FROM
    v_joiner
UNION ALL
SELECT
    *
FROM
    v_switch
UNION ALL
SELECT
    *
FROM
    v_leaver
UNION ALL
SELECT
    *
FROM
    v_bolton