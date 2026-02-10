-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pcl.person_center AS "Member Center",
        CAST(pcl.person_id AS TEXT) AS "Member ID",
        pcl.change_attribute AS "Category",
        pcl.new_value AS "New value",
        TO_CHAR(longtodateC(pcl.entry_time, pcl.person_center), 'dd-MM-YYYY') AS "Date"
FROM person_change_logs pcl
WHERE
        (pcl.person_center,pcl.person_id) IN (:memberid)