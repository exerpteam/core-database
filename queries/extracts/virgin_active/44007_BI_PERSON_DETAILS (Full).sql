SELECT
    biview.*
FROM
    BI_PERSON_DETAILS biview
WHERE
   biview.CENTER_ID in ($$scope$$)