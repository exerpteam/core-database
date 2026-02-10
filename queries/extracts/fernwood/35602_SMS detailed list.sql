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
        c.name AS "Club Name"
        ,ss.*
FROM
        messages m
JOIN
        sms s
        ON s.message_center = m.center
        AND s.message_id = m.id
        AND s.message_sub_id = m.subid  
JOIN
        sms_splits ss
        ON ss.sms_center = s.center
        AND ss.sms_id = s.id
JOIN    
        params
        ON params.CENTER_ID = m.center
JOIN
        centers c
        ON c.id = m.center              
WHERE
        m.senttime BETWEEN params.FromDate AND params.ToDate
        AND
        m.center in (:Scope)