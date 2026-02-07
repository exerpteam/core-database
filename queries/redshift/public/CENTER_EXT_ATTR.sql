SELECT
    cea.ID             AS "ID",
    CENTER_ID          AS "CENTER_ID",
    NAME               AS "NAME",
    LEFT(CASE
        WHEN cea.mime_type = 'text/plain'
        THEN encode(cea.mime_value,'escape')
        ELSE cea.TXT_VALUE
    END, 2048)        AS "VALUE",
    cea.LAST_EDIT_TIME AS "ETS"
FROM
    CENTER_EXT_ATTRS cea
