WITH 
        params AS
          (
              SELECT
                  /*+ materialize */
                  CAST((datetolongC(TO_CHAR((CAST(getcentertime(c.id) AS DATE) - INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT)  AS cutDate,
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
        pea.last_edit_time > params.cutdate
        AND
        pe.external_id IS NOT NULL
		AND
        pea.mimevalue IS NOT NULL