-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        part.participant_center || 'p' || part.participant_id AS PersonId,
        pea.txtvalue as mosoid,
        to_char(longtodatec(part.start_time, part.center),'YYYY-MM-DD HH24.MI') AS StartTime,
        to_char(longtodatec(part.stop_time, part.center),'YYYY-MM-DD HH24.MI') AS StopTime,
        to_char(longtodatec(part.creation_time, part.center),'YYYY-MM-DD HH24.MI') AS CreationTime,
        part.state,
        b.name,
        b.center || 'book' || b.id AS BookingId,
        cre.fullname AS Creator
FROM chelseapiers.participations part
JOIN chelseapiers.bookings b ON part.booking_center = b.center AND part.booking_id = b.id
LEFT JOIN chelseapiers.person_ext_attrs pea ON part.participant_center = pea.personcenter and part.participant_id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN chelseapiers.persons cre ON cre.center = part.creation_by_center AND cre.id = part.creation_by_id
WHERE
        part.state NOT IN ('CANCELLED')
ORDER BY 5