select 
        per.center, 
        per.id,
        DECODE (per.sex, 'C', 'Company','M','MALE','F','FEMALE') as sex,
        per.BIRTHDATE,
        DECODE (per.persontype, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF',3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR',8,'GUEST','UNKNOWN') AS PERSON_TYPE,
        DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE',3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE',6,'PROSPECT',7,'SLETTTET','UNKNOWN') AS PERSON_STATUS,
        ch.checkin_center as Checkin_center,
        to_char(longtodate(ch.checkin_time), 'YYYY-MM-dd HH24:MI') as checkin_time,
        to_char(longtodate(par.start_time), 'YYYY-MM-dd HH24:MI') as participation_start,
        bo.name as activity,
        c.lastname as companyname
        --pr.name as productname
from 
        persons per
join    
        checkins ch
        on  
        per.center = ch.person_center 
        and per.id = ch.person_id
left join
        participations par  
        on  
        ch.person_center = par.participant_center 
        and ch.person_id = par.participant_id
        and par.state = 'PARTICIPATION'
        and par.start_time between ch.checkin_time and (ch.checkin_time + 7200000)
        and par.center = ch.checkin_center
left join
        bookings bo
        on  
        par.booking_center = bo.center 
        and  par.booking_id = bo.id
left join
        activity act
        on  
        bo.ACTIVITY = act.ID
LEFT JOIN subscriptions s
    ON
        s.OWNER_CENTER = per.CENTER
        AND  s.OWNER_ID = per.ID
        AND  s.STATE IN (2,4)
left JOIN products pr
    ON
        pr.center = s.SUBSCRIPTIONTYPE_CENTER 
        and pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN RELATIVES rel
    ON
        per.CENTER = rel.RELATIVECENTER
        AND  per.id = rel.RELATIVEID
        AND  rel.RTYPE = 2 /* persons in company*/
        AND  rel.status < 3
LEFT JOIN PERSONS c
    ON
        c.CENTER = rel.CENTER
        AND c.id = rel.ID
where
        ch.checkin_time >= :date_from
    and ch.checkin_time < 
:date_to+1
    and ch.checkin_center in
(:scope)

    and (act.id is null or act.ACTIVITY_TYPE = 2)  -- only classes
group by 
        per.center, 
        per.id,
        DECODE (per.sex, 'C', 'Company','M','MALE','F','FEMALE'),
        per.BIRTHDATE,
        DECODE (per.persontype, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF',3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR',8,'GUEST','UNKNOWN'),
        DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE',3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE',6,'PROSPECT',7,'SLETTTET','UNKNOWN'),
        ch.checkin_center,
        longtodate(ch.checkin_time),
to_char(longtodate(par.start_time), 'YYYY-MM-dd HH24:MI'),
        bo.name,
        c.lastname
order by 
	per.center,
	per.id,
	longtodate(ch.checkin_time)