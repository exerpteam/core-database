-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    bk.name                                                           AS "Activity",
    TO_CHAR(longtodateC(bk.starttime,bk.center),'YYYY-MM-DD HH12:MI') AS "Date/Time",
    p_old.fullname                                                    AS "Instructor Name",
    p_old.external_id                                                 AS "Instructor ExternalID",
    p_new.fullname                                                    AS "Substitute Instructor",
    p_new.external_id                                                 AS
    "Substitute Instructor ExternalID",
    TO_CHAR(longtodateC(su_old.available_for_subst_time,bk.center),'YYYY-MM-DD HH12:MI') AS
    "Made Available Time",
    TO_CHAR(longtodateC(su_old.cancellation_time,bk.center),'YYYY-MM-DD HH12:MI') AS "Pick Up Time"
    ,
    su_old.booking_center||'book'||su_old.booking_id AS "Booking ID"
FROM
    staff_usage su_old
JOIN
    bookings bk
ON
    bk.center = su_old.booking_center
AND bk.id = su_old.booking_id
LEFT JOIN
    booking_change bc
ON
    su_old.booking_id=bc.booking_id
AND su_old.booking_center = bc.booking_center
AND bc.type='STAFF_SUBSTITUTION'
AND bc.value_before = '' || su_old.id
JOIN
    persons p_old
ON
    su_old.person_center = p_old.center
AND su_old.person_id = p_old.id
LEFT JOIN
    staff_usage su_new
ON
    '' || su_new.id = bc.value_after
AND su_new.booking_id=bc.booking_id
AND su_new.booking_center = bc.booking_center
LEFT JOIN
    persons p_new
ON
    su_new.person_id=p_new.id
AND su_new.person_center=p_new.center
WHERE
    bk.center IN (:center)
AND ( (
            su_old.available_for_subst_time >= :From_date
        AND su_old.available_for_subst_time < (24*3600*1000 + :to_date))
    OR  (
            su_old.cancellation_time >= :From_date
        AND su_old.cancellation_time < (24*3600*1000 + :to_date)) )
AND ( (
            su_new.id IS NOT NULL)
    OR  (
            su_new.id IS NULL
        AND su_old.available_for_substitution='true'));