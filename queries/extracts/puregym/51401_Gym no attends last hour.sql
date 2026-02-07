 SELECT
     c.id         AS "Club Id",
     c.shortname  AS "Club Name",
     k.for_date   AS "Attend Date",
     k.value      AS "Total Attend",
     c.startupdate AS "Club Startup Date"
 FROM
     kpi_data k
 JOIN
     centers c
 ON
     c.id = k.center
 WHERE
     k.field = 202
     AND trunc(c.startupdate) <= current_timestamp
     AND k.for_date = TRUNC(CURRENT_TIMESTAMP-1/24)
     AND k.value < 50
         AND c.id not in (136, 149, 100, 189)
 ORDER BY
     c.shortname
