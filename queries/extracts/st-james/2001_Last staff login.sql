SELECT
    p.center||'p'||p.id member_id,
    CASE p.status
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
  --  p.last_modified,
    e.CENTER||'emp'||e.id AS employee_id,
    p.fullname as user_name,
    e.blocked,
    e.last_login last_client_login,
    longtodateTZ(lt.last_used, 'America/Toronto') login_token_last_used
FROM
    persons p  
JOIN
    EMPLOYEES e
ON
    p.center = e.personcenter
AND p.id =e.personid
left join     EMPLOYEE_LOGIN_TOKENS lt on e.center = lt.employee_center and e.id = lt.employee_id
where p.status not in (7,8)