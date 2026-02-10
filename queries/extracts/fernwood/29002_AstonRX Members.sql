-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
        SELECT
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
)
SELECT 
        p.center||'p'||p.id AS PersonID
        ,p.fullname AS PersonName
        ,p.external_id AS ExternalD
        ,CASE p.status 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS PersonStatus
        ,CAST(longtodateC(astonrx.last_edit_time,astonrx.personcenter) as date) AS ActivationDate
FROM
        persons p
JOIN
        person_ext_attrs astonrx
        ON astonrx.personcenter = p.center
        AND astonrx.personid = p.id
        AND astonrx.name = 'astonrx'
JOIN
        params
        ON params.center_id = p.center        
WHERE 
        astonrx.txtvalue IN (:AstonRX)
        AND
        p.center IN (:Scope)
        AND 
        astonrx.last_edit_time BETWEEN params.FromDate AND params.ToDate
        
      