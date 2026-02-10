-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11818
SELECT DISTINCT
    crl.cash_register_center ||' - '||cen.name AS "Cash Register Center"
FROM
    lifetime.cash_register_log crl
JOIN
    lifetime.centers cen
ON
    cen.id = crl.cash_register_center
WHERE
    crl.cash_register_center NOT IN
    (
        SELECT
            crl2.cash_register_center
        FROM
            lifetime.cash_register_log crl2
        WHERE
            crl2.log_type = 'CLOSE_CASH_REGISTER'
        AND crl2.log_time >= FLOOR(extract(epoch from now())*1000) - (86400*1000*7)
	)