SELECT
    t1.center ||'p'|| t1.id AS "Person ID",
    t1.external_id AS "External ID",
    t1.age AS "Age",
    ccc.amount AS "Open Debt",
    ccc.startdate AS "Start Date"
FROM
    (   SELECT
            p.center,
            p.id,
            p.external_id,
            EXTRACT(YEAR FROM AGE(p.birthdate)) AS age
        FROM
            persons p ) t1
JOIN
    purefitnessus.cashcollectioncases ccc
ON
    ccc.personcenter = t1.center
AND ccc.personid = t1.id
WHERE
    t1.age < 18
AND ccc.missingpayment = true
AND ccc.closed = false
AND t1.center IN (:scope)