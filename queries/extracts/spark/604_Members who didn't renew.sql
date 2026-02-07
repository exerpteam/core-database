WITH
    params AS MATERIALIZED
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS currentDate,
            c.id             AS center_Id
        FROM
            centers c
    )
SELECT
    p.center ||'p'|| p.id AS "Member ID",
    p.external_id         AS "Member external ID",
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END AS "Persontype",
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
    END AS "Person status",
    p.fullname AS "Member name",
    email.txtvalue AS "Email",
    mob.txtvalue   AS "Mobile phone"
FROM
    persons p
JOIN
params par
ON
par.center_id = p.center
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs mob
ON
    mob.personcenter = p.center
AND mob.personid = p.id
AND mob.name = '_eClub_PhoneSMS'
WHERE
    p.persontype != 2
AND p.status NOT IN (1,3)
AND p.center IN (:scope)
AND EXISTS
(SELECT
1
FROM
subscriptions s
WHERE
s.owner_center = p.center
AND s.owner_id = p.id
AND s.end_date BETWEEN :cutDate AND par.currentDate)