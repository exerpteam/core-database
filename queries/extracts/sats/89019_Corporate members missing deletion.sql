SELECT
t1.*
FROM
(SELECT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END                  AS PERSON_STATUS,
    'Balance on account' AS Reason,
    ar.balance           AS Balance
FROM
    persons p
JOIN
    sats.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
    p.persontype = 4
AND p.status = 2
AND p.last_active_end_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
AND ar.balance != 0
AND p.sex != 'C'
UNION ALL
SELECT
    p.center ||'p'|| p.id,
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
    END AS PERSONTYPE,
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
    END                  AS PERSON_STATUS,
    'Balance on account' AS Reason,
    ar.balance           AS Balance
FROM
    persons p
JOIN
    person_change_logs creation
ON
    creation.person_center = p.center
AND creation.person_id = p.id
AND creation.change_attribute = 'CREATION_DATE'
JOIN
    sats.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
    p.persontype = 4
AND p.status IN (0,6,9)
AND TO_DATE(creation.new_value, 'YYYY-MM-DD') < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')-
    interval '5 month'
AND ar.balance != 0
AND p.sex != 'C'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END                AS PERSON_STATUS,
    'Active agreement' AS Reason,
    ar.balance         AS Balance
FROM
    persons p
JOIN
    person_change_logs creation
ON
    creation.person_center = p.center
AND creation.person_id = p.id
AND creation.change_attribute = 'CREATION_DATE'
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    sats.payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
JOIN
    payment_agreements pa
ON
    pa.center = pac.active_agr_center
AND pa.id = pac.active_agr_id
AND pa.subid = pac.active_agr_subid
WHERE
    p.sex != 'C'
AND p.persontype = 4
AND p.status IN (0,6,9)
AND pa.state IN (1,2,4,14,16,17)
AND TO_DATE(creation.new_value, 'YYYY-MM-DD') < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')-
    interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END                AS PERSON_STATUS,
    'Active agreement' AS Reason,
    ar.balance         AS Balance
FROM
    persons p
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    sats.payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
JOIN
    payment_agreements pa
ON
    pa.center = pac.active_agr_center
AND pa.id = pac.active_agr_id
AND pa.subid = pac.active_agr_subid
WHERE
    p.sex != 'C'
AND p.persontype = 4
AND p.status = 2
AND pa.state IN (1,2,4,14,16,17)
AND p.last_active_end_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END               AS PERSON_STATUS,
    'Active clipcard' AS Reason,
    0 AS balance
FROM
    persons p
JOIN
    person_change_logs creation
ON
    creation.person_center = p.center
AND creation.person_id = p.id
AND creation.change_attribute = 'CREATION_DATE'
JOIN
    clipcards c
ON
    c.owner_center = p.center
AND c.owner_id = p.id
AND c.finished = 'false'
WHERE
    p.sex != 'C'
AND p.persontype = 4
AND p.status IN (0,6,9)
AND TO_DATE(creation.new_value, 'YYYY-MM-DD') < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')-
    interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END               AS PERSON_STATUS,
    'Active clipcard' AS Reason,
    0 AS balance
FROM
    persons p
JOIN
    clipcards c
ON
    c.owner_center = p.center
AND c.owner_id = p.id
AND c.finished = 'false'
WHERE
    p.sex != 'C'
AND p.persontype = 4
AND p.status = 2
AND p.last_active_end_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END              AS PERSON_STATUS,
    'Open debt case' AS Reason,
    cc.amount        AS Balance
FROM
    persons p1
JOIN
    persons p
ON
    p.center = p1.transfers_current_prs_center
AND p.id = p1.transfers_current_prs_id
AND p.sex != 'C'
AND p.persontype = 4
AND p.status IN (0,6,9)
JOIN
person_change_logs creation
ON
creation.person_center = p.center
AND creation.person_id = p.id
AND creation.change_attribute = 'CREATION_DATE' 
JOIN
    sats.cashcollectioncases cc
ON
    cc.personcenter = p1.center
AND cc.personid = p1.id
AND cc.closed = 'false'
WHERE
    TO_DATE(creation.new_value, 'YYYY-MM-DD')  < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END              AS PERSON_STATUS,
    'Open debt case' AS Reason,
    cc.amount        AS Balance
FROM
    persons p1
JOIN
    persons p
ON
    p.center = p1.transfers_current_prs_center
AND p.id = p1.transfers_current_prs_id
AND p.sex != 'C'
AND p.persontype = 4
AND p.status = 2
JOIN
    sats.cashcollectioncases cc
ON
    cc.personcenter = p1.center
AND cc.personid = p1.id
AND cc.closed = 'false'
WHERE
    p.last_active_end_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
UNION ALL
SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
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
    END AS PERSONTYPE,
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
    END                       AS PERSON_STATUS,
    'Not billed subscription' AS Reason,
    0                         AS Balance
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state NOT IN (2,4)
AND s.sub_state != 8
JOIN
    sats.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
AND st.st_type = 1
WHERE
    p.last_active_end_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')- interval '5 month'
AND p.sex != 'C'
AND p.persontype = 4
AND p.status = 2
AND s.billed_until_date < s.end_date
AND s.subscription_price > 0    ) t1
ORDER BY
t1.memberid,
t1.reason,
t1.person_status