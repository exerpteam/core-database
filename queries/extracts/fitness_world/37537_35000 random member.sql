-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2210
WITH
    v_person AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    men_15_30.center,
                    men_15_30.id,
                    firstname,
                    lastname,
                    'Male'                                         AS sex,
                    floor(months_between(exerpsysdate(), birthdate) / 12)    age
                FROM
                    persons men_15_30
                JOIN
                    area_centers ac
                ON
                    ac.center = men_15_30.center
                JOIN
                    areas a
                ON
                    a.id = ac.area
                    AND (
                        a.id IN (4,5,6)
                        OR a.parent IN (4,5,6))
                WHERE
                    men_15_30.sex = 'M'
                    AND floor(months_between(exerpsysdate(), men_15_30.birthdate) / 12) >=15
                    AND floor(months_between(exerpsysdate(), men_15_30.birthdate) / 12) <= 30
                    AND rownum <=8797
                ORDER BY
                    DBMS_RANDOM.RANDOM )
        UNION ALL
        SELECT
            *
        FROM
            (
                SELECT
                    women_15_30.center,
                    women_15_30.id,
                    firstname,
                    lastname,
                    'Female'                                       AS sex,
                    floor(months_between(exerpsysdate(), birthdate) / 12)    age
                FROM
                    persons women_15_30
                JOIN
                    area_centers ac
                ON
                    ac.center = women_15_30.center
                JOIN
                    areas a
                ON
                    a.id = ac.area
                    AND (
                        a.id IN (4,5,6)
                        OR a.parent IN (4,5,6))
                WHERE
                    women_15_30.sex = 'F'
                    AND floor(months_between(exerpsysdate(), women_15_30.birthdate) / 12) >=15
                    AND floor(months_between(exerpsysdate(), women_15_30.birthdate) / 12) <= 30
                    AND rownum <=9083
                ORDER BY
                    DBMS_RANDOM.RANDOM )
        UNION ALL
        SELECT
            *
        FROM
            (
                SELECT
                    men_not_15_30.center,
                    men_not_15_30.id,
                    firstname,
                    lastname,
                    'Male'                                         AS sex,
                    floor(months_between(exerpsysdate(), birthdate) / 12)    age
                FROM
                    persons men_not_15_30
                JOIN
                    area_centers ac
                ON
                    ac.center = men_not_15_30.center
                JOIN
                    areas a
                ON
                    a.id = ac.area
                    AND (
                        a.id IN (4,5,6)
                        OR a.parent IN (4,5,6))
                WHERE
                    men_not_15_30.sex = 'M'
                    AND (
                        floor(months_between(exerpsysdate(), men_not_15_30.birthdate) / 12) < 15
                        OR floor(months_between(exerpsysdate(), men_not_15_30.birthdate) / 12) > 30)
                    AND rownum <=8773
                ORDER BY
                    DBMS_RANDOM.RANDOM )
        UNION ALL
        SELECT
            *
        FROM
            (
                SELECT
                    women_not_15_30.center,
                    women_not_15_30.id,
                    firstname,
                    lastname,
                    'Female'                                       AS sex,
                    floor(months_between(exerpsysdate(), birthdate) / 12)    age
                FROM
                    persons women_not_15_30
                JOIN
                    area_centers ac
                ON
                    ac.center = women_not_15_30.center
                JOIN
                    areas a
                ON
                    a.id = ac.area
                    AND (
                        a.id IN (4,5,6)
                        OR a.parent IN (4,5,6))
                WHERE
                    women_not_15_30.sex = 'F'
                    AND (
                        floor(months_between(exerpsysdate(), women_not_15_30.birthdate) / 12) < 15
                        OR floor(months_between(exerpsysdate(), women_not_15_30.birthdate) / 12) > 30 )
                    AND rownum <=8347
                ORDER BY
                    DBMS_RANDOM.RANDOM )
    )
SELECT
    per.center || 'p' || per.id AS "MemberId",
    per.firstname,
    per.lastname,
    per.sex,
    per.age,
    email.txtvalue AS Email,
    CASE
        WHEN a.id IN (4,5,6)
        THEN a.name
        ELSE DECODE (a.parent, 4, 'Sjælland', 5, 'Jylland', 6, 'Fyn')
    END AS Region
FROM
    v_person per
JOIN
    area_centers ac
ON
    ac.center = per.center
JOIN
    areas a
ON
    a.id = ac.area
    AND (
        a.id IN (4,5,6)
        OR a.parent IN (4,5,6))
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    per.center=email.PERSONCENTER
    AND per.id=email.PERSONID
    AND email.name='_eClub_Email'