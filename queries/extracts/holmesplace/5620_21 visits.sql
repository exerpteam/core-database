-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT DISTINCT
    c.SHORTNAME                         as "Center Name",
    p.CENTER || 'p' || p.ID          pid,
    s.CENTER || 'ss' || s.ID         sid,
    cstaff.FULLNAME                   sales_employee,
    p.FIRSTNAME || ' ' || p.LASTNAME "Name",
    s.START_DATE,
    (
        SELECT
            COUNT(DISTINCT TO_CHAR(longToDate(cx.CHECKIN_TIME),'yyyy-MM-dd') )
        FROM
            HP.CHECKINS cx
        WHERE
            cx.PERSON_CENTER = p.CENTER
            AND cx.PERSON_ID = p.ID
            AND cx.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(s.START_DATE + (:periodLength*1),'YYYY-MM-dd HH24:MI')) ) AS x_checkins,
    (
        SELECT
            COUNT(DISTINCT TO_CHAR(longToDate(cx.CHECKIN_TIME),'yyyy-MM-dd') )
        FROM
            HP.CHECKINS cx
        WHERE
            cx.PERSON_CENTER = p.CENTER
            AND cx.PERSON_ID = p.ID
            AND cx.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(s.START_DATE + (:periodLength*2),'YYYY-MM-dd HH24:MI')) ) AS y_checkins,
    (
        SELECT
            COUNT(DISTINCT TO_CHAR(longToDate(cx.CHECKIN_TIME),'yyyy-MM-dd') )
        FROM
            HP.CHECKINS cx
        WHERE
            cx.PERSON_CENTER = p.CENTER
            AND cx.PERSON_ID = p.ID
            AND cx.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(s.START_DATE + (:periodLength*3),'YYYY-MM-dd HH24:MI')) ) AS z_checkins,
    (
        SELECT
            COUNT(DISTINCT TO_CHAR(longToDate(cx.CHECKIN_TIME),'yyyy-MM-dd') )
        FROM
            HP.CHECKINS cx
        WHERE
            cx.PERSON_CENTER = p.CENTER
            AND cx.PERSON_ID = p.ID
            AND cx.CHECKIN_TIME BETWEEN dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(CURRENT_DATE, 'YYYY-MM-dd HH24:MI')) ) AS all_checkins,
    (
        SELECT
            longToDate(MAX(cx.CHECKIN_TIME))
        FROM
            HP.CHECKINS cx
        WHERE
            cx.PERSON_CENTER = p.CENTER
            AND cx.PERSON_ID = p.ID ) AS last_checkin,
    (
        SELECT
            COUNT(*)
        FROM
            HP.SUBSCRIPTION_BLOCKED_PERIOD srp
        WHERE
            srp.SUBSCRIPTION_CENTER = s.CENTER
            AND srp.SUBSCRIPTION_ID = s.ID
            AND srp.STATE = 'ACTIVE'
            AND (
                s.START_DATE + (0 * :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE
                OR s.START_DATE + (1* :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE ) )x_blocked_periods,
    (
        SELECT
            COUNT(*)
        FROM
            HP.SUBSCRIPTION_BLOCKED_PERIOD srp
        WHERE
            srp.SUBSCRIPTION_CENTER = s.CENTER
            AND srp.SUBSCRIPTION_ID = s.ID
            AND srp.STATE = 'ACTIVE'
            AND (
                s.START_DATE + (1 * :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE
                OR s.START_DATE + (2* :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE ) ) y_blocked_periods,
    (
        SELECT
            COUNT(*)
        FROM
            HP.SUBSCRIPTION_BLOCKED_PERIOD srp
        WHERE
            srp.SUBSCRIPTION_CENTER = s.CENTER
            AND srp.SUBSCRIPTION_ID = s.ID
            AND srp.STATE = 'ACTIVE'
            AND (
                s.START_DATE + (2 * :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE
                OR s.START_DATE + (3* :periodLength) BETWEEN srp.START_DATE AND srp.END_DATE ) ) z_blocked_periods,
    /*
    CASE
    WHEN p.STATUS IN (1,3)
    THEN ROUND(sysdate - p.LAST_ACTIVE_START_DATE)
    ELSE ROUND(p.LAST_ACTIVE_END_DATE - p.LAST_ACTIVE_START_DATE)
    END AS active_days
    */
    ROUND(CURRENT_DATE - s.START_DATE) active_days
FROM
    HP.SUBSCRIPTIONS s
JOIN
    HP.PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    HP.PRODUCT_GROUP pg
ON
    pg.id = prod.PRIMARY_PRODUCT_GROUP_ID
JOIN
    HP.PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
    AND p.PERSONTYPE != 2
LEFT JOIN
    HP.PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.id
    AND atts.NAME = 'Sales_Staff'
LEFT JOIN
    HP.PERSONS staff
ON
    staff.center||'p'||staff.id = atts.TXTVALUE
    left join HP.PERSONS cstaff on cstaff.CENTER = staff.CURRENT_PERSON_CENTER and cstaff.id = staff.CURRENT_PERSON_ID
LEFT JOIN
    HP.SUBSCRIPTION_REDUCED_PERIOD srp
ON
    srp.SUBSCRIPTION_CENTER = s.CENTER
    AND srp.SUBSCRIPTION_ID = s.ID
    AND srp.STATE = 'ACTIVE'
    join HP.CENTERS c on c.id = p.CENTER
WHERE
    s.START_DATE BETWEEN :fromDate AND :endDate
    /*AND s.START_DATE < (sysdate - (:periodLength * 3) )*/
    AND s.CENTER IN (:scope)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            HP.STATE_CHANGE_LOG scl2
        JOIN
            HP.SUBSCRIPTIONS s2
        ON
            1=1
        WHERE
            scl2.STATEID IN (2,4)
            AND scl2.center = s2.CENTER
            AND scl2.id = s2.ID
            AND scl2.ENTRY_TYPE = 2
            AND s2.OWNER_CENTER = s.OWNER_CENTER
            AND s2.OWNER_ID = s.OWNER_ID
            AND (
                s2.CENTER,s2.ID ) NOT IN ((s.CENTER,
                                           s.id))
            AND ( (
                    scl2.BOOK_START_TIME BETWEEN dateToLong(TO_CHAR(add_months(s.START_DATE,-3),'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(s.START_DATE, 'YYYY-MM-dd HH24:MI') ) -1000 )
                OR (
                    scl2.BOOK_END_TIME > dateToLong(TO_CHAR(add_months(s.START_DATE,-3),'YYYY-MM-dd HH24:MI') )
                    OR scl2.BOOK_END_TIME IS NULL ) ) )