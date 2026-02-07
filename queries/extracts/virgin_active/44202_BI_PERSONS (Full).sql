SELECT
    biview.*
FROM
    BI_PERSONS biview
WHERE
    biview.CENTER_ID in (:Centers)