SELECT
    biview.*
FROM
    BI_CENTER_EXT_ATTR biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
AND biview.CENTER_ID in ($$scope$$)