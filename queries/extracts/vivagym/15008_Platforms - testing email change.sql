WITH
            params AS
            (
             SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS from_date,
                    datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'),  'YYYY-MM-DD'), c.ID)+ (86400 * 1000)-1 AS to_date,
                    c.ID                      AS CenterID
               FROM
                    CENTERS c
       -- WHERE
      --  c.country = 'PT'
            )

SELECT
        p.center || 'p' || p.id AS PersonId,
        p.external_id,
        longtodateC(pcl.entry_time, pcl.person_center) AS change_time,
        pcl.new_value AS new_value --,
        --pcl.*
     --   pea.txtvalue AS current_value
FROM vivagym.persons p
JOIN vivagym.centers c ON c.id = p.center --AND c.country = 'PT'     
JOIN vivagym.person_change_logs pcl ON pcl.person_center = p.center AND pcl.person_id = p.id
--LEFT JOIN vivagym.person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = --p.id AND pea.name = 'E_MAIL'
JOIN
    params
 ON
    params.CenterID = pcl.person_center
WHERE pcl.change_attribute = 'E_MAIL'
AND 
p.center IN (:center)
AND pcl.entry_time >= params.from_date 
    AND pcl.entry_time <= params.to_date
ORDER BY 1,3