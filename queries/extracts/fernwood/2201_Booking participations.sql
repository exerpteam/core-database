WITH
        PARAMS AS
                (
                        SELECT
                                /*+ materialize */
                                CAST(datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS BIGINT) AS FROMDATE,
                                CAST((datetolongC(TO_CHAR((CAST(CURRENT_DATE AS DATE)),'YYYY-MM-dd HH24:MI'),c.id)) AS BIGINT) AS TODATE,
                                c.id AS CENTER_ID
                        FROM
                                centers c
                )
        SELECT
                b.center || 'book' || b.id AS BookingID,
                ac.name AS ActivityName,
                p.fullname AS MemberName,
                p.center || 'p' || p.ID AS MemberNumber,
                TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') BookingDate,
                TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') BookingTime,                                               
                su.person_center || 'p' || su.person_id AS StaffPersonNumber,
                par.state AS participationState
                
                
        FROM bookings b
        JOIN params
                ON params.CENTER_ID = b.center
        JOIN staff_usage su
                ON su.booking_center = b.center AND su.booking_id = b.id
        JOIN participations par
                ON b.center = par.booking_center AND b.id = par.booking_id
        JOIN persons p
                ON par.participant_center = p.center AND par.participant_id = p.id
        JOIN activity ac
                ON b.activity = ac.id AND ac.activity_type IN (2,4)
        WHERE
                (su.person_center, su.person_id) IN 
                (       
                        SELECT 
                                DISTINCT
                                p.center,
                                p.id
                        FROM persons p
                        JOIN person_staff_groups ps
                                ON ps.person_center = p.center AND ps.person_id = p.id
                        WHERE
                            p.status IN (0,1,2,3,6,9)
                            AND p.center IN (:center)
                )
                AND b.starttime >= params.fromdate
                AND b.starttime < params.todate
                --GROUP BY BookingID
                Order BY b.starttime, BookingID
                