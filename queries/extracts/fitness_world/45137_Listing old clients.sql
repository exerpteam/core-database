-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3816
SELECT 
   sq.*
FROM
(SELECT
    c.center, c.id, c.name, c.CLIENTID, c.type, c.STATE, longtodateC(max(ci.startuptime),c.center) AS Startup_Time, longtodateC(max(ci.shutdowntime),c.center) AS Shutdown_Time
FROM
    clients c
JOIN
    client_instances ci
ON
    c.id = ci.client 
WHERE
    c.STATE = 'ACTIVE'
    AND c.center in (:Scope)
GROUP BY c.center, c.id, c.name, c.CLIENTID, c.type, c.STATE
) sq
WHERE 
  (sq.shutdown_time <= to_date('2018-01-01','yyyy-mm-dd') OR sq.shutdown_time IS NULL)
  AND sq.startup_time <= to_date('2017-09-30','yyyy-mm-dd')