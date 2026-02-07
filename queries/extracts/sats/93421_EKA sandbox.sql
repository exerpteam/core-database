WITH params AS materialized
(SELECT
CAST(datetolongC(getCenterTime(c.id), c.id) AS BIGINT) AS fromDateTime,
CAST(datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')+interval '1 day', 'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
c.id,
c.name
FROM
centers c
)
SELECT
longtodateC(bo.starttime, bo.center) AS starttime,
bo.center,
par.name AS center_name,
bo.name AS class_name,
longtodateC(bo.queue_run_time, bo.center) AS waitinglist_runtime,
bo.queue_run_by_center ||'p'|| bo.queue_run_by_id AS waitinglist_run_exployee,
tc.name AS timeconfiguration
FROM
bookings bo
JOIN
params par
ON
par.id = bo.center
JOIN
sats.activity ac
ON
ac.id = bo.activity
LEFT JOIN
sats.booking_time_configs tc
ON
tc.id = ac.time_config_id
WHERE
bo.starttime BETWEEN par.fromDateTime AND par.toDate
ORDER BY
bo.starttime