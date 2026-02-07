SELECT
    c.name,
    SUM(DECODE(ci.checkin_center, center, 1, 0)) AS homevisits,
    SUM(DECODE(ci.checkin_center, center, 0, 1)) AS awayvisits
FROM
    centers c,
    CHECKIN_LOG ci
WHERE
    c.id >= :FromCenter
AND c.id <= :ToCenter
AND ci.CHECKIN_TIME > :Check_in_from_date
AND ci.CHECKIN_TIME < (:Check_in_to_date + 24*3600*1000)
AND ci.center = c.id
GROUP BY
    c.name
ORDER BY
    c.name

