 select
     person.center||'p'||person.id as customer,
     person.fullname as customer_name,
     to_char(longToDateTZ(par.START_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI') as ClassStart,
     an.name as activity
 from
      pulse.persons person
 join pulse.participations par
     on
         person.center = par.participant_center
     and person.id = par.participant_id
 join pulse.privilege_usages pu
     on
         par.center = pu.target_center
     and par.id = pu.target_id
     and PU.TARGET_SERVICE = 'Participation'
 join pulse.bookings bo
     on
         par.booking_center = bo.center
     and par.booking_id = bo.id
 join pulse.activity an
     on
      bo.activity = an.id
 WHERE
     PU.privilege_type = 'BOOKING'
 and par.cancelation_reason = 'NO_SHOW'
 and par.booking_center in (:scope)
 and par.START_TIME >= (:date_from)
 and par.start_time <= (:date_to)
 order by
     person.center,
     person.id,
     par.START_TIME
