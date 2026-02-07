SELECT
p.external_id AS cardId,
p.center ||'p'|| p.id AS memberId,
p.fullname,
TO_CHAR(longtodateC(att.start_time, p.center), 'YYYY-MM-DD') AS attendDate,
TO_CHAR(longtodateC(att.start_time, p.center), 'HH24:MI:SS') AS attendTime,
br.name AS resource
FROM
attends att
JOIN
persons p
ON
p.center = att.person_center
AND p.id = att.person_id
JOIN
booking_resources br
ON
br.center = att.booking_resource_center
AND br.id = att.booking_resource_id
WHERE
att.center IN (:center)
ORDER BY
att.start_time DESC