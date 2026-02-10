-- The extract is extracted from Exerp on 2026-02-08
-- To be used for testing Extract changes before applying them to the real extract.
SELECT
        center_id, txt_value
FROM
        CENTER_EXT_ATTRS

WHERE
 txt_value like '%20:00%'

LIMIT 1000