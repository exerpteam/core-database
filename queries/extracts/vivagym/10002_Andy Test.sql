WITH params AS MATERIALIZED
(
        SELECT 
                dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromDate,
                dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as toDate,
                c.id AS center_id
        FROM vivagym.centers c
        WHERE c.country = 'ES'
)      
SELECT
        t1.center || 'p' || t1.id AS PersonId,
        t1.checkinId,
        TO_CHAR(t1.CheckinTime, 'YYYY-MM-DD HH24:MI'),
        count(*) 
FROM
(  
        SELECT
                rank() over (partition by p.center,p.id,c.id ORDER BY a.start_time DESC) ranking,
                p.center,
                p.id,
                c.id AS checkinId,
                a.center || 'att' || a.id AS attendId,
                longtodatec(c.checkin_time, c.checkin_center) AS CheckinTime,
                longtodatec(c.checkout_time, c.checkin_center) AS CheckoutTime,
                longtodatec(a.start_time, a.center) AS AttendStart,
                longtodatec(a.stop_time, a.center) AS AttendEnd
        FROM persons p
        JOIN params par ON par.center_id = p.center
        JOIN vivagym.checkins c ON p.center = c.person_center AND p.id = c.person_id
        JOIN vivagym.attends a ON p.center = a.person_center AND p.id = a.person_id
        JOIN vivagym.booking_resources br ON a.booking_resource_center = br.center AND a.booking_resource_id = br.id
        WHERE
                p.center IN (:Center)
                AND c.checkin_result = 1
                AND c.checkin_time BETWEEN par.fromDate AND par.toDate
                AND a.start_time BETWEEN par.fromDate AND par.toDate
                AND a.attend_using_card = true
                AND a.state = 'ACTIVE'
                AND a.start_time BETWEEN c.checkin_time AND c.checkout_time
                AND br.name IN ('Check-in','Check in')
                AND br.type = 'GATE'
) t1
GROUP BY
        t1.center,
        t1.id,
        t1.checkinId,
        t1.CheckinTime
HAVING COUNT(*) > 1
        