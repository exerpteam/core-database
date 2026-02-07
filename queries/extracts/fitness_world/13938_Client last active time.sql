-- This is the version from 2026-02-05
-- To find the active clients
SELECT
   *
FROM
   CLIENTS CL
JOIN CLIENT_INSTANCES CLI
ON
   CLI.CLIENT = CL.ID
WHERE
   center in (:scope)
AND CL.STATE = 'ACTIVE'
