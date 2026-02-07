WITH
    params AS MATERIALIZED
    (
        SELECT
            :StartDate       AS FromDateTime,
            :EndDate    	AS ToDateTime
        
    )
SELECT
    p.center || 'p' || p.id AS "PersonId",
    case 
    when mobile.txtvalue is null
    then REPLACE( home.txtvalue, '+447','07')
    else REPLACE( mobile.txtvalue, '+447','07')
    End as  "Phone number",
    email.txtvalue          AS "Alternative contact",
    to_char(longtodatetz(ch.CHECKIN_TIME,'Europe/London'), 'HH24:MI') AS "Time in",
    to_char(longtodatetz(ch.CHECKIN_TIME,'Europe/London'), 'DD/MM/YYYY') AS "Log date",
    c.name as "Venue",
    p.firstname             AS "First Name",
    p.lastname              AS "Last Name",  
    p.address1              AS "Address Line 1",
    p.address2              AS "Address Line 2",
    p.address3              AS "Address Line 3",
    p.zipcode               AS "Post Code"
FROM
checkins ch
join
    persons p
on
ch.person_center = p.center
AND ch.person_id = p.id

CROSS JOIN
    params

LEFT JOIN
    person_ext_attrs mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    person_ext_attrs pe
ON
    pe.personcenter = p.center
    AND pe.personid = p.id
    AND pe.name = 'TRACKTRACE'
	AND pe.txtvalue = 'false'
left join
centers c
on
CHECKIN_CENTER = c.id

WHERE
    p.status IN (1,3)
    /* pe.personcenter is null means either deafult value true or          pe.txtvalue = 'true' */
	AND pe.personcenter is null 
    and ch.CHECKIN_CENTER IN (:Scope)
    and ch.checkin_time <= params.ToDateTime
    AND ch.checkin_time >= params.FromDateTime