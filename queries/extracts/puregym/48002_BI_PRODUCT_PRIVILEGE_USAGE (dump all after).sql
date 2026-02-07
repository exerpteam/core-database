SELECT biview.*
FROM BI_PRODUCT_PRIVILEGE_USAGE biview
WHERE
    biview."ETS" >= :DateFrom