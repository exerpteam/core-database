SELECT
    biview.*
FROM
    BI_VISIT_LOG biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
    AND biview."CENTER_ID" in ($$scope$$)