-- The extract is extracted from Exerp on 2026-02-08
-- Not time safe, not working.
WITH
    params AS
    (
          SELECT
            /*+ materialize */
           (par.CREATION_TIME,book.CENTER)(to_char(trunc(trunc(sysdate, 'mm') - 1, 'MM'), 'YYYY-MM-DD HH24:MI') AS FROMDATE,
            (par.CREATION_TIME,book.CENTER)(to_char(trunc(sysdate, 'mm') - 1, 'YYYY-MM-DD HH24:MI')) + (1000*60*60*24) AS TODATE
        FROM
            dual
    )

select distinct 
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
"Member external id" from (
SELECT 
    c.SHORTNAME "Club name",
    act.NAME "Class name",
    ag.NAME "Class activity group",
    p.CENTER || 'p' || p.ID "Membership id",
    p.FULLNAME "Member full name",
    p.EXTERNAL_ID "Member external id",
    cp.SHORTNAME "Member Home club",
    TRUNC(months_between(SYSDATE, p.BIRTHDATE)/12) "Member age",
    FIRST_VALUE(prod.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT asc) "Current active subscription",
    FIRST_VALUE(pg.NAME) OVER (PARTITION BY s.OWNER_CENTER,s.OWNER_ID ORDER BY pg.EXCLUDE_FROM_MEMBER_COUNT asc) "Mem Cat",
    TO_CHAR(TRUNC(longToDateC(book.STARTTIME,book.CENTER)),'YYYY-MM-DD') "Date of class",
    TO_CHAR(longToDateC(book.STARTTIME,book.CENTER),'HH24:MI') "Time of class",
    TO_CHAR(TRUNC(longToDateC(par.CREATION_TIME,book.CENTER)),'YYYY-MM-DD') "Date booking made",
    CASE
        WHEN par.STATE = 'CANCELLED'
        THEN par.CANCELATION_REASON
        ELSE par.STATE
    END "Booking status",
	DECODE(par.USER_INTERFACE_TYPE, 1,'STAFF',2,'WEB',3,'KIOSK',4,'SCRIPT',5,'API',6,'MOBILE API',0,'OTHER') AS "User interface"
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
        OR act.NAME like replace($$ACTIVITY$$,'*','%'))
    AND par.CENTER IN (76,
29,
30,
427,
437,
33,
34,
35,
27,
36,
421,
405,
38,
438,
40,
39,
403,
47,
440,
436,
48,
441,
448,
12,
51,
411,
442,
9,
419,
56,
954,
57,
59,
434,
415,
2,
407,
60,
61,
422,
400,
450,
452,
15,
6,
68,
69,
406,
410,
435,
16,
71,
75,
953,
425,
401,
443,
13,
67,
408)
  
    AND (
        $$RAQUETS$$ = 'ALL'
        OR prod.NAME LIKE $$RAQUETS$$)


    and (
        'ALL' IN ($$AG$$)
        OR ag.NAME like replace($$AG$$,'*','%')) 

ORDER BY
    c.SHORTNAME,
    book.STARTTIME,
    act.NAME
)