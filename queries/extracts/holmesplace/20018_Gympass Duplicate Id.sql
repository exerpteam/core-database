
SELECT
    c.SHORTNAME AS CENTER_SHORT_NAME,
    p.CURRENT_PERSON_CENTER AS CENTER_ID,
    p.CENTER || 'p' ||p.ID AS PERSON_ID,
    p.FULLNAME AS PERSON_NAME,
    pe.TXTVALUE AS GYMPASS_ID,
    longtodateTZ(pe.LAST_EDIT_TIME, 'CET') AS GP_ID_LAST_UPDATE,
    CASE p.status
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
        ELSE 'UNKNOWN'
    END AS "STATUS"
FROM
    PERSONS p
INNER JOIN
    PERSON_EXT_ATTRS pe
ON
    p.center = pe.personcenter
AND p.ID = pe.PERSONID
JOIN
        CENTERS c
ON
        p.center = c.ID
WHERE
    pe.TXTVALUE IN
    (
        SELECT
            pe.TXTVALUE
        FROM
            PERSON_EXT_ATTRS pe
        WHERE
            pe.NAME = 'GYMPASSID'
        AND pe.TXTVALUE IS NOT NULL
        GROUP BY
            pe.TXTVALUE
        HAVING
            COUNT(*)>1 )