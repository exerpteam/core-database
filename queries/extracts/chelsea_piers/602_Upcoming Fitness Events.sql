-- The extract is extracted from Exerp on 2026-02-08
-- This extracts shows you the upcoming corporate and member events that will take place in the next 7 days.
SELECT c.name as "Center Name",
       a.name as "Event Name", 
       to_char(longtodatec(b.starttime, b.center), 'MM/DD/YYYY HH24:MI:SS') as "Event Date",
       to_char(longtodatec(b.stoptime, b.center), 'MM/DD/YYYY HH24:MI:SS') as "Event End Date", 
       p.fullname as "Event Coordinator", 
       --p.center,
       --p.id,
       --pp.center,
       --pp.id,
       pp.fullname as "Event Owner",
       pEmail.txtvalue as "Event Owner Email",
       pPhone.txtvalue as "Event Owner Home Phone",
       pMobPhone.txtvalue as "Event Owner Mobile Phone",
	   b.coment as "Event Booking Comment"
       --pp.address1 as "Event Owner Address 1",
       --pp.address2 as "Event Owner Address 2r",
       --pp.city as "Event Owner City",
       --pp.zipcode as "Event Owner Zip Code",
       --b.*
FROM 
   BOOKINGS b
JOIN
   ACTIVITY a
ON
   b.activity = a.id
JOIN
   PERSONS p
ON
   p.center = b.creator_center
AND
   p.id = b.creator_id
JOIN
   ACTIVITY_GROUP ag
ON 
   ag.id = a.activity_group_id
JOIN
   CENTERS c
ON
   c.id = b.center
LEFT JOIN
   PARTICIPATIONS pa
ON
   pa.booking_center = b.center
AND
   pa.booking_id = b.id
LEFT JOIN
   persons pp
ON
   pa.participant_center = pp.center
AND
   pa.participant_id = pp.id
LEFT JOIN
   person_ext_attrs pEmail
ON
   pEmail.personcenter = pa.participant_center
AND
   pEmail.personid = pa.participant_id
AND
   pEmail.name = '_eClub_Email'
LEFT JOIN
   person_ext_attrs pPhone
ON
   pPhone.personcenter = pa.participant_center
AND
   pPhone.personid = pa.participant_id
AND
   pPhone.name = '_eClub_PhoneHome'
LEFT JOIN
   person_ext_attrs pMobPhone
ON
   pMobPhone.personcenter = pa.participant_center
AND
   pMobPhone.personid = pa.participant_id
AND
   pMobPhone.name = '_eClub_PhoneSMS'
WHERE
   b.state = 'ACTIVE'
AND
   ag.name in ('Corporate Events', 'Member Events')
AND
   DATE(longtodatec(b.starttime, b.center)) BETWEEN current_date and current_date + 7