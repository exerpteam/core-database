-- The extract is extracted from Exerp on 2026-02-08
--  
/*
CRM Task Trends Report - STEP 1: BASIC VERSION
Purpose: Start simple - just get lead details and their current CRM task status
*/

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
  ),
  -- Get latest CRM task for each person
  latest_task AS
  (
      SELECT 
          MAX(t.id) AS task_id,
          t.person_center,
          t.person_id
      FROM 
          tasks t
      WHERE 
          t.center IN (:scope)
          AND t.type_id = 400
      GROUP BY
          t.person_center,
          t.person_id
  )
  
-- Main query - just basics
SELECT 
    p.center || 'p' || p.id AS "Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    peeaEmail.txtvalue AS "Email",
    peeaMobile.txtvalue AS "Phone",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Other'
    END AS "Person Status",
    t2.status AS "Current CRM Status",
    c.shortname AS "Club Name"
    
FROM 
    Persons p
    
JOIN    
    params 
    ON params.CENTER_ID = p.center
    
JOIN 
    centers c
    ON c.id = p.center
    
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
    latest_task lt
    ON lt.person_center = p.center
    AND lt.person_id = p.id
    
LEFT JOIN
    tasks t2
    ON t2.person_center = lt.person_center 
    AND t2.person_id = lt.person_id
    AND t2.id = lt.task_id

WHERE
    p.center IN (:scope)
    AND p.status IN (0, 6, 9)
    AND t2.status IS NOT NULL
    AND t2.creation_time BETWEEN params.FromDate AND params.ToDate
    
ORDER BY
    p.center,
    p.id