SELECT
    c.name,
    sb.center,
    COUNT (sb.id) baskets
FROM
    SATS.SHOPPING_BASKETS sb
JOIN
    centers c
ON
    c.id = sb.center
WHERE
    sb.status in (:status)
and sb.origin in (:source)
GROUP BY
    c.name,
    center
ORDER BY
    sb.center ASC