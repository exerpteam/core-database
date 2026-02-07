SELECT
    p.center ||'p'|| p.id                                                   AS "Member ID",
    p.external_id                                                           AS "External ID",
    p.fullname                                                              AS "Name",
    TO_CHAR(longtodateC(pcl.entry_time, p.center), 'YYYY-MM-DD HH24:MI:SS') AS "Creation time"
FROM
    persons p
JOIN
    person_change_logs pcl
ON
    pcl.person_center = p.center
AND pcl.person_id = p.id
AND pcl.change_attribute = 'CREATION_DATE'
WHERE
    (pcl.employee_center,pcl.employee_id) = (100,202)
AND p.status = 0
AND p.center IN (:scope)
AND pcl.entry_time BETWEEN :fromDate AND :toDate