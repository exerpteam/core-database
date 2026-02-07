select distinct 
"Club name",
"Activity name",
"Activity group",
"Membership id",
"Member full name",
"Date of class",
"Start Time",
"End Time",
"Booking status",
"Wait list"
--"Date booking made",
--"User interface",
--"Member Home club"
--"Current active subscription",
--"Mem Cat",
--"Member age",
--"Member external id" 
from (
SELECT 
    c.SHORTNAME "Club name",
    act.NAME "Activity name",
    ag.NAME "Activity group",
    p.CENTER || 'p' || p.ID "Membership id",
    p.FULLNAME "Member full name",
    p.EXTERNAL_ID "Member external id",
    cp.SHORTNAME "Member Home club",
    TRUNC(months_between(SYSDATE, p.BIRTHDATE)/12) "Member age",
    FIRST_VALUE(prod.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT asc) "Current active subscription",
    FIRST_VALUE(pg.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT asc) "Mem Cat",
    TO_CHAR(TRUNC(longToDateC(book.STARTTIME,book.CENTER)),'YYYY-MM-DD') "Date of class",
    TO_CHAR(longToDateC(book.STARTTIME,book.CENTER),'HH24:MI') "Start Time",
TO_CHAR(longToDateC(book.STOPTIME,book.CENTER),'HH24:MI') "End Time",  
  TO_CHAR(TRUNC(longToDateC(par.CREATION_TIME,book.CENTER)),'YYYY-MM-DD') "Date booking made",
    CASE
        WHEN par.STATE = 'CANCELLED'
        THEN par.CANCELATION_REASON
        ELSE par.STATE
    END "Booking status",
DECODE(par.on_waiting_list, 0, 'NO', 1, 'YES') AS "Wait list",
	DECODE(par.USER_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT',6,'MOBILE','UNKNOWN') AS "User interface"
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
    AND act.ACTIVITY_TYPE in (2,3,4)
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
        OR act.NAME like replace($$ACTIVITY$$,'*','%'))
    AND par.CENTER IN (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443)

    AND book.STARTTIME BETWEEN $$START_DATE$$ AND $$END_DATE$$ + (1000*60*60*24)-1
    AND (
        $$RAQUETS$$ = 'ALL'
        OR prod.NAME LIKE $$RAQUETS$$)
AND
(par.state NOT IN('CANCELLED'))

    and (
        'ALL' IN ($$AG$$)
        OR ag.NAME like replace($$AG$$,'*','%')) 

ORDER BY
    c.SHORTNAME,
    book.STARTTIME,
    act.NAME
)