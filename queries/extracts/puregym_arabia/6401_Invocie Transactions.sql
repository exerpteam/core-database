-- The extract is extracted from Exerp on 2026-02-08
-- Returns list of transactions included in a members invoice
SELECT
    *
FROM
    puregym_arabia.invoice_lines_mt
WHERE
    center = 8001
AND ID = 27387;