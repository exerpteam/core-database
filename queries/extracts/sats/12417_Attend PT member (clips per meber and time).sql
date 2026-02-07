SELECT 
    a.booking_resource_center as Center,
c.name,
b.name, 
a.person_center,
a.person_id, 
TO_DATE('01011970', 'DDMMYYYY') + a.START_TIME/(24*3600*1000) + 1/24 as AttendTime,
  longToDate(a.START_TIME) as attendtime2
FROM 
    eclub2.attends a
Join centers c on 
a.booking_resource_center = c.id
JOIN 
    eclub2.booking_resources b 
    ON 
    a.booking_resource_center = b.center and a.booking_resource_id = b.id WHERE 
    a.person_center = :PCenter 
AND a.person_id =:Pid
  /* and a.booking_resource_id <> 1 */
and
b.name ='Personal Training' and
a.START_TIME BETWEEN  :Startfrom AND 
:Startto 