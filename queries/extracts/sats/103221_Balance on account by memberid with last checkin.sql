-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS memberid,
    p.firstname,
    p.lastname,
    p.status,
    ar.balance,
    longtodatec(ch.last_checkin_date, c.id)
FROM
    account_receivables ar
JOIN
    persons p
    ON ar.customercenter = p.center
   AND ar.customerid = p.id
join centers c
on 
p.center = c.id   
LEFT JOIN (
    SELECT
        person_center,
        person_id,
        MAX(checkin_time) AS last_checkin_date
    FROM
        checkins
    WHERE
        checkin_result < 3
    GROUP BY
        person_center,
        person_id
) ch
    ON ch.person_center = p.center
   AND ch.person_id = p.id
WHERE
  ar.center IN (:scope)
AND ar.AR_TYPE = :Kontotype
 and
 (p.center,p.id) in (:memberid)