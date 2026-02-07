WITH
    date_series AS
    (
        SELECT
            *,
            extract(epoch FROM week_start)::bigint*1000                        AS epoch_week_start,
            extract(epoch FROM (week_start - interval '4 weeks'))::bigint*1000 AS
            epoch_four_week_ago
        FROM
            (
                SELECT
                    generate_series( date_trunc('week', CURRENT_DATE) - interval '5 weeks',
                    date_trunc('week', CURRENT_DATE) - interval '1 week', interval '1 week' ) AS
                    week_start )
    )
    ,
    centers_id AS
    (
        SELECT
            id AS center_id
        FROM
            centers
        WHERE
            id IN (:scope)
    )
    ,
    week_center_combinations AS
    (
        SELECT
            ds.week_start,
            ds.epoch_week_start,
            ds.epoch_four_week_ago,
            c.center_id
        FROM
            date_series ds
        CROSS JOIN
            centers_id c
    )
SELECT
    wc.week_start::DATE AS week,
    wc.center_id,
    COALESCE(COUNT(DISTINCT p.participant_center || 'p' || p.participant_id), 0) AS
    unique_show_ups_in_past_4_weeks
FROM
    week_center_combinations wc
LEFT JOIN
    participations p
ON
    p.start_time >= wc.epoch_four_week_ago
AND p.start_time < wc.epoch_week_start
AND p.state = 'PARTICIPATION'
AND p.booking_center=wc.center_id
LEFT JOIN
    bookings b
ON
    p.booking_center = b.center
AND p.booking_id = b.id
LEFT JOIN
    activity a
ON
    b.activity = a.id
WHERE
    (
        a.activity_type = 2
    OR  a.activity_type IS NULL) -- classes only
GROUP BY
    wc.week_start,
    wc.center_id
ORDER BY
    wc.week_start,
    wc.center_id; 
    