-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9005
WITH
    compare_this AS
    (
        SELECT
            p.center||'p'||p.id AS pnumber,
            p.external_id,
            LOWER(trim(p.fullname))   AS pname,
            LOWER(trim(pem.txtvalue)) AS pmail,
            p.birthdate
        FROM
            persons p
        LEFT JOIN
            person_ext_attrs pem
        ON
            p.center = pem.personcenter
        AND p.id = pem.personid
        AND pem.name = '_eClub_Email'
        WHERE
            p.status NOT IN (4,5,7,
                             8) --Transferred, Deleted
    )
    ,
    duplicates AS
    (
        SELECT
            pname,
            pmail,
            birthdate,
            COUNT(*)
        FROM
            compare_this
        GROUP BY
            pname,
            pmail,
            birthdate
        HAVING
            COUNT(pname) > 1
    )
SELECT
    p.center||'p'||p.id AS pnumber,
    p.fullname,
    p.birthdate,
    m.txtvalue AS e_mail, 
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS PERSON_STATUS
FROM
    duplicates d
JOIN
    persons p
ON
    d.pname = LOWER(trim(p.fullname))
AND d.birthdate = p.birthdate
AND p.status NOT IN (4,5,7,
                     8)                   
LEFT JOIN
    person_ext_attrs m
ON
    p.center = m.personcenter
AND p.id = m.personid
AND m.name = '_eClub_Email'
AND m.txtvalue = d.pmail
WHERE m.txtvalue = d.pmail or d.pmail is null