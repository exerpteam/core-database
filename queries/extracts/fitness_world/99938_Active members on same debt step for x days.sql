-- This is the version from 2026-02-05
-- Will return all members with an active subscription and an open debt case, where current debt step has been the same for x days
WITH params AS (
SELECT
TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') -:days AS to_date,
c.id AS centerid
FROM
centers c
)
SELECT DISTINCT
    p.center ||'p'|| p.id AS member_id,
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
    END AS PERSON_STATUS,
    ccc.startdate AS debtcase_startdate,
    CASE ccc.CURRENTSTEP_TYPE
        WHEN 0
        THEN 'MESSAGE'
        WHEN 1
        THEN 'REMINDER'
        WHEN 2
        THEN 'BLOCK'
        WHEN 3
        THEN 'REQUESTANDSTOP'
        WHEN 4
        THEN 'CASHCOLLECTION'
        WHEN 5
        THEN 'CLOSE'
        WHEN 6
        THEN 'WAIT'
        WHEN 7
        THEN 'REQUESTBUYOUTANDSTOP'
        WHEN 8
        THEN 'PUSH'
        ELSE 'Undefined'
    END AS CURRENTSTEP,
    ccc.amount,
    CASE 
        WHEN ccc.nextstep_type = 0
        THEN 'MESSAGE'
        WHEN ccc.nextstep_type = 1
        THEN 'REMINDER'
        WHEN ccc.nextstep_type = 2
        THEN 'BLOCK'
        WHEN ccc.nextstep_type = 3
        THEN 'REQUESTANDSTOP'
        WHEN ccc.nextstep_type = 4
        THEN 'CASHCOLLECTION'
        WHEN ccc.nextstep_type = 5
        THEN 'CLOSE'
        WHEN ccc.nextstep_type = 6
        THEN 'WAIT'
        WHEN ccc.nextstep_type = 7
        THEN 'REQUESTBUYOUTANDSTOP'
        WHEN ccc.nextstep_type = 8
        THEN 'PUSH'
        WHEN ccc.nextstep_type IS NULL
        THEN 'NO NEXT STEP'
        ELSE 'Undefined'
    END AS NEXT_STEP
FROM
    cashcollectioncases ccc
JOIN
    persons p
ON
    p.center = ccc.personcenter
AND p.id = ccc.personid
JOIN
    subscriptions s
    ON
    s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.state IN (2,4)
JOIN
params
ON
params.centerid = ccc.center
WHERE
    ccc.missingpayment = true
AND ccc.closed = false
AND ccc.currentstep_date < params.to_date
AND ccc.amount > :amount
--AND p.center IN (:scope)