

SELECT
    TRAINER                                                                   AS "Service Provider",
    center_name                                         AS "Club",
    TO_CHAR(to_date(START_DATETIME,'yyyy-mm-dd'),'Day')                          AS "Day of Week",
    TO_CHAR(to_date(START_DATETIME,'yyyy-mm-dd'),'mm-dd-yyyy')                   AS "Date",
    TO_CHAR(to_TIMESTAMP(start_datetime,'YYYY-MM-DD HH24:MI:SS'),'FMHH12:MI am') AS "Time",
    duration                                                                     AS "Duration",
    ACTIVITY_GROUP                                                               AS "Service Type",
    ACTIVITY                                                                     AS "Service",
    MEMBER_ID                                                                    AS "ID",
    firstname                                                                    AS "First Name",
    lastname                                                                     AS "Last Name",
    age                                                                          AS "Age",
    address1                                                                     AS "Address",
    province                                                                     AS "State",
    zipcode                                                                      AS "Zip",
    memPhone                                                                     AS "Phone",
    memEmail                                                                     AS "Email",
payrollSystem
AS "Payroll System"
    --,bk_id
    --zipcode AS "Zip Code"
    --t.*
FROM
    (
        WITH
            params AS
            (
                SELECT
                    c.id   AS CENTER_ID,
                    c.name AS center_name,
                    datetolongc(TO_CHAR(to_date($$fromdate$$, 'YYYY-MM-DD HH24:MI:SS'),
                    'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
                    datetolongc(TO_CHAR(to_date($$todate$$, 'YYYY-MM-DD HH24:MI:SS'),
                    'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
                FROM
                    centers c
                WHERE
                    c.id IN ($$scope$$)
            )
        SELECT
            b.center||'book'||b.id                                           AS bk_id,
            per.fullname                                                     AS TRAINER,
            TO_CHAR(longtodatec(b.STARTTIME,b.center), 'YYYY-MM-DD HH24:MI') AS START_DATETIME,
            (b.stoptime-b.starttime)/(60*1000)                               AS duration,
            b.NAME                                                           AS BOOKING_NAME,
            center_name,
            a.name                      AS ACTIVITY,
            ag.NAME                     AS ACTIVITY_GROUP,
            mem.center || 'p' || mem.id AS MEMBER_ID,
            mem.external_id             AS MEMBER_ExID,
            mem.fullname                AS MEMBER_FULLNAME,
            mem.firstname,
            mem.lastname,
            mem.address1,
            CASE 
            WHEN mem.birthdate > (CURRENT_DATE - interval '1 year')
            THEN date_part('month', age(mem.birthdate :: TIMESTAMP)) || ' months'
            ELSE
            date_part('year', age(mem.birthdate :: TIMESTAMP)) || ' years'
            END as age,
            --z.city,
            mem.zipcode,
            mem.city,
            province.province,
            part.state              AS PARTICIPATION_STATE,
            part.cancelation_reason AS CANCELLATION_REASON,
            CASE
                WHEN part.state = 'BOOKED'
                THEN 'N/A'
                WHEN part.state = 'PARTICIPATION'
                THEN 'Show-up'
                WHEN part.state = 'CANCELLED'
                AND part.cancelation_reason = 'NO_SHOW'
                THEN 'No-Show'
                WHEN part.state = 'CANCELLED'
                AND part.cancelation_reason = 'BOOKING'
                THEN 'Booking cancelled'
                WHEN part.state = 'CANCELLED'
                AND part.cancelation_reason = 'NO_PRIVILEGE'
                THEN 'Cancelled (No privilege)'
                WHEN part.state = 'CANCELLED'
                AND part.cancelation_reason IN ('USER',
                                                'CENTER')
                THEN 'Cancelled by staff or user'
                ELSE 'Other'
            END            AS SHOWUP_STATUS,
            email.txtvalue AS memEmail,
            phone.txtvalue AS memPhone,
            payroll.txtvalue AS payrollSystem
        FROM
            bookings b
        JOIN
            params
        ON
            b.center = center_id
        JOIN
            ACTIVITY a
        ON
            a.id = b.ACTIVITY
        JOIN
            ACTIVITY_GROUP ag
        ON
            ag.id = a.ACTIVITY_GROUP_ID
        LEFT JOIN
            STAFF_USAGE su
        ON
            su.BOOKING_CENTER = b.center
        AND su.BOOKING_ID = b.id
        AND su.state = 'ACTIVE'
        LEFT JOIN
            persons per
        ON
            per.CENTER = su.PERSON_CENTER
        AND per.ID = su.PERSON_ID
        LEFT JOIN
            chelseapiers.person_ext_attrs payroll
        ON 
            per.center = payroll.personcenter
        AND per.id = payroll.personid
        AND payroll.name = '_eClub_EmployeeTitle'
        
        JOIN
            PARTICIPATIONS part
        ON
            b.center = part.BOOKING_CENTER
        AND b.id = part.BOOKING_ID
        JOIN
            PERSONS mem
        ON
            mem.center = part.participant_center
        AND mem.id = part.participant_id
        LEFT JOIN
            zipcodes province
        ON
            mem.zipcode = province.zipcode
        AND province.country = 'US'
        AND province.province IS NOT NULL
        LEFT JOIN
            person_ext_attrs email
        ON
            email.personcenter=mem.center
        AND email.personid=mem.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs phone
        ON
            phone.personcenter=mem.center
        AND phone.personid=mem.id
        AND phone.name = '_eClub_PhoneHome'
        WHERE
            b.state = 'ACTIVE'
        AND
            CASE ((:serviceProvider) || '')
                WHEN 'Enter the first few letters or full name of the Service Provider'
                THEN PER.fullname ILIKE ('%')
                WHEN 'none'
                THEN PER.fullname ILIKE ('%')
                WHEN 'None'
                THEN PER.fullname ILIKE ('%')
                ELSE PER.fullname ILIKE ((:serviceProvider) || '%')
            END
        AND
            CASE ((:serviceType) || '')
                WHEN 'Enter the first few letters or full name of the Service Type'
                THEN ag.name ILIKE ('%')
                WHEN 'none'
                THEN ag.name ILIKE ('%')
                WHEN 'None'
                THEN ag.name ILIKE ('%')
                ELSE ag.name ILIKE ((:serviceType) || '%')
            END
        AND
            CASE ((:service) || '')
                WHEN 'Enter the first few letters or full name of the Service'
                THEN a.name ILIKE ('%')
                WHEN 'none'
                THEN a.name ILIKE ('%')
                WHEN 'None'
                THEN a.name ILIKE ('%')
                ELSE a.name ILIKE ((:service) || '%')
            END
        AND b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE          
        ORDER BY
            START_DATETIME,
            TRAINER,
            BOOKING_NAME,
            MEMBER_FULLNAME)t
    --where member_exID='1638'
GROUP BY
    TRAINER ,
    center_name,
    START_DATETIME,
    duration,
    ACTIVITY_GROUP,
    ACTIVITY,
    MEMBER_ID,
    firstname,
    lastname,
    age,
    address1,
    memEmail,
    memPhone,
    payrollSystem,
    zipcode,
    province
    --HAVING COUNT(*)>1