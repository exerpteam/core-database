-- The extract is extracted from Exerp on 2026-02-08
-- This extract returns the list of active person relations for a given center.
/*The following relations are excluded from the Extract:
'Contact person'
'Created by'
'Account manager'
'Duplicate'*/


-- People that represent the first part of a relation
SELECT *
FROM
(SELECT
    p.external_id                                                             AS "EXTERNAL_ID",
    rel.rtype                                                                 AS "RELATION_TYPE",
    (
        CASE
            WHEN rel.rtype = 1
            THEN 'My friend'
            WHEN rel.rtype = 2
            THEN 'My company'
            WHEN rel.rtype = 3
            THEN 'My company agreement'
            WHEN rel.rtype = 4
            THEN 'My family'
            WHEN rel.rtype = 5
            THEN 'My friends (member)'
            WHEN rel.rtype = 6
            THEN 'Main company'
            WHEN rel.rtype = 9
            THEN 'My counsellor'
            WHEN rel.rtype = 12
            THEN 'Paid for by me'
            WHEN rel.rtype = 13
            THEN 'Referred by me'
            WHEN rel.rtype = 14
            THEN 'My child'
            WHEN rel.rtype = 15
            THEN 'My secondary member'
            WHEN rel.rtype = 16
            THEN 'My family employed at company'
            WHEN rel.rtype = 17
            THEN 'Company my family is employed in'
            ELSE 'Unknown relation'
        END)                                                                  AS "RELATION_TYPE_NAME",
    rperson.external_id                                                       AS "RELATIVE_EXTERNAL_ID",
    rel.status                                                                AS "RELATION_STATUS",
   (
        CASE
            WHEN rel.status = 0
            THEN 'Lead'
            WHEN rel.status = 1
            THEN 'Active'
            WHEN rel.status = 2
            THEN 'Inactive'
            WHEN rel.status = 3
            THEN 'Blocked'
        END)                                                                  AS "RELATION_STATUS_NAME",
    TO_CHAR(longtodatec(scl.book_start_time, p.center),'YYYY-MM-DD HH24:MI')  AS "RELATION_FROM_DATE",
    TO_CHAR(longtodatec(scl.book_end_time, p.center),'YYYY-MM-DD HH24:MI')    AS "RELATION_TO_DATE",
    rel.expiredate                                                            AS "RELATION_EXPIRY_DATE" 
FROM
    persons p
JOIN
    relatives rel
ON
    rel.center = p.center
AND rel.id = p.id
LEFT JOIN
    state_change_log scl
ON
    scl.center = rel.center
AND scl.id = rel.id
AND scl.subid = rel.subid
AND scl.entry_type = 4
JOIN
    persons rperson
ON
    rperson.center = rel.relativecenter
AND rperson.id = rel.relativeid
WHERE
    rel.status = 1
AND scl.stateid = 1   
AND rel.rtype NOT IN (7,8,10,11)
AND scl.book_end_time IS NULL
AND p.sex != 'C'
AND p.center IN ($$scope$$)
UNION
-- People that represent the second part of a relation
SELECT
    p.external_id                                                             AS "EXTERNAL_ID",
    rel.rtype                                                                 AS "RELATION_TYPE",
    (
        CASE
            WHEN rel.rtype = 1
            THEN 'Friends of me'
            WHEN rel.rtype = 2
            THEN 'My company'
            WHEN rel.rtype = 3
            THEN 'My company agreement'
            WHEN rel.rtype = 4
            THEN 'Family to me'
            WHEN rel.rtype = 5
            THEN 'My friends (member)'
            WHEN rel.rtype = 6
            THEN 'Main company'
            WHEN rel.rtype = 9
            THEN 'Councelled by me'
            WHEN rel.rtype = 12
            THEN 'My payer'
            WHEN rel.rtype = 13
            THEN 'My referrer'
            WHEN rel.rtype = 14
            THEN 'My parent'
            WHEN rel.rtype = 15
            THEN 'My primary member'
            WHEN rel.rtype = 16
            THEN 'My family linked at company'
            WHEN rel.rtype = 17
            THEN 'Company my family is employed in'
            ELSE 'Unknown relation'
        END)                                                                  AS "RELATION_TYPE_NAME",
    rperson.external_id                                                       AS "RELATIVE_EXTERNAL_ID",
    rel.status                                                                AS "RELATION_STATUS",
   (
        CASE
            WHEN rel.status = 0
            THEN 'Lead'
            WHEN rel.status = 1
            THEN 'Active'
            WHEN rel.status = 2
            THEN 'Inactive'
            WHEN rel.status = 3
            THEN 'Blocked'
        END)                                                                  AS "RELATION_STATUS_NAME",
    TO_CHAR(longtodatec(scl.book_start_time, p.center),'YYYY-MM-DD HH24:MI')  AS "RELATION_FROM_DATE",
    TO_CHAR(longtodatec(scl.book_end_time, p.center),'YYYY-MM-DD HH24:MI')    AS "RELATION_TO_DATE",
    rel.expiredate                                                            AS "RELATION_EXPIRY_DATE"                               
FROM
    persons p
JOIN
    relatives rel
ON
    rel.relativecenter = p.center
AND rel.relativeid = p.id
LEFT JOIN
    state_change_log scl
ON
    scl.center = rel.center
AND scl.id = rel.id
AND scl.subid = rel.subid
AND scl.entry_type = 4
JOIN
    persons rperson
ON
    rperson.center = rel.center
AND rperson.id = rel.id
WHERE
    rel.status = 1
AND scl.stateid = 1    
AND rel.rtype NOT IN (7,8,10,11)
AND scl.book_end_time IS NULL
AND p.sex != 'C'
AND p.center IN ($$scope$$)) a
ORDER BY "EXTERNAL_ID"