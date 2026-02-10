-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
            spk.id,
            spk.client,
            spk.txtvalue,c.*
        FROM
            systemproperties spk
join clients c on spk.client = c.id
        WHERE
            spk.globalid = 'CLIENT_CASHREGISTER'
        AND txtvalue = '1'