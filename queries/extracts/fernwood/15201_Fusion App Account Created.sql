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
        longtodatec(pea.last_edit_time,pea.PERSONCENTER) AS CreationDate
        ,PERSONCENTER||'p'||PERSONID AS PersonID
        ,pea.txtvalue
FROM 
        PERSON_EXT_ATTRS pea
JOIN 
        params 
                ON params.CENTER_ID = pea.PERSONCENTER
WHERE 
        pea.name = '_eClub_HasLoggedInMemberMobileApp' 
        AND
        pea.last_edit_time BETWEEN params.FromDate AND params.ToDate