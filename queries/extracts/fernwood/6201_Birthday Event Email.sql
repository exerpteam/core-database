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
SELECT 
        c.shortname AS "Club"
        ,p.center ||'p'|| p.id AS "Person ID"
        ,p.external_id AS "External ID"
        ,p.birthdate AS "Birthday"
        ,p.fullname AS "Full Name"
        ,pea.txtvalue AS "Email"
        ,CAST(longtodatec(m.senttime,m.center) as date) AS "Delivery date"
        ,TO_CHAR(longtodateC(m.senttime,m.center),'hh24:mi') AS "Delivery time"
        ,m.subject AS "Subject"
FROM 
        messages m
JOIN 
        persons p 
        ON p.center = m.center
        AND p.id = m.id
JOIN
        centers c
        ON c.id = p.center
LEFT JOIN
        person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id 
        AND pea.name = '_eClub_Email' 
JOIN 
        params 
        ON params.CENTER_ID = p.center                               
WHERE 
        m.templatetype = 109
        AND 
        m.senttime BETWEEN params.FromDate AND params.ToDate