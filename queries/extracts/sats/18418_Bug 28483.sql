SELECT
    b.name,
    b.type,
    b.id,
    b.parent

FROM

    (
        SELECT
            a.ID     AS id,
            a.parent AS parent,
            a.name   AS name,
            'REGION' as type
        FROM
            AREAS a
        UNION
        SELECT
            ac.CENTER          AS id,
            ac.AREA            AS parent,
            TO_CHAR(ac.CENTER) AS name,
            'CENTER'            as type
        FROM
            AREA_CENTERS ac
    )
    b START
WITH b.id = 64 CONNECT BY prior b.id = b.parent