WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate           
      FROM
          centers c
  )
SELECT DISTINCT 
        instructor.fullname                             AS "Instructor name" ,
        instructor.external_id                          AS "Instructor id" ,
        sg.name                                         AS "Staff group" ,
        person_salary.salary                            AS "Staff group rate" ,
        pea.txtvalue                                    AS "PT Level" ,
        b.name                                          AS "Session name" ,
        acg.description                                 AS "Activity group" ,
        longtodatec(b.starttime,b.center)               AS "Booking start date/time" ,
        longtodatec(b.stoptime,b.center)                AS "Booking end date/time" ,
        c.name                                          AS "Centre" ,
        p.center||'p'||p.id                             AS "Member id" ,
        p.fullname                                      AS "Member name" ,
        pro.name                                        AS "Product name" ,
        cc.clips_initial                                AS "Total number of clips" ,
        invl.net_amount                           		AS "Clip card price" ,
        longtodatec(cc.valid_from,cc.center)            AS "Clip card start date" ,
        longtodatec(cc.valid_until,cc.center)           AS "Clip card end date" ,
        cc.clips_left                                   AS "Current clip card balance" ,
        ROUND((invl.net_amount / cc.clips_initial),2) AS "Price per clip" ,
        CASE
                WHEN part.state = 'PARTICIPATION' THEN part.state
                ELSE part.cancelation_reason                                     
        END                                             AS "Session status" ,
        part.showup_using_card                          AS "Membercard swiped" ,
        CASE
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'Old' THEN ROUND((invl.net_amount  / cc.clips_initial) * (person_salary.salary/100),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 1 AND 50 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.30),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 51 AND 69 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.35),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 70 AND 89 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.40),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 90 AND 119 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.45),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 120 AND 139 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.50),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 140 AND 169 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.55),2) 
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id IN (1,2,201) AND pea.txtvalue = 'New' AND totalcount.TotalBooking BETWEEN 170 AND 210 THEN ROUND((invl.net_amount  / cc.clips_initial) * (0.60),2)  
                WHEN part.state = 'PARTICIPATION' AND acs.staff_group_id NOT IN (1,2,201) THEN ROUND((invl.net_amount  / cc.clips_initial) * (person_salary.salary/100),2) 
                ELSE NULL 
        END                                             AS "Commission due"
FROM
        leejam.participations part
JOIN
        leejam.persons p
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN
        leejam.bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN
        leejam.centers c
        ON c.id = b.center
JOIN
        leejam.activity ac
        ON b.activity = ac.id
        AND ac.activity_type = 4
JOIN
        leejam.activity_group acg
        ON acg.id = ac.activity_group_id
JOIN
        leejam.activity_staff_configurations acs
        ON ac.id = acs.activity_id
JOIN
        leejam.staff_usage su
        ON su.booking_center = b.center
        AND su.booking_id = b.id
        AND su.state = 'ACTIVE'
JOIN
        leejam.persons instructor
        ON instructor.center = su.person_center
        AND instructor.id = su.person_id
LEFT JOIN
        leejam.person_staff_groups psg
        ON instructor.center = psg.person_center
        AND instructor.id = psg.person_id
        AND psg.staff_group_id = acs.staff_group_id
LEFT JOIN
        leejam.staff_groups sg
        ON sg.id = psg.staff_group_id
JOIN
        leejam.privilege_usages pu
        ON part.center = pu.target_center
        AND part.id = pu.target_id
        AND pu.target_service = 'Participation'        
JOIN
        leejam.clipcards cc
        ON cc.center = pu.source_center
        AND cc.id = pu.source_id
        AND cc.subid = pu.source_subid
JOIN
        leejam.products pro
        ON pro.center = cc.center
        AND pro.id = cc.id        
JOIN
        leejam.invoice_lines_mt invl
        ON cc.invoiceline_center = invl.center
        AND cc.invoiceline_id = invl.id
        AND cc.invoiceline_subid = invl.subid
LEFT JOIN
        leejam.person_ext_attrs pea
        ON instructor.center = pea.personcenter
        AND instructor.id = pea.personid
        AND pea.name = 'SCALEPT'        
LEFT JOIN
    (
        SELECT
            person_center ,
            person_id ,
            staff_group_id,
            salary,
            center_id,
            rank() over (partition BY person_center, person_id, staff_group_id, center_id ORDER BY
            level DESC) AS rnk
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
                        WHEN psg.scope_type = 'C' THEN psg.scope_id-- override on center
                        ELSE
                            CASE
                                WHEN c.id IS NOT NULL THEN c.ID -- override on tree
                                ELSE ac.center
                            END
                    END AS center_id,
                    CASE
                        WHEN psg.scope_type = 'C' THEN 100 -- override on center
                        WHEN psg.scope_type = 'T' THEN 0 -- override on Tree
                        WHEN psg.scope_type = 'A' THEN areas_total.level-- override on Area                       
                    END AS level
                FROM
                    leejam.person_staff_groups psg
                LEFT JOIN
                    (
                        WITH
                            RECURSIVE centers_in_area AS
                            (
                                SELECT
                                    a.id,
                                    a.parent,
                                    ARRAY[id] AS chain_of_command_ids,
                                    1 AS level
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
                                    cin.level + 1 AS level
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
                            1,2) areas_total
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
                ON sg.id = psg.staff_group_id ) t1) person_salary
                ON person_salary.center_id = part.center
                AND person_salary.staff_group_id = sg.id
                AND person_salary.person_center = instructor.center
                AND person_salary.person_id = instructor.id
                AND person_salary.rnk = 1
JOIN 
        params 
        ON params.CENTER_ID = b.center                  
LEFT JOIN
        (        
        SELECT
                acs.staff_group_id AS StaffGroupID
                ,instructor.external_id AS Instructor
                ,count(su.booking_id) AS TotalBooking        
        FROM 
                leejam.bookings b
        JOIN
                leejam.staff_usage su
                ON su.booking_center = b.center
                AND su.booking_id = b.id
                AND su.state = 'ACTIVE'
        JOIN
                leejam.activity ac
                ON b.activity = ac.id
                AND ac.activity_type = 4
        JOIN
                leejam.activity_group acg
                ON acg.id = ac.activity_group_id 
        JOIN
                leejam.activity_staff_configurations acs
                ON ac.id = acs.activity_id
        JOIN
                leejam.participations part
                ON b.center = part.booking_center
                AND b.id = part.booking_id
        JOIN
                leejam.persons instructor
                ON instructor.center = su.person_center
                AND instructor.id = su.person_id                
        JOIN 
                params 
                ON params.CENTER_ID = b.center
        WHERE
                part.state = 'PARTICIPATION' 
                AND 
                ac.activity_group_id != 408
                AND 
                su.person_center IN (:Scope) 
                AND 
                su.starttime BETWEEN params.FromDate AND params.ToDate
        GROUP BY
                acs.staff_group_id
                ,instructor.external_id
        )totalcount
        ON totalcount.Instructor = instructor.external_id
        AND totalcount.StaffGroupID = acs.staff_group_id                                
WHERE
        (part.state = 'PARTICIPATION' OR part.state = 'CANCELLED')
        AND 
        ac.activity_group_id != 408
        AND 
        instructor.center IN (:Scope)
        AND
        su.starttime BETWEEN params.FromDate AND params.ToDate
