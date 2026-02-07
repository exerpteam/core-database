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