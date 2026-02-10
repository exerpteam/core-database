-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-4469
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
  
Select 
         p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Full Name"
        ,peeaMobile.txtvalue AS "Mobile"
        ,peeaEmail.txtvalue AS "Email"
        ,CASE
                WHEN p.status = 0 THEN 'Lead'
                WHEN p.status = 1 THEN 'Sale'                               
                WHEN p.status = 6 THEN 'Prospect'
                WHEN p.status = 9 THEN 'Contact'
         ELSE ''
         END AS "Member Status"
         ,t2.status
        
FROM Persons p

JOIN    
        params 
        ON params.CENTER_ID = p.center
JOIN 
        person_ext_attrs peeaEmail
        ON peeaEmail.personcenter = p.center
        AND peeaEmail.personid = p.id
        AND peeaEmail.name = '_eClub_Email'
JOIN 
        person_ext_attrs peeaMobile
        ON peeaMobile.personcenter = p.center
        AND peeaMobile.personid = p.id
        AND peeaMobile.name = '_eClub_PhoneSMS'

LEFT JOIN
        (SELECT 
                max(t.id) AS ID
                ,t.person_center
                ,t.person_id
        FROM 
                tasks t
        WHERE 
                t.center in (:scope)
        GROUP BY
                t.person_center
                ,t.person_id
        )t
                ON t.person_center = p.center
                AND t.person_id = p.id 
JOIN
        tasks t2
        ON t2.person_center = t.person_center 
        AND t2.person_id = t.person_id
        AND t2.id = t.ID

WHERE

        t2.status in (:workflowtype)
        and p.center in (:scope)
		and t2.creation_time BETWEEN params.FromDate AND params.ToDate
		and t2.type_id = 400