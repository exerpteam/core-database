-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6040


WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR(CURRENT_DATE - $$Days_back$$, 'YYYY-MM-dd HH24:MI'),'Europe/Berlin') AS FROMDATE,
            datetolongTZ(TO_CHAR(CURRENT_DATE, 'YYYY-MM-dd HH24:MI'),'Europe/Berlin')              AS TODATE
    )
SELECT
    not_booked_staff.FULLNAME                                               AS "Employee Name",
    not_booked_staff.StaffPersonCenter||'p'||not_booked_staff.StaffPersonId AS "Employee id",
    list_groups.StaffGroups                                                 AS "Staff group(s)",
    ROUND((params.TODATE - last_booked.LastTime) / (24*3600000))            AS "Number of days back",
    c.SHORTNAME                                                             AS "Club",
    encode(gdpr_note.big_text, 'escape')                                    AS "Note",
    TO_CHAR(TO_DATE(first_time.TXTVALUE,'YYYY-MM-dd'),'DD.MM.YYYY')         AS "Creation Date"
	
FROM
    PARAMS,
    (
        SELECT
            p.center AS StaffPersonCenter,
            p.id     AS StaffPersonId,
            p.FULLNAME
        FROM
            persons p
        JOIN
            EMPLOYEES e
        ON
            p.CENTER = e.PERSONCENTER
            AND p.ID = e.PERSONID
        WHERE
            p.center IN ($$center$$)
            AND e.USE_API = 1
            AND e.BLOCKED = 0
            AND (
                e.PASSWD_EXPIRATION IS NULL
                OR e.PASSWD_EXPIRATION >= CURRENT_DATE)
        EXCEPT
        SELECT
            su.person_center AS StaffPersonCenter,
            su.person_id     AS StaffPersonId,
            p.FULLNAME
        FROM
            bookings b
        CROSS JOIN
            params
        JOIN
            activity ac
        ON
            b.activity = ac.id
            AND ac.activity_type = 4
        JOIN
            participations par
        ON
            b.center = par.booking_center
            AND b.id = par.booking_id
            AND par.STATE <> 'CANCELLED'
        JOIN
            staff_usage su
        ON
            su.booking_center = b.center
            AND su.booking_id = b.id
        JOIN
            persons p
        ON
            su.PERSON_CENTER = p.center
            AND su.PERSON_ID = p.id
        WHERE
            b.starttime >= params.fromdate
            AND b.starttime < params.todate
            AND su.person_center IN ($$center$$) ) not_booked_staff
JOIN
    centers c
ON
    c.ID = not_booked_staff.StaffPersonCenter
LEFT JOIN
    (
        SELECT
            p.CENTER,
            p.id,
            STRING_AGG(sg.NAME, ',' ORDER BY sg.NAME) AS StaffGroups
        FROM
            persons p
        JOIN
            person_staff_groups ps
        ON
            ps.person_center = p.center
            AND ps.person_id = p.id
        JOIN
            STAFF_GROUPS sg
        ON
            sg.ID = ps.STAFF_GROUP_ID
        GROUP BY
            p.center,
            p.id,
            p.FULLNAME ) list_groups
ON
    list_groups.CENTER = not_booked_staff.StaffPersonCenter
    AND list_groups.ID = not_booked_staff.StaffPersonId
LEFT JOIN
    (
        SELECT
            su.person_center,
            su.person_id,
            MAX(b.StartTime) AS LastTime
        FROM
            PARAMS,
            bookings b
        JOIN
            activity ac
        ON
            b.activity = ac.id
            AND ac.activity_type = 4
        JOIN
            participations par
        ON
            b.center = par.booking_center
            AND b.id = par.booking_id
            AND par.STATE <> 'CANCELLED'
        JOIN
            staff_usage su
        ON
            su.booking_center = b.center
            AND su.booking_id = b.id
        WHERE
            su.person_center IN ($$center$$)
            AND b.starttime < params.todate
        GROUP BY
            su.person_center,
            su.person_id ) last_booked
ON
    last_booked.person_center = not_booked_staff.StaffPersonCenter
    AND last_booked.person_id = not_booked_staff.StaffPersonId
LEFT JOIN
    (
        SELECT
            rank() over (partition BY je.PERSON_CENTER, je.PERSON_ID ORDER BY je.CREATION_TIME DESC) AS rnk,
            je.person_center,
            je.person_id,
            je.big_text
        FROM
            JOURNALENTRIES je
        WHERE
            je.JETYPE = 3
            AND UPPER(TRIM(je.name)) = 'GDPR NOTE') gdpr_note
ON
    gdpr_note.PERSON_CENTER = not_booked_staff.StaffPersonCenter
    AND gdpr_note.PERSON_ID = not_booked_staff.StaffPersonId
    AND gdpr_note.RNK = 1
LEFT JOIN
    PERSON_EXT_ATTRS first_time
ON
    not_booked_staff.StaffPersonCenter = first_time.PERSONCENTER
    AND not_booked_staff.StaffPersonId = first_time.PERSONID
    AND first_time.NAME = 'CREATION_DATE'

