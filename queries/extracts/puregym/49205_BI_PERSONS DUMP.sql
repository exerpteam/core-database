SELECT
    biview.*
FROM
    BI_PERSONS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
AND biview.CENTER_ID in ($$scope$$)