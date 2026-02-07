SELECT
    id                                                          AS "ID",
    name                                                        AS "NAME",
    state                                                       AS "STATE",
    min_age                                                     AS "MINIMUM_AGE",
    max_age                                                     AS "MAXIMUM_AGE",
    external_id                                                 AS "EXTERNAL_ID",
    COALESCE(CAST(CAST (strict_min_age AS INT) AS SMALLINT) ,0) AS "STRICT_AGE_LIMIT"
FROM
    age_groups