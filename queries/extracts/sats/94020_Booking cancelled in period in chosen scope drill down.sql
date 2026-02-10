-- The extract is extracted from Exerp on 2026-02-08
--  
Select distinct
bo.CENTER                                                       AS CENTER,
c.name as "Center name",
bo.center ||'book'|| bo.id as bookingid,
longtodate(bo.starttime) as "startdate and time of class",
bo.name as "name of class",
((bo.stoptime-bo.starttime)/60000)||'min'  as Duration_of_the_class,
longtodate(bo.cancelation_time) as cancelation_time,
bo.cancellation_reason as "cancellation reason if entered"
--bo.*     
     
 FROM
    bookings bo
join centers c
on
c.id = bo.center




where
 bo.center in (:center) and
 bo.state = 'CANCELLED'
 AND bo.STARTTIME BETWEEN (:dateFrom) AND (:dateTo)
 and bo.activation_time is not null
 
