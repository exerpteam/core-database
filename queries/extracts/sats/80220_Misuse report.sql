 WITH
         params AS
         (
          SELECT
                     /*+ materialize */
                     c.id                                                                                               AS centerid,
                     c.name                                                                                             AS center_name,
                     datetolongTZ (TO_CHAR (current_timestamp, 'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) - cast(30 as bigint)* 24 * 3600 * 1000  AS cutDate --minus 30 days
                FROM
                     centers c
                JOIN
                     countries co
                  ON
                     co.id = c.country
         )
 SELECT DISTINCT
             (pu.id)                                                                          AS "Privilege usage ID",
             pu.person_center || 'p' || pu.person_id                                          AS "Member ID",
             TO_CHAR (longtodateTZ (bk.starttime, 'Europe/Copenhagen'), 'DD/MM/YYYY HH24:MI') AS "Booking start time",
             bk.center                                                                        AS "Booking center ID",
             c.name                                                                           AS "Center name",
             bk.center || 'book' || bk.id                                                     AS "Booking ID",
             bk.name                                                                          AS "Booking name",
             staff.center || 'p' || staff.id                                                  AS "Instructor",
             pu.STATE                                                                         AS "Privilege usage participation status",
             pu.misuse_state                                                                  AS "Misused state",
             mem.external_id
        FROM
             privilege_usages pu
        JOIN
             params
          ON
             params.CenterID = pu.target_center
        JOIN
             participations pa
          ON --pu.target_service = 'Participation' and
             pu.target_center = pa.center
             AND pu.target_id = pa.id
        JOIN
             persons mem
          ON
             pa.participant_center = mem.center
             AND pa.participant_id = mem.id
        JOIN
             bookings bk
          ON
             bk.center = pa.booking_center
             AND bk.id = pa.booking_id
        JOIN
             centers c
          ON
             bk.center = c.id
        JOIN
             activity act
          ON
             bk.activity = act.id
   LEFT JOIN
             activity_group ag
          ON
             act.activity_group_id = ag.id
        JOIN
             staff_usage su
          ON
             bk.center = su.booking_center
             AND bk.id = su.booking_id
        JOIN
             persons staff
          ON
             staff.center = su.person_center
             AND staff.id = su.person_id
        --JOIN employees emp ON staff.center = emp.personcenter AND staff.id = emp.personid
       WHERE
             pu.privilege_type = 'BOOKING'
             AND pu.STATE = 'CANCELLED'
             AND pu.misuse_state IN ('MISUSED', 'PUNISHED')
             AND bk.starttime >= params.cutDate
             AND su.STATE = 'ACTIVE'
             AND mem.external_id IN  (:external_ID)
