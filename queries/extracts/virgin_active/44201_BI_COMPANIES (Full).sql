SELECT
    biview.*
FROM
    BI_COMPANIES biview
WHERE
    biview.HOME_CENTER_ID in (:Centers)