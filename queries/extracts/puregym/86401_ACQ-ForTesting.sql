SELECT
        center_id, txt_value
FROM
        CENTER_EXT_ATTRS

WHERE
 txt_value like '%20:00%'

LIMIT 1000