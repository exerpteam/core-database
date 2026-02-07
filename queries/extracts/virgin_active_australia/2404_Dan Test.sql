-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    "Club name",
    "Class name",
	"Instructor ID",
	"Instructor name",
    "Class activity group",
    "Membership id",
	--"Email",
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
            c.SHORTNAME AS "Club name",
            act.NAME AS "Class name",
            ag.NAME AS "Class activity group",
            p.CENTER || 'p' || p.ID AS "Membership id",
			email.txtvalue AS "Email",
            p.FULLNAME AS "Member full name",
            p.EXTERNAL_ID AS "Member external id",
            cp.SHORTNAME AS "Member Home club",
            age(p.BIRTHDATE) AS "Member age",
			staff.center || 'p' || staff.ID AS "Instructor ID",
            staff.FULLNAME   AS "Instructor name",
            FIRST_VALUE(prod.NAME) OVER (PARTITION BY s.OWNER_CENTER, s.OWNER_ID 
                ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT ASC) AS "Current active subscription",
            FIRST_VALUE(pg.NAME) OVER (PARTITION BY s.OWNER_CENTER, s.OWNER_ID 
                ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT ASC) AS "Mem Cat",
            TO_CHAR(longToDateC(book.STARTTIME, book.CENTER)::DATE, 'YYYY-MM-DD') AS "Date of class",
            TO_CHAR(longToDateC(book.STARTTIME, book.CENTER)::TIME, 'HH24:MI') AS "Time of class",
            TO_CHAR(longToDateC(par.CREATION_TIME, book.CENTER), 'YYYY-MM-DD HH24:MI') AS "Date booking made",
            CASE
                WHEN par.STATE = 'CANCELLED' THEN par.CANCELATION_REASON
                ELSE par.STATE
            END AS "Booking status",
            CASE par.USER_INTERFACE_TYPE
                WHEN 0 THEN 'OTHER'
                WHEN 1 THEN 'CLIENT'
                WHEN 2 THEN 'WEB'
                WHEN 3 THEN 'KIOSK'
                WHEN 4 THEN 'SCRIPT'
                WHEN 6 THEN 'MOBILE'
                ELSE 'UNKNOWN'
            END AS "User interface"
        FROM
            PARTICIPATIONS par
        JOIN PERSONS p
            ON p.CENTER = par.PARTICIPANT_CENTER
            AND p.ID = par.PARTICIPANT_ID
		LEFT JOIN PERSON_EXT_ATTRS email 
    ON p.center = email.personcenter 
   AND p.id = email.personid 
   AND email.name = '_eClub_Email'
        LEFT JOIN SUBSCRIPTIONS s
            ON s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2)
        LEFT JOIN PRODUCTS prod
            ON prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCT_GROUP pg
            ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        JOIN CENTERS cp
            ON cp.ID = p.CENTER
        JOIN BOOKINGS book
            ON book.CENTER = par.BOOKING_CENTER
            AND book.ID = par.BOOKING_ID
		JOIN
     STAFF_USAGE su
 ON
     book.CENTER = su.BOOKING_CENTER
     AND book.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
	 JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     book.ID = bru.BOOKING_ID
     AND book.CENTER = bru.BOOKING_CENTER
         AND bru.STATE = 'ACTIVE'
 JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
        /* Only class activity */
        JOIN ACTIVITY act
            ON act.ID = book.ACTIVITY
            AND act.ACTIVITY_TYPE = 2
        JOIN ACTIVITY_GROUP ag
            ON ag.ID = act.ACTIVITY_GROUP_ID
        JOIN CENTERS c
            ON c.ID = book.CENTER
        WHERE
            (
                :ACTIVITY = 'ALL' OR act.NAME LIKE REPLACE(:ACTIVITY, '*', '%')
            )
            AND par.CENTER IN (:SCOPE)
            AND book.STARTTIME BETWEEN EXTRACT(EPOCH FROM (:START_DATE::TIMESTAMP)) * 1000 
                                  AND (EXTRACT(EPOCH FROM (:END_DATE::TIMESTAMP)) + 86400) * 1000 - 1
            AND (
                :AG = 'ALL' OR ag.NAME LIKE REPLACE(:AG, '*', '%')
            )
        ORDER BY
            c.SHORTNAME,
            book.STARTTIME,
            act.NAME
    ) t;