SELECT
    biview.*
FROM
    BI_ACCEPTED_MATERIALS biview
WHERE
biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
and biview.CENTER_ID in ($$scope$$)
