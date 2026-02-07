 SELECT distinct
     bo.name                                                         AS "Classname",
     TO_CHAR(longToDate(bo.STARTTIME),'hh24:mi')                         AS "Class time",
     TO_CHAR(longToDate(bo.STARTTIME),'dd-mm-yyyy')                     AS "Class date",     
     bo.CENTER                                                       AS CENTER,
     su.PERSON_CENTER||'p'||su.person_id                AS INSTRUCTOR_KEY,
     p2.fullname AS INSTRUCTOR_NAME,
     ext.txtvalue as "Staff external ID",
     (bo.stoptime-bo.starttime)/60000 ||' min' as "Duration of the class",
c.org_code as "Organisation code",
     c.shortname as "center name"
     
     
 FROM
    bookings bo

 JOIN
     STAFF_USAGE su
 ON
     su.BOOKING_CENTER = bo.center
 AND su.BOOKING_ID = bo.id
 and su.state != 'CANCELLED'
 
JOIN
     persons p2
 ON
     p2.CENTER = su.PERSON_CENTER
 AND p2.id = su.PERSON_ID

join centers c
on
c.id = bo.center

 left join 
 person_ext_attrs ext
 on
 ext.personcenter = p2.center
 and 
 ext.personid = p2.id
 and ext.name = '_eClub_StaffExternalId'
 
 WHERE
   
  bo.center in (:center)
 AND bo.STARTTIME BETWEEN (:dateFrom) AND (:dateTo)

 ORDER BY
     TO_CHAR(longToDate(bo.STARTTIME),'dd-mm-yyyy'),
     TO_CHAR(longToDate(bo.STARTTIME),'hh24:mi'),
     bo.name 