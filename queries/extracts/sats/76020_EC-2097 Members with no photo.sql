SELECT DISTINCT
    member,
    member_center,
    CASE
        WHEN member_status = 1
        THEN 'ACTIVE'
        WHEN member_status = 2
        THEN 'INACTIVE'
        WHEN member_status = 3
        THEN 'TEMPORARYINACTIVE'
    END AS MEMBERSTATUS
FROM
    (
        SELECT DISTINCT
            a.center || 'p' || a.id AS member,
            a.center                AS member_center,
            a.STATUS                AS member_status
        FROM
            persons a
        LEFT JOIN
            person_ext_attrs b
        ON
            a.center = b.personcenter
        AND a.id = b.personid
        WHERE
            a.center IN (:Scope)
        AND a.status IN (1,2,3) ) t1
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea2
        WHERE
            pea2.personcenter || 'p' || pea2.personid = t1.member
        AND (
                pea2.name = '_eClub_Picture'
            OR  pea2.name = '_eClub_PictureFace'))
ORDER BY
    member_center,
    MEMBERSTATUS