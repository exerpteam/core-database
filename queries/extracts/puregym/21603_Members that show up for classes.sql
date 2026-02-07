
select 
    cen.NAME                                                            AS "Home club",  
    bookingcen.name                                                     AS "Booking center",
    person.center||'p'||person.id                                       as PNumber,
    person.fullname                                                     as "Full Name",
	person.ZIPCODE as "Post Code",
    person.external_id                                                  as "External id",
    email.TXTVALUE                                                      as Email,
    phonehome.TXTVALUE                                                  as HomePhone,
    mobile.TXTVALUE                                                     as Mobile,
    ag.name                                                             AS "Activity type",        
    DECODE(USER_INTERFACE_TYPE, 0,'App', 1,'Staff',2,'Website')         as "Booking interface",
    to_char(longToDateTZ(bo.STARTTIME, 'Europe/London'),'YYYY-MM-DD HH24:MI') as "Class start",
    TO_CHAR(longtodateTZ(par.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI')       AS "Booking date",
    an.name                                                             as activity
from
     persons person
join participations par
    on
        person.center = par.participant_center
    and person.id = par.participant_id
join privilege_usages pu
    on
        par.center = pu.target_center 
    and par.id = pu.target_id
    and PU.TARGET_SERVICE = 'Participation'
join bookings bo
    on  
        par.booking_center = bo.center 
    and par.booking_id = bo.id
join activity an
    on  
     bo.activity = an.id
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = an.activity_group_id          
LEFT JOIN
    PERSON_EXT_ATTRS mobile
    on mobile.PERSONCENTER = person.CENTER and  mobile.PERSONID = person.ID and mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS phonehome
    on phonehome.PERSONCENTER = person.CENTER and  phonehome.PERSONID = person.ID and phonehome.NAME = '_eClub_PhoneHome'

LEFT JOIN
    PERSON_EXT_ATTRS email
    on email.PERSONCENTER = person.CENTER and  email.PERSONID = person.ID and email.NAME = '_eClub_Email'
JOIN
    CENTERS cen
ON
    cen.ID = person.CENTER
JOIN
    CENTERS bookingcen
ON
    bookingcen.ID = bo.CENTER    
WHERE
    PU.privilege_type = 'BOOKING'
and par.state = 'PARTICIPATION'
and par.booking_center in ($$scope$$)
and par.START_TIME >= ($$date_from$$) 
and par.start_time <= ($$date_to$$)
order by
    person.center,
    person.id,
    par.START_TIME



