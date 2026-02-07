WITH
    params AS materialized
    (
        SELECT
            datetolongC((CURRENT_DATE - interval '15' DAY)::VARCHAR, c.id)::bigint AS fifteen_days,
           (current_date - interval '1' day)                    AS yesterday,
            c.id                                                                   AS param_center

        FROM
            centers c
            where c.id in (:scope)
    )
SELECT
    p.center||'p'||p.id AS "Member id",
    p.external_id       AS "Member external id",
    p.firstname         AS "Member first name",
    p.lastname          AS "Member last name",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARY INACTIVE'
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
    END           AS "Status",

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
    END        AS "Person type",
        ccc.startdate AS "Debt case start date",
    ccc.amount AS "Debt case amount",
    CASE
        WHEN MAX(ch.checkin_time) IS NOT NULL
        THEN 'Com utilização'
        ELSE 'Sem utilização nos últimos 15 dias'
    END AS "Category"
FROM
    cashcollectioncases ccc
JOIN
    persons p
ON
    ccc.personcenter=p.center
AND ccc.personid=p.id
JOIN
    params
ON
    p.center=params.param_center
LEFT JOIN
    checkins ch
ON
    p.center=ch.person_center
AND p.id=ch.person_id
AND ch.checkin_time >= params.fifteen_days
AND ch.checkin_result=1
WHERE
    ccc.closed=false
AND ccc.missingpayment=true
AND p.status NOT IN ( 2,
                     4,
                     5,
                     7,
                     8)

AND p.sex!='C'
AND p.center != 700
AND p.status != 2
AND ccc.startdate =  params.yesterday
GROUP BY
    p.center,
    p.id ,
    p.external_id,
    p.firstname,
    p.lastname,
    p.PERSONTYPE,
    p.status,
    ccc.startdate,
    ccc.amount
