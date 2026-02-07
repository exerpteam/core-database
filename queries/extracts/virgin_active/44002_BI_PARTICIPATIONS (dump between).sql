SELECT
    biview.*
FROM
    BI_PARTICIPATIONS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
and biview.CENTER_ID in ($$scope$$)