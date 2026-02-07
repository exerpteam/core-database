SELECT DISTINCT
    "Club name",
    "Class name",
    "Class activity group",
    "Membership id",
    "Member full name",
    "Date of class",
    "Time of class",
    "Booking status",
    "Date booking made",
    "User interface",
    "Member Home club",
    "Current active subscription",
    "Mem Cat",
    "Member age",
    "Member external id"
FROM
    (
        SELECT
            c.SHORTNAME "Club name",
            act.NAME "Class name",
            ag.NAME "Class activity group",
            p.CENTER || 'p' || p.ID "Membership id",
            p.FULLNAME "Member full name",
            p.EXTERNAL_ID "Member external id",
            cp.SHORTNAME "Member Home club",
            age(p.BIRTHDATE) "Member age",
            FIRST_VALUE(prod.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY
            pg.EXCLUDE_FROM_MEMBER_COUNT ASC) "Current active subscription",
            FIRST_VALUE(pg.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY
            pg.EXCLUDE_FROM_MEMBER_COUNT ASC) "Mem Cat",
            TO_CHAR(longToDateC(book.STARTTIME,book.CENTER),'YYYY-MM-DD') "Date of class",
            TO_CHAR(longToDateC(book.STARTTIME,book.CENTER),'HH24:MI') "Time of class",
            TO_CHAR(longToDateC(par.CREATION_TIME,book.CENTER),'YYYY-MM-DD HH24:MI') "Date booking made",
            CASE
                WHEN par.STATE = 'CANCELLED'
                THEN par.CANCELATION_REASON
                ELSE par.STATE
            END "Booking status",
            CASE par.USER_INTERFACE_TYPE
                WHEN 0
                THEN 'OTHER'
                WHEN 1
                THEN 'CLIENT'
                WHEN 2
                THEN 'WEB'
                WHEN 3
                THEN 'KIOSK'
                WHEN 4
                THEN 'SCRIPT'
                WHEN 6
                THEN 'MOBILE'
                ELSE 'UNKNOWN'
            END AS "User interface"
        FROM
            PARTICIPATIONS par
        JOIN
            PERSONS p
        ON
            p.CENTER = par.PARTICIPANT_CENTER
        AND p.ID = par.PARTICIPANT_ID
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
        AND s.OWNER_ID = p.ID
        AND s.STATE IN (2)
        LEFT JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        JOIN
            CENTERS cp
        ON
            cp.id = p.CENTER
        JOIN
            BOOKINGS book
        ON
            book.CENTER = par.BOOKING_CENTER
        AND book.ID = par.BOOKING_ID
            /* Only class activity */
        JOIN
            ACTIVITY act
        ON
            act.ID = book.ACTIVITY
        AND act.ACTIVITY_TYPE = 2
        JOIN
            ACTIVITY_GROUP ag
        ON
            ag.ID = act.ACTIVITY_GROUP_ID
        JOIN
            CENTERS c
        ON
            c.ID = book.CENTER
        WHERE
            (
                'ALL' IN ($$ACTIVITY$$)
            OR  act.NAME LIKE REPLACE($$ACTIVITY$$,'*','%'))
        AND par.CENTER IN ($$SCOPE$$)
        AND book.STARTTIME BETWEEN $$START_DATE$$ AND $$END_DATE$$ + (1000*60*60*24)-1
        AND (
                $$RAQUETS$$ = 'ALL'
            OR  prod.NAME LIKE $$RAQUETS$$)
        AND (
                'ALL' IN ($$AG$$)
            OR  ag.NAME LIKE REPLACE($$AG$$,'*','%'))
        ORDER BY
            c.SHORTNAME,
            book.STARTTIME,
            act.NAME ) t