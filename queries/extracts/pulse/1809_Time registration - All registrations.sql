SELECT
    staff.center||'p'||staff.id AS personID,
    staff.fullname,
    act.name AS LocalActivityName,
    actg.name AS Activitygroupname,
    TO_CHAR(longtodate(bo.STARTTIME), 'YYYY-MM-DD') dato,
    TO_CHAR(longtodate(bo.STARTTIME), 'HH24:MI') startTime,
    TO_CHAR(longtodate(bo.STOPTIME), 'HH24:MI') endTime,
    round((bo.stoptime - bo.STARTTIME)/3600000,2) AS duration,
    bo.STATE
FROM
    pulse.bookings bo
JOIN pulse.staff_usage su
ON
    bo.center = su.BOOKING_CENTER
    AND bo.id = su.BOOKING_ID
JOIN pulse.persons staff
ON
    su.person_center = staff.center
    AND su.person_id = staff.id
JOIN pulse.activity act
ON
    bo.activity = act.id
JOIN pulse.activity_group actg
ON
    act.activity_group_id = actg.id
WHERE
    --longtodate(bo.STARTTIME) >= to_date('2012-02-01', 'yyyy-mm-dd')
    --AND longtodate(bo.STARTTIME) <= to_date('2012-02-29', 'yyyy-mm-dd')
    bo.STARTTIME >= :date_from 
    and bo.starttime <= :date_to + (1000*60*60*24)
    AND bo.CENTER in(:scope)
    and bo.STATE = 'ACTIVE'
   /* AND EXISTS
    (
        SELECT
            *
        FROM
            pulse.employees e
        JOIN pulse.employeesroles er
        ON
            e.center = er.center
            AND e.id = er.id
        JOIN pulse.roles ro
        ON
            er.roleid = ro.id
        WHERE
            su.person_center = e.personcenter
            AND su.person_id = e.personid
            AND ro.rolename LIKE 'Membership Advisor'
    )*/
ORDER BY
    staff.center,
    staff.id,
    act.name