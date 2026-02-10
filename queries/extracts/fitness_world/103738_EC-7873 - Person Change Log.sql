-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
pcl.person_center AS "Medlem Center",
pcl.person_id::varchar(20) AS "Medlem ID",
pcl.change_attribute AS "Kategori",
pcl.new_value AS "Ny værdi",
TO_CHAR(longtodateC(pcl.entry_time, pcl.person_center), 'dd-MM-YYYY') AS "Dato"
FROM
fw.person_change_logs pcl
WHERE
pcl.person_center ||'p'|| pcl.person_id IN (:memberid)