-- The extract is extracted from Exerp on 2026-02-08
--  
WITH hours AS (
  SELECT generate_series(5, 23) AS hour_of_day
),
age_groups AS (
  SELECT unnest(ARRAY[
    '10 - 19 år',
    '20 - 29 år',
    '30 - 44 år',
    '45 - 59 år',
    '60 - 80 år'
  ]) AS age_group
),
src AS (
  SELECT
    to_timestamp(c.checkin_time / 1000.0) AS ts,
    p.birthdate
  FROM checkins c
  JOIN persons p
    ON p.center = c.person_center
   AND p.id = c.person_id
  WHERE c.checkin_time >= :start
    AND c.checkin_time < :end + (60 * 60 * 1000 * 24)
    AND c.checkin_center = :center
),
bucketed AS (
  SELECT
    CASE
      WHEN date_part('year', age(ts::date, birthdate)) BETWEEN 10 AND 19 THEN '10 - 19 år'
      WHEN date_part('year', age(ts::date, birthdate)) BETWEEN 20 AND 29 THEN '20 - 29 år'
      WHEN date_part('year', age(ts::date, birthdate)) BETWEEN 30 AND 44 THEN '30 - 44 år'
      WHEN date_part('year', age(ts::date, birthdate)) BETWEEN 45 AND 59 THEN '45 - 59 år'
      WHEN date_part('year', age(ts::date, birthdate)) BETWEEN 60 AND 80 THEN '60 - 80 år'
      ELSE NULL
    END AS age_group,
    extract(hour from ts)::int AS hour_of_day
  FROM src
),
counts AS (
  SELECT
    age_group,
    hour_of_day,
    count(*) AS cnt
  FROM bucketed
  WHERE age_group IS NOT NULL
    AND hour_of_day BETWEEN 5 AND 23
  GROUP BY age_group, hour_of_day
),
grid AS (
  SELECT
    ag.age_group,
    h.hour_of_day
  FROM age_groups ag
  CROSS JOIN hours h
),
filled AS (
  SELECT
    g.age_group,
    g.hour_of_day,
    COALESCE(c.cnt, 0) AS cnt
  FROM grid g
  LEFT JOIN counts c
    ON c.age_group = g.age_group
   AND c.hour_of_day = g.hour_of_day
),
with_pct AS (
  SELECT
    age_group,
    hour_of_day,
    cnt,
    COALESCE(
      round(
        100.0 * cnt /
        nullif(sum(cnt) OVER (PARTITION BY hour_of_day), 0),
        0
      )::int,
      0
    ) AS pct
  FROM filled
)
SELECT
  age_group AS "Tider",

  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 5)  AS "5",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 6)  AS "6",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 7)  AS "7",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 8)  AS "8",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 9)  AS "9",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 10) AS "10",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 11) AS "11",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 12) AS "12",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 13) AS "13",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 14) AS "14",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 15) AS "15",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 16) AS "16",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 17) AS "17",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 18) AS "18",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 19) AS "19",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 20) AS "20",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 21) AS "21",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 22) AS "22",
  max(format('%sst, %s%%', cnt, pct)) FILTER (WHERE hour_of_day = 23) AS "23"

FROM with_pct
GROUP BY age_group
ORDER BY
  CASE age_group
    WHEN '10 - 19 år' THEN 1
    WHEN '20 - 29 år' THEN 2
    WHEN '30 - 44 år' THEN 3
    WHEN '45 - 59 år' THEN 4
    WHEN '60 - 80 år' THEN 5
    ELSE 99
  END;
