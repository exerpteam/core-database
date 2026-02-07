Select
t2.center,
t2.name,
round(t2.number_of_hours_cancelled,2)   as "number of hours cancelled in period"

from

(

Select
t1.center,
t1.name,
sum(t1.Duration_of_the_class)/60  as number_of_hours_cancelled

from

(

Select distinct
bo.CENTER                                                       AS CENTER,
c.name,
bo.center ||'book'|| bo.id as bookingid,
((bo.stoptime-bo.starttime)/60000)  as Duration_of_the_class
 
     
     
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
 
 )t1
 
 group by

 t1.center,
t1.name )t2
 
 group by
t2.center, 
t2.name,
t2.number_of_hours_cancelled