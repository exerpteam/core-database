SELECT
    CASE
        WHEN bo.queue_run_time IS NULL
        THEN 'false'
        ELSE 'true'
    END AS Waiting_list_run
FROM
    bookings bo
WHERE
    bo.center = :center
AND bo.id = :id