SELECT
    biview.*
FROM
    BI_SUBSCRIPTIONS biview
WHERE
    biview.CENTER_ID in (:Centers)