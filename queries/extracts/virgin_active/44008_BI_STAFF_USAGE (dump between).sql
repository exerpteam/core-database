SELECT
    biview.*
FROM
    BI_STAFF_USAGE biview
WHERE
biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
and biview.CENTER_ID in ($$scope$$)