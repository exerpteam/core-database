SELECT
    staff_ID,
    fullname,
    t.employee_center||'emp'||t.employee_id AS employee_id,
    client_instance                         AS exerp_session_id,
    attempt_count,
    longtodateC(entrytime,178)||' '||cen.time_zone AS lastattmpt,
    cen.name                                       AS center_name,
    ci.hostname                                    AS computer_name,
    ci.username                                    AS computer_user_profile,
    ci.macaddress,
    ci.ipaddress
FROM
    (
        WITH
            params AS
            (
                SELECT
                    c.id AS centerid,
                    datetolongTZ(TO_CHAR(to_date($$from_date$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'
                    ), c.time_zone) AS fromdateBooking,
                    datetolongTZ(TO_CHAR(to_date($$to_date$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'
                    ), c.time_zone) + (24*3600*1000)-1                     AS todateBooking,
                    datetolongTZ(TO_CHAR(now(),'YYYY-MM-DD HH24:MI:SS'),c.time_zone) AS
                    timenow
                FROM
                    centers c
            )
        SELECT
            ela.employee_center,
            ela.employee_id,
            ela.client_instance,
            MAX(ela.entry_time) AS entrytime,
            timenow,
            COUNT(*)      AS attempt_count,
            p.external_id AS staff_ID,
            p.fullname
        FROM
            lifetime.employee_login_attempts ela
        JOIN
            params
        ON
            ela.employee_center = centerid
        JOIN
            lifetime.employees e
        ON
            e.center =employee_center
        AND e.id =employee_id
        JOIN
            lifetime.persons p
        ON
            p.center = e.personcenter
        AND p.id = e.personid
            --WHERE
        WHERE
            p.external_id IN ($$staff_externaID$$)
            --success != true
        AND ela.entry_time BETWEEN fromdateBooking AND todateBooking
        GROUP BY
            ela.employee_center,
            ela.employee_id,
            ela.client_instance,
            timenow,
            staff_ID,
            p.fullname
            --,ela.entry_time
        HAVING
            COUNT(*) > 100 )t
JOIN
    lifetime.client_instances ci
ON
    t.client_instance = ci.id
JOIN
    lifetime.clients c
ON
    ci.client = c.id
JOIN
    centers cen
ON
    c.center = cen.id ;    
        