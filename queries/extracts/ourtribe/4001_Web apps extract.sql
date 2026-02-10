-- The extract is extracted from Exerp on 2026-02-08
--  
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
je.person_center || 'p' || je.person_id AS "Personkey",
je.name AS "Journalnote",
TO_CHAR(longtodateC(je.creation_time,params.center_id), 'YYYY-MM-dd HH24:MI') AS "Time"

FROM 
journalentries je 

JOIN 
params 
ON params.center_id = je.person_center

WHERE 
je.name LIKE '%ShoppingBasketAPI.registerExternalPayment%'
AND je.creation_time BETWEEN params.FromDate AND params.ToDate