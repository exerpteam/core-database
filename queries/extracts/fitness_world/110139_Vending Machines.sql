-- This is the version from 2026-02-05
--  
SELECT
vm.center AS center_id,
c.name AS center_name,
vm.name AS vending_name,
vm.external_id AS vending_id
FROM
fw.vending_machine vm
JOIN
centers c
ON
c.id = vm.center
WHERE
vm.state = 'ACTIVE'
AND vm.center in (:scope)
ORDER BY
vm.center,
vm.external_id