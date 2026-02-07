SELECT
    biview.*
FROM
    BI_PRODUCTS biview
WHERE
 biview.CENTER_ID in ($$scope$$)