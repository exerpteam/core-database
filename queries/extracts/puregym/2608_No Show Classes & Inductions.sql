-- The extract is extracted from Exerp on 2026-02-08
--  
select 
    cen.NAME AS Center,  
	person.center||'p'||person.id as customer,
    person.fullname as customer_name,
    email.TXTVALUE as Email,
    phonehome.TXTVALUE as HomePhone,
    mobile.TXTVALUE as Mobile,
	user_interface_type,
    DECODE(USER_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK') as booking_interface,
    to_char(longToDateTZ(par.START_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI') as ClassStart,
    an.name as activity
from
     puregym.persons person
join puregym.participations par
    on
        person.center = par.participant_center
    and person.id = par.participant_id
join puregym.privilege_usages pu
    on
        par.center = pu.target_center 
    and par.id = pu.target_id
    and PU.TARGET_SERVICE = 'Participation'
join puregym.bookings bo
    on  
        par.booking_center = bo.center 
    and par.booking_id = bo.id
join puregym.activity an
    on  
     bo.activity = an.id
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
    on mobile.PERSONCENTER = person.CENTER and  mobile.PERSONID = person.ID and mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS phonehome
    on phonehome.PERSONCENTER = person.CENTER and  phonehome.PERSONID = person.ID and phonehome.NAME = '_eClub_PhoneHome'

LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
    on email.PERSONCENTER = person.CENTER and  email.PERSONID = person.ID and email.NAME = '_eClub_Email'

LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = person.CENTER

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



