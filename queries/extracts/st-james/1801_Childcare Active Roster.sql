-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            getstartofday((:from_date)::DATE::TEXT, c.id) AS from_time,
            getendofday((:to_date)::    DATE::TEXT, c.id) AS to_time ,
            c.id,
            c.time_zone,
            c.name
        FROM
            centers c
             where c.id in (:centers)
    )
SELECT
    TO_CHAR(to_timestamp(at.start_time/1000) at TIME zone at.time_zone, 'MM/DD/YY HH24:MI') AS
    "Dropoff",
    CASE
        WHEN at.stop_time IS NULL
        THEN NULL
        ELSE TO_CHAR(to_timestamp(at.stop_time/1000) at TIME zone at.time_zone, 'MM/DD/YY HH24:MI' 
            )
    END AS "Actual Pickup",
    TO_CHAR((to_timestamp(at.start_time/1000) at TIME zone at.time_zone) + interval '3 hours' ,
    'MM/DD/YY HH24:MI')                                                   AS "Latest Pickup",
    p.fullname                                                            AS "Child Name",
    EXTRACT(YEAR FROM age( now() AT TIME ZONE at.time_zone, p.birthdate)) AS "Age",
    CASE
        WHEN at.stop_time IS NULL and ( 
                now() AT                           TIME ZONE at.time_zone) 
            > (to_timestamp(at.start_time/1000) at TIME zone at.time_zone) + interval '3 hours' 
        THEN 'Overdue'
        WHEN at.stop_time IS NULL
        THEN 'Dropped Off'
        ELSE 'Picked Up'
    END AS "Status",
    CASE
        WHEN EXTRACT(YEAR FROM age( now() AT TIME ZONE at.time_zone, p.birthdate)) < 1
        THEN 'Laugh, Learn & Play Babies'
        ELSE 'Laugh, Learn & Play'
    END AS "Room",
    CASE
        WHEN (
                (
                    COALESCE(at.stop_time, (EXTRACT(EPOCH FROM now())*1000)::bigint) -
                    at.start_time)
                / 60000 )
            ::INT < 60
        THEN ((COALESCE(at.stop_time, (EXTRACT(EPOCH FROM now())*1000)::bigint) - at.start_time) /
            60000 )::INT || ' min'
        ELSE (((COALESCE(at.stop_time, (EXTRACT(EPOCH FROM now())*1000)::bigint) - at.start_time) 
            / 60000 )::INT / 60) || ' hr ' || (((COALESCE(at.stop_time, (EXTRACT(EPOCH FROM now()) 
            *1000):: bigint) - at.start_time) / 60000 )::INT %60)::INT || ' min'
    END        AS "Elapsed Time",
    r.fullname AS "Dropoff Guardian",
    CASE
        WHEN at.stop_time IS NULL
        THEN NULL
        ELSE r.fullname
    END AS "Picked up Guardian"
FROM
    (   SELECT 
            at.stop_time , 
            at.start_time,
            at.person_center,
            at.person_id,
            c.time_zone,
            ROW_NUMBER() over( 
                          PARTITION BY 
                              at.person_center, 
                              at.person_id 
                          ORDER BY 
                              at.start_time ) rn 
        FROM 
            attends at
        JOIN
            params c
        ON
            at.center=c.id
        JOIN
            booking_resources br
        ON
            at.booking_resource_center=br.center
        AND at.booking_resource_id=br.id
        JOIN
            booking_resource_configs brc
        ON
            brc.booking_resource_center=br.center
        AND brc.booking_resource_id=br.id
        WHERE
            brc.group_id=1001
        AND at.start_time >= c.from_time 
        AND at.start_time <= c.to_time
         
      
        
         ) at
JOIN
    persons p
ON
    p.center=at.person_center
AND p.id=at.person_id
LEFT JOIN --finding families and main person as guardian
    lateral
    (   SELECT
            STRING_AGG (p_f.fullname, ',') AS fullname
        FROM
            relatives r
        JOIN
            relatives r_f
        ON
            r.relativecenter=r_f.relativecenter
        AND r.relativeid=r_f.relativeid
        AND r_f.RTYPE = 19
        AND r_f.status=1
        JOIN
            persons p_f
        ON
            r_f.center=p_f.center
        AND r_f.id=p_f.id
        WHERE
            p.center=r.center
        AND p.id=r.id
        AND r.status=1
        AND r.rtype=22 )r
ON
    true
WHERE 
    at.rn=1
  