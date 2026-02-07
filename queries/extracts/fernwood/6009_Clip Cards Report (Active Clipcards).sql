SELECT
        t1."PersonID"
        ,t1."ExternalID"
        ,t1."Club Name"
        ,t1."First Name"
        ,t1."Last Name"
        ,t1."Person Status"
        ,t1."Person type" 
        ,t1."Email"
        ,t1."Mobile"
        ,t1."Home"
        ,t1."Clip Card Name"
        ,t1."Start Date"
        ,t1."End Date"
        ,t1."Original Clips"
        ,t1."Remaining Clips"
        ,t1."Amount Paid"
        ,t1."Sold by"
        ,t1."Sold at"
        ,t1."Last Visit Date"
        ,t1."TRAINER'S NAME"  
        ,t1."Last Attended Session Date"
        ,t1."Number of Attended Sessions in Last 28 Days"
        ,t1.product_group_id
        ,t1."Clip Card ID"
        ,t1."Next Booked Session"
FROM
        (                
        SELECT DISTINCT 
                p.center ||'p'||p.id AS "PersonID"
                ,p.external_id AS "ExternalID"
                ,c.shortname AS "Club Name"
                ,p.firstname AS "First Name"
                ,p.lastname AS "Last Name"
                        ,CASE
                        p.status
                        WHEN 0 THEN 'Lead'
                        WHEN 1 THEN 'Active'
                        WHEN 2 THEN 'Inactive'
                        WHEN 3 THEN 'Temporary Inactive'
                        WHEN 4 THEN 'Transferred'
                        WHEN 5 THEN 'Duplicate'
                        WHEN 6 THEN 'Prospect'
                        WHEN 7 THEN 'Deleted'
                        WHEN 8 THEN 'Anonymized'
                        WHEN 9 THEN 'Contact'
                 END AS "Person Status"
                        ,CASE
                                p.persontype
                                WHEN 0 THEN 'Private'
                                WHEN 1 THEN 'Student'
                                WHEN 2 THEN 'Staff'
                                WHEN 3 THEN 'Friend'
                                WHEN 4 THEN 'Corporate'
                                WHEN 5 THEN 'One Man Corporate'
                                WHEN 6 THEN 'Family'
                                WHEN 7 THEN 'Senior'
                                WHEN 8 THEN 'Guest'
                                WHEN 9 THEN 'Child'
                                WHEN 10 THEN 'External Staff' 
                        END AS "Person type" 
                        ,peeaEmail.txtvalue AS "Email"
                ,peeaMobile.txtvalue AS "Mobile"
                ,peeaHome.txtvalue AS "Home"
                ,pro.name AS "Clip Card Name"
                ,longtodatec(cc.valid_from,cc.center) AS "Start Date"
                ,longtodatec(cc.valid_until,cc.center) AS "End Date"
                ,cc.clips_initial AS "Original Clips"
                ,cc.clips_left AS "Remaining Clips"
                ,inv.total_amount AS "Amount Paid"
                ,pe.fullname AS "Sold by"
                ,cclip.shortname AS "Sold at"
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,instructor."TRAINER'S NAME"  
                ,longtodatec(t.LatestVisit,t.owner_center) AS "Last Attended Session Date"
                ,t1.totalpu AS "Number of Attended Sessions in Last 28 Days"
                ,pgl.product_group_id
                ,cc.center||'cc'||cc.id||'cc'||cc.subid AS "Clip Card ID"
                ,longtodatec(t2.NextBookedSession,t2.person_center) AS "Next Booked Session"
        FROM 
                fernwood.persons p
        JOIN 
                fernwood.clipcards cc 
                ON cc.owner_center = p.center 
                AND cc.owner_id = p.id
                AND cc.cancelled = 'false' 
                AND cc.finished = 'false' 
                AND cc.blocked = 'false' 
        JOIN 
                fernwood.centers c 
                ON c.id = p.center
        JOIN 
                fernwood.centers cclip
                ON cc.center = cclip.id
        JOIN 
                fernwood.products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID                                   
        LEFT JOIN 
                fernwood.invoice_lines_mt inv
                ON cc.invoiceline_center = inv.center
                AND cc.invoiceline_id = inv.id
                AND cc.invoiceline_subid = inv.subid  
        LEFT JOIN 
                fernwood.invoices i
                ON inv.center = i.center     
                AND inv.id = i.id   
        LEFT JOIN 
                fernwood.employees emp
                ON emp.CENTER = i.employee_center
                AND emp.ID = i.employee_id
        LEFT JOIN 
                fernwood.persons pe
                ON pe.CENTER = emp.PERSONCENTER
                AND pe.ID = emp.PERSONID  
        LEFT JOIN 
                fernwood.person_ext_attrs peeaEmail
                ON peeaEmail.personcenter = p.center
                AND peeaEmail.personid = p.id
                AND peeaEmail.name = '_eClub_Email'
        LEFT JOIN 
                fernwood.person_ext_attrs peeaMobile
                ON peeaMobile.personcenter = p.center
                AND peeaMobile.personid = p.id
                AND peeaMobile.name = '_eClub_PhoneSMS' 
        LEFT JOIN 
                fernwood.person_ext_attrs peeaHome
                ON peeaHome.personcenter = p.center
                AND peeaHome.personid = p.id
                AND peeaHome.name = '_eClub_PhoneHome'
        LEFT JOIN
                (SELECT max(checkin_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID             
                FROM fernwood.checkins 
                GROUP BY person_center,person_id ) la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id
        LEFT JOIN
                (
                SELECT 
                        *
                FROM
                        (SELECT 
                                max(part.id) AS MaxID
                                ,part.center
                                ,part.participant_center
                                ,part.participant_id               
                        FROM 
                                fernwood.participations part
                        JOIN 
                                fernwood.persons p 
                                ON p.center = part.participant_center
                                AND p.id = part.participant_id
                        JOIN 
                                fernwood.bookings b
                                ON b.center = part.booking_center
                                AND b.id = part.booking_id
                        JOIN 
                                fernwood.activity ac
                                ON b.activity = ac.id
                                AND ac.activity_type = 4
                        WHERE 
                                part.state = 'PARTICIPATION'
                        GROUP BY 
                                part.center
                                ,part.participant_center
                                ,part.participant_id
                        )t1                   
                JOIN
                        (
                        SELECT  
                                part.id
                                ,part.center
                                ,part.participant_center AS PersonCenter
                                ,part.participant_id AS PersonID
                                ,p2.fullname AS "TRAINER'S NAME"                
                        FROM 
                                fernwood.participations part
                        JOIN 
                                fernwood.bookings b
                                ON b.center = part.booking_center
                                AND b.id = part.booking_id
                        JOIN 
                                fernwood.activity ac
                                ON b.activity = ac.id
                                AND ac.activity_type = 4
                        JOIN 
                                fernwood.STAFF_USAGE su
                                ON su.BOOKING_CENTER = b.center
                                AND su.BOOKING_ID = b.id
                                AND su.state = 'ACTIVE'
                        LEFT JOIN 
                                fernwood.persons p2
                                ON p2.CENTER = su.PERSON_CENTER
                                AND p2.id = su.PERSON_ID 
                        )t2
                                ON t1.maxid = t2.id
                                AND t1.center = t2.center 
                )instructor
                        ON instructor.participant_center = p.center
                        AND instructor.participant_id = p.id
        JOIN 
                fernwood.masterproductregister mpr
                ON mpr.globalid = pro.globalid
                AND mpr.scope_type = 'A'
        JOIN
                fernwood.privilege_grants pgr
                ON pgr.granter_id = mpr.id
                AND pgr.valid_to IS NULL
        JOIN
                fernwood.privilege_sets pse
                ON pse.id = pgr.privilege_set            
        LEFT JOIN
                (SELECT 
                        max(par.showup_time) AS LatestVisit
                        ,par.owner_center
                        ,par.owner_id
                        ,ps.Name 
                FROM 
                        fernwood.privilege_usages pu
                JOIN
                        fernwood.privilege_grants pg
                        ON pg.ID = pu.GRANT_ID
                        AND pg.valid_to IS NULL 
                JOIN    
                        fernwood.privilege_sets ps
                        ON ps.ID = pg.privilege_set                              
                JOIN 
                        fernwood.participations par
                        ON par.center = pu.target_center
                        AND par.id = pu.target_id
                        AND pu.target_service = 'Participation' 
                WHERE
                        pu.state != 'Cancelled'
                        AND
                        par.owner_center IN (:Scope)               
                GROUP BY
                        par.owner_center
                        ,par.owner_id
                        ,ps.Name             
                )t                
                        ON pse.Name = t.Name
                        AND p.center = t.owner_center
                        AND p.id = t.owner_id        
        LEFT JOIN
                (SELECT 
                        count(par.showup_time) AS totalpu
                        ,par.owner_center
                        ,par.owner_id
                        ,ps.Name
                FROM 
                        fernwood.privilege_usages pu
                JOIN
                        fernwood.privilege_grants pg
                        ON pg.ID = pu.GRANT_ID 
                        AND pg.valid_to IS NULL
                JOIN    
                        fernwood.privilege_sets ps
                        ON ps.ID = pg.privilege_set                            
                JOIN 
                        fernwood.participations par
                        ON par.center = pu.target_center
                        AND par.id = pu.target_id
                        AND pu.target_service = 'Participation' 
                WHERE
                        pu.state != 'Cancelled'
                        AND
                        (current_date - (CAST(longtodatec(par.showup_time,par.booking_center) as date))) <= 28
                        AND
                        par.owner_center IN (:Scope)              
                GROUP BY
                        par.owner_center
                        ,par.owner_id 
                        ,ps.Name              
                )t1                
                        ON pse.Name = t1.Name
                        AND p.center = t1.owner_center
                        AND p.id = t1.owner_id
        LEFT JOIN
                        (SELECT 
                                max(pu.target_start_time) AS NextBookedSession
                                ,pu.person_center
                                ,pu.person_id
                                ,ps.Name 
                        FROM 
                                fernwood.privilege_usages pu
                        JOIN
                                fernwood.privilege_grants pg
                                ON pg.ID = pu.GRANT_ID
                                AND pg.valid_to IS NULL 
                        JOIN    
                                fernwood.privilege_sets ps
                                ON ps.ID = pg.privilege_set                              
                        WHERE
                                pu.state = 'PLANNED'
                                AND
                                pu.person_center IN (:Scope)               
                        GROUP BY
                                pu.person_center
                                ,pu.person_id
                                ,ps.Name             
                        )t2                
                                ON pse.Name = t2.Name
                                AND p.center = t2.person_center
                                AND p.id = t2.person_id          
        LEFT JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = pro.center
                AND pgl.product_id = pro.id
                AND pgl.product_group_id = 225                  
        WHERE 
                p.status not in (4,5,7,8)
                AND 
                p.CENTER IN (:Scope)
                AND
                pgl.product_group_id IS NULL        
        )t1               