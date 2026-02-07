-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') AS cutDate,
            c.id                                                           AS centerid
        FROM
            centers c
    )
SELECT
    p.fullname AS "Full Name",
    p.center ||'p'|| p.id AS "Member ID",
    p.birthdate AS "Birth Date",
	prod.name AS "Subscription Name",
	s.binding_end_date AS "Contract End Date"
FROM
    subscriptions s
JOIN
    params par
ON
    par.centerid = s.center
JOIN
    persons p
	ON p.center = s.owner_center
	AND p.id = s.owner_id
JOIN PRODUCTS prod 
	ON prod.center = s.subscriptiontype_center
	and prod.id = s.subscriptiontype_id
WHERE
prod.name IN (
    'Life U23''s 12 Month - Website',
    'Life U23''s 12 Month'
)
AND EXTRACT(YEAR FROM age(par.cutDate, p.birthdate)) > 23
AND s.binding_end_date is null 
AND p.center IN (:center)