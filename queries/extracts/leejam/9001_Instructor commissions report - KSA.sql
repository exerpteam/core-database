-- The extract is extracted from Exerp on 2026-02-08
-- Performance fixes, Exerp. EC-3777 
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
            c.id                                                                   AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'),
            'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
        WHERE
            country = 'SA'
    )
    ,
    materialized_1 AS
    (
        WITH
            areas_total AS MATERIALIZED
            (
                WITH
                    RECURSIVE centers_in_area AS
                    (
                        SELECT
                            a.id,
                            a.parent,
                            ARRAY[id] AS chain_of_command_ids,
                            1         AS level
                        FROM
                            leejam.areas a
                        WHERE
                            a.types LIKE '%system%'
                        AND a.parent IS NULL
                        UNION ALL
                        SELECT
                            a.id,
                            a.parent,
                            array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                            cin.level + 1                                AS level
                        FROM
                            leejam.areas a
                        JOIN
                            centers_in_area cin
                        ON
                            cin.id = a.parent
                    )
                SELECT
                    cin.id AS ID,
                    cin.level,
                    unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
                FROM
                    centers_in_area cin
                LEFT JOIN
                    centers_in_area AS b -- join provides subordinates
                ON
                    cin.id = ANY (b.chain_of_command_ids)
                AND cin.level <= b.level
                GROUP BY
                    1,2
            )
            ,
            person_salary AS MATERIALIZED
            (
                SELECT
                    person_center ,
                    person_id ,
                    staff_group_id,
                    salary,
                    center_id,
                    rank() over (partition BY person_center, person_id, staff_group_id, center_id
                    ORDER BY level DESC) AS rnk
                FROM
                    (
                        SELECT
                            psg.person_center ,
                            psg.person_id ,
                            psg.scope_id ,
                            psg.scope_type ,
                            sg.name AS staff_group_name,
                            sg.id   AS staff_group_id,
                            psg.salary,
                            CASE
                                WHEN psg.scope_type = 'C'
                                THEN psg.scope_id-- override on center
                                ELSE
                                    CASE
                                        WHEN c.id IS NOT NULL
                                        THEN c.ID -- override on tree
                                        ELSE ac.center
                                    END
                            END AS center_id,
                            CASE
                                WHEN psg.scope_type = 'C'
                                THEN 100 -- override on center
                                WHEN psg.scope_type = 'T'
                                THEN 0 -- override on Tree
                                WHEN psg.scope_type = 'A'
                                THEN areas_total.level-- override on Area
                            END AS level
                        FROM
                            leejam.person_staff_groups psg
                        LEFT JOIN
                            areas_total
                        ON
                            areas_total.id = psg.scope_id
                        AND psg.scope_type = 'A'
                        LEFT JOIN
                            leejam.area_centers ac
                        ON
                            ac.area = areas_total.sub_areas
                        JOIN
                            leejam.centers c
                        ON
                            psg.scope_type IN ('T',
                                               'G')
                        OR  (
                                psg.scope_type = 'C'
                            AND psg.scope_id = c.id)
                        OR  (
                                psg.scope_type = 'A'
                            AND ac.CENTER = c.id)
                        JOIN
                            leejam.staff_groups sg
                        ON
                            sg.id = psg.staff_group_id ) t1
            )
        SELECT
            *
        FROM
            person_salary
        WHERE
            rnk = 1
    )
    ,
    materialized_2 AS
    (
        SELECT
            part.center       AS part_center,
            sg.id             AS sg_id,
            instructor.center AS instructor_center,
            instructor.id     AS instructor_id,
            instructor.external_id AS instructor_external_id,
            instructor.fullname,
            pea.txtvalue,
            sg.name AS sg_name,
            b.name  AS booking_name,
            acg.description,
            TO_CHAR(longtodatec(b.starttime,b.center),'YYYY-MM-dd HH24:MI')   AS "Booking start date/time",
           TO_CHAR(longtodatec(b.stoptime, b.center),'YYYY-MM-dd HH24:MI')   AS "Booking end date/time" ,
            c.name                                        AS center_name,
            p.center||'p'||p.id                           AS "Member id" ,
            p.fullname                                    AS "Member name" ,
            pro.name                                      AS "Product name" ,
            cc.clips_initial                              AS "Total number of clips" ,
            invl.net_amount                               AS "Clip card price" ,
            longtodatec(cc.valid_from,cc.center)          AS "Clip card start date" ,
            longtodatec(cc.valid_until,cc.center)         AS "Clip card end date" ,
            cc.clips_left                                 AS "Current clip card balance" ,
            ROUND((invl.net_amount / cc.clips_initial),2) AS "Price per clip" ,
            CASE
                WHEN part.state = 'PARTICIPATION'
                THEN 'PARTICIPATED'
                WHEN part.state = 'CANCELLED'
                THEN 'NO_SHOW'
            END                    AS "Session status",
            part.showup_using_card AS "Membercard swiped",
           acs.staff_group_id,
            su.booking_id

        FROM
            leejam.participations part
        JOIN
            persons p
        ON
            p.center = part.participant_center
        AND p.id = part.participant_id
        AND (
                part.state = 'PARTICIPATION'
            OR  (
                    part.state = 'CANCELLED'
                AND part.cancelation_reason = 'NO_SHOW'))
        JOIN
            params
        ON
            params.CENTER_ID = p.center
        JOIN
            leejam.bookings b
        ON
            b.center = part.booking_center
        AND b.id = part.booking_id
        AND b.starttime BETWEEN params.FromDate AND params.ToDate
        JOIN
            leejam.centers c
        ON
            b.center = c.id
        JOIN
            leejam.activity ac
        ON
            b.activity = ac.id
        AND ac.activity_group_id != 408
        AND (
                ac.activity_type IN (2,4)
            OR  ac.activity_type IN (2)
            AND ac.id IN (1401,1601,1,2))
        JOIN
            leejam.activity_group acg
        ON
            acg.id = ac.activity_group_id
        JOIN
            leejam.activity_staff_configurations acs
        ON
            ac.id = acs.activity_id
        JOIN
            leejam.staff_usage su
        ON
            su.booking_center = b.center
        AND su.booking_id = b.id
        AND su.state = 'ACTIVE'
        AND su.starttime BETWEEN params.FromDate AND params.ToDate
        JOIN
            persons instructor
        ON
            instructor.center = su.person_center
        AND instructor.id = su.person_id
        AND instructor.center IN (:Scope)
        LEFT JOIN
            leejam.person_staff_groups psg
        ON
            instructor.center = psg.person_center
        AND instructor.id = psg.person_id
        AND psg.staff_group_id = acs.staff_group_id
        LEFT JOIN
            person_ext_attrs pea
        ON
            instructor.center = pea.personcenter
        AND instructor.id = pea.personid
        AND pea.name = '_eClub_StaffExternalId'
        LEFT JOIN
            leejam.staff_groups sg
        ON
            sg.id = psg.staff_group_id
        JOIN
            leejam.privilege_usages pu
        ON
            part.center = pu.target_center
        AND part.id = pu.target_id
        AND pu.target_service = 'Participation'
        AND pu.target_start_time >= params.FromDate
        AND pu.target_start_time <= params.ToDate
        JOIN
            leejam.clipcards cc
        ON
            cc.center = pu.source_center
        AND cc.id = pu.source_id
        AND cc.subid = pu.source_subid
        JOIN
            leejam.products pro
        ON
            pro.center = cc.center
        AND pro.id = cc.id
        JOIN
            leejam.invoice_lines_mt invl
        ON
            cc.invoiceline_center = invl.center
        AND cc.invoiceline_id = invl.id
        AND cc.invoiceline_subid = invl.subid
    
        
    )
  ,
    materialized_3 AS
    (
    (
        SELECT
            acs.staff_group_id     AS StaffGroupID ,
            instructor.external_id AS Instructor ,
            part.booking_id,
            COUNT(su.booking_id)   AS TotalBooking
        FROM
            leejam.bookings b
        JOIN
            leejam.staff_usage su
        ON
            su.booking_center = b.center
        AND su.booking_id = b.id
        AND su.state = 'ACTIVE'
        JOIN
            leejam.activity ac
        ON
            b.activity = ac.id
       -- AND ac.activity_type = 4
        JOIN
            leejam.activity_group acg
        ON
            acg.id = ac.activity_group_id
        JOIN
            leejam.activity_staff_configurations acs
        ON
            ac.id = acs.activity_id
        JOIN
            leejam.participations part
        ON
            b.center = part.booking_center
        AND b.id = part.booking_id
        JOIN
            persons instructor
        ON
            instructor.center = su.person_center
        AND instructor.id = su.person_id
        JOIN
            params
        ON
            params.CENTER_ID = b.center
        WHERE
           part.state = 'PARTICIPATION'
       AND ac.activity_group_id != 408
        AND su.person_center IN (:Scope)
        AND su.starttime BETWEEN params.FromDate AND params.ToDate
        GROUP BY
            acs.staff_group_id ,
            instructor.external_id,
            part.booking_id
    )
    )    
    
    
SELECT DISTINCT
    m2.fullname     AS "Instructor name" ,
    m2.txtvalue     AS "Instructor id" ,
    m2.sg_name      AS "Staff group" ,
    m1.salary       AS "Staff group rate" ,
    m2.booking_name AS "Session name" ,
    m2.description  AS "Activity group" ,
    m2."Booking start date/time" ,
    m2."Booking end date/time" ,
    m2.center_name AS "Centre" ,
    m2."Member id" ,
    m2."Member name" ,
    m2."Product name" ,
    m2."Total number of clips" ,
    m2."Clip card price" ,
    m2."Clip card start date" ,
    m2."Clip card end date" ,
    m2."Current clip card balance" ,
    m2."Price per clip" ,
    m2."Session status" ,
    m2."Membercard swiped" ,
   CASE
        WHEN m2.staff_group_id = 201
        THEN  ROUND((m2."Clip card price" / m2."Total number of clips") * (0.40),2)
        WHEN m2."Session status" = 'PARTICIPATED'
        AND m2.staff_group_id IN (202,203,204)
        AND m3.TotalBooking BETWEEN 1 AND 6
        THEN ROUND((m2."Clip card price" / m2."Total number of clips") * (0.30),2)
        WHEN m2."Session status" = 'PARTICIPATED'
        AND m2.staff_group_id IN (202,203,204)
        AND m3.TotalBooking BETWEEN 7 AND 12
        THEN ROUND((m2."Clip card price" / m2."Total number of clips") * (0.40),2)
        WHEN m2."Session status" = 'PARTICIPATED'
        AND m2.staff_group_id IN (202,203,204)
        AND m3.TotalBooking BETWEEN 13 AND 7000
        THEN ROUND((m2."Clip card price" / m2."Total number of clips") * (0.50),2)
        ELSE ROUND((m2."Clip card price" / m2."Total number of clips") * (m1.salary/100),2)
    END AS "Commission due"
   
    
FROM
    materialized_2 m2
LEFT JOIN
    materialized_1 m1
ON
    m1.center_id = m2.part_center
AND m1.staff_group_id = m2.sg_id
AND m1.person_center = m2.instructor_center
AND m1.person_id = m2.instructor_id
LEFT JOIN
    materialized_3 m3
ON
    m2.instructor_external_id = m3.Instructor
AND m2.booking_id = m3.booking_id