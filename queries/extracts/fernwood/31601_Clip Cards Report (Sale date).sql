-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1."PersonID"
        ,t1."ExternalID"
        ,t1."Club Name"
        ,t1."First Name"
        ,t1."Last Name"
        ,t1."Person type" 
        ,t1."Email"
        ,t1."Mobile"
        ,t1."Home"
        ,t1."Clip Card Name"
        ,t1."Start Date"
        ,t1."End Date"
        ,t1."Sale Date"
        ,t1."Original Clips"
        ,t1."Remaining Clips"
        ,t1."Amount Paid"
        ,t1."State"
        ,t1."Sold by"
        ,t1."Adjusted Clips"
        ,t1."Clips Adjusted by"
        ,t1."Sold at"
        ,t1."Last Visit Date"
FROM
        (                
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
        SELECT distinct
                p.center ||'p'||p.id AS "PersonID"
                ,p.external_id AS "ExternalID"
                ,c.shortname AS "Club Name"
                ,p.firstname AS "First Name"
                ,p.lastname AS "Last Name"
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
                ,longtodatec(t.entry_time,t.center) AS "Sale Date"
                ,cc.clips_initial AS "Original Clips"
                ,cc.clips_left AS "Remaining Clips"
                ,inv.total_amount AS "Amount Paid"
                ,CASE
                        WHEN cc.cancelled = 'true' AND cc.finished = 'true' THEN 'Cancelled'
                        WHEN cc.blocked = 'true' AND cc.finished = 'true' THEN 'Blocked'
                        WHEN cc.finished = 'true' AND cc.cancelled = 'false' AND cc.blocked = 'false' THEN 'Finished'
                        ELSE 'Active'
                 END AS "State"
                 ,pe.fullname AS "Sold by"
                 ,ccu.clips AS "Adjusted Clips"
                 ,pea.fullname AS "Clips Adjusted by"
                 ,cclip.shortname AS "Sold at"
                 ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                 ,cc.center||'cc'||cc.id||'cc'||cc.subid
        FROM 
                persons p
        JOIN 
                clipcards cc 
                ON cc.owner_center = p.center 
                AND cc.owner_id = p.id
        LEFT JOIN 
                card_clip_usages ccu 
                ON ccu.card_center = cc.center 
                AND ccu.card_id = cc.id 
                AND ccu.card_subid = cc.subid
                AND ccu.type = 'ADJUSTMENT'
        JOIN 
                centers c 
                ON c.id = p.center
        JOIN 
                centers cclip
                ON cc.center = cclip.id
        JOIN 
                products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID
        LEFT JOIN 
                invoice_lines_mt inv
                ON cc.invoiceline_center = inv.center
                AND cc.invoiceline_id = inv.id
                AND cc.invoiceline_subid = inv.subid  
        LEFT JOIN 
                invoices i
                ON inv.center = i.center     
                AND inv.id = i.id   
        LEFT JOIN 
                employees emp
                ON emp.CENTER = i.employee_center
                AND emp.ID = i.employee_id
        LEFT JOIN 
                persons pe
                ON pe.CENTER = emp.PERSONCENTER
                AND pe.ID = emp.PERSONID  
        LEFT JOIN 
                employees empa
                ON empa.CENTER = ccu.employee_center
                AND empa.ID = ccu.employee_id
        LEFT JOIN 
                persons pea
                ON pea.CENTER = empa.PERSONCENTER
                AND pea.ID = empa.PERSONID  
        LEFT JOIN 
                person_ext_attrs peeaEmail
                ON peeaEmail.personcenter = p.center
                AND peeaEmail.personid = p.id
                AND peeaEmail.name = '_eClub_Email'
        LEFT JOIN 
                person_ext_attrs peeaMobile
                ON peeaMobile.personcenter = p.center
                AND peeaMobile.personid = p.id
                AND peeaMobile.name = '_eClub_PhoneSMS' 
        LEFT JOIN 
                person_ext_attrs peeaHome
                ON peeaHome.personcenter = p.center
                AND peeaHome.personid = p.id
                AND peeaHome.name = '_eClub_PhoneHome'
        LEFT JOIN
                (SELECT max(checkin_time) AS LastVisitDate, person_center AS PersonCenter, person_id AS PersonID             
                FROM checkins 
                GROUP BY person_center,person_id ) la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id
        JOIN 
                params 
                ON params.CENTER_ID = c.id
        LEFT JOIN
                product_and_product_group_link pgl
                ON pgl.product_center = pro.center
                AND pgl.product_id = pro.id
                AND pgl.product_group_id = 225
        LEFT JOIN
                (SELECT DISTINCT
                        center
                        ,id
                        ,entry_time
                 FROM
                        invoices
                )t
                ON cc.invoiceline_center = t.center 
                AND cc.invoiceline_id = t.id
        WHERE 
                p.status NOT IN (4,5,7,8)
                AND 
                t.entry_time BETWEEN params.FromDate AND params.ToDate
                AND 
                p.CENTER IN (:Scope)
                AND
                pgl.product_group_id IS NULL        
        )t1                