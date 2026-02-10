-- The extract is extracted from Exerp on 2026-02-08
-- Kids Camp Membership Status
with params as (
SELECT
             c.name as club_of_camp,
            c.id AS CENTER_ID,
            datetolongc(TO_CHAR(to_date(:from_date, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS') , c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date(:to_date, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE,
c.state as club_state
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
SELECT distinct 
b.center||' - '||params.club_of_camp                         AS "Center",
params.club_state                                             AS "Center State",
 p.external_id                                                AS "Member ID",
p.lastname as "Last Name",
p.firstname as "First Name",
    b.name as "Booking",
    to_char(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS "Booking Date", -- to_char( ,'FMMonth dd, yyyy' )                   
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS "Member Age",
    pea.txtvalue as "MMS Pricing Category",
-- Added line 26 and 45 on Feb 15 as per ST-16614 
	pea2.txtvalue as "MMS Registration Category"
FROM
    lifetime.bookings b 
JOIN
    params  on b.center = params.CENTER_ID

    join lifetime.activity a on b.activity = a.id
    and a.activity_type = 11 --CAMP ACTIVITY TYPE
JOIN
    lifetime.participations pa 
ON
    pa.booking_center = b.center
    and pa.booking_id = b.id
    and pa.state != 'CANCELLED'
JOIN
    persons p
ON
    p.center = pa.participant_center
AND p.id = pa.participant_id
join lifetime.person_ext_attrs pea on pea.personcenter = p.center and pea.personid = p.id and pea.name = 'MMSPricingCategory'
-- Added line 26 and 45 on Feb 15 as per ST-16614
join lifetime.person_ext_attrs pea2 on pea2.personcenter = p.center and pea2.personid = p.id and pea2.name = 'MMSRegistrationCategory'
where 
b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE
 AND B.state !='CANCELLED'
 AND (pea.txtvalue = 'NonMember'  OR pea2.txtvalue = 'NonMember')
order by 1,3 asc