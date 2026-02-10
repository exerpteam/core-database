-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-7674
SELECT
    p.center ||'p'|| p.id AS "PERSONID",
    p.firstname,
    p.lastname,
    e.center ||'emp'|| e.id AS "EMPLOYEEID",
    p.external_id           AS "STAFF_EXTERNAL_ID",
CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
    r.rolename,
    e.last_login,
    t.name       AS "SUBSCRIPTION_NAME",
    t.start_date AS "SUBSCRIPTION_START_DATE"
FROM
    persons p
JOIN
    employees e
ON
    e.personcenter = p.center
AND e.personid = p.id
AND e.blocked = false
JOIN
    employeesroles er
ON
    er.center = e.center
AND er.id = e.id
JOIN
    roles r
ON
    r.id = er.roleid
LEFT JOIN
    (
        SELECT
            s.owner_center,
            s.owner_id,
            s.start_date,
            pr.name
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        WHERE
        s.state IN (2,4) )t
ON
    t.owner_center = p.center
AND t.owner_id = p.id
WHERE
    p.persontype = 2
AND p.CENTER >= :fromCenter
AND p.center <= :toCenter