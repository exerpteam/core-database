select
 cen.NAME as HomeClub,
 p.FULLNAME,
 e.IDENTITY as PIN,
 pem.TXTVALUE as Email,
 br.NAME,
TO_CHAR(longtodateTZ(att.START_TIME,'Europe/Zurich'),'DD/MM/YYYY HH24:MI') as AttendTime
 from ATTENDS att
 join BOOKING_RESOURCES br
 on br.CENTER = att.BOOKING_RESOURCE_CENTER
 and br.ID = att.BOOKING_RESOURCE_ID
 join PERSONS p
 on p.CENTER = att.PERSON_CENTER
 and p.ID = att.PERSON_ID
 join CENTERS cen
 on cen.ID = p.CENTER
 LEFT JOIN
     ENTITYIDENTIFIERS e
 ON
     e.IDMETHOD = 5
     AND e.ENTITYSTATUS = 1
     AND e.REF_CENTER = p.CENTER
     AND e.REF_ID = p.ID
     AND e.REF_TYPE = 1
 LEFT JOIN
     person_ext_attrs pem
 ON
     pem.personcenter = p.center
     AND pem.personid = p.id
     AND pem.name = '_eClub_Email'
 where
 att.CENTER in (:center)
 and att.START_TIME between (:starttime) and (:endtime)
