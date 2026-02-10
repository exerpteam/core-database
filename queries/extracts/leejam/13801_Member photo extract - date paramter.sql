-- The extract is extracted from Exerp on 2026-02-08
--  
WITH 
        params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:Date AS DATE), 'YYYY-MM-dd HH24:MI'),c.id)  AS cutDate,
                  c.id AS CENTER_ID
              FROM
                  centers c
          )
SELECT 
        pe.external_id
        ,longtodatec(pea.last_edit_time,pe.center) AS Update_date
FROM 
        leejam.persons pe
JOIN 
        leejam.person_ext_attrs  pea 
        ON pea.personcenter = pe.center 
        AND pea.personid = pe.id 
        AND pea.name = '_eClub_Picture'
JOIN
        params
        ON params.center_id = pea.personcenter        
WHERE
        pea.last_edit_time > params.cutDate 
        AND
        pe.external_id IS NOT NULL
		AND
        pea.mimevalue IS NOT NULL