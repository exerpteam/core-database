SELECT
    biview.*
FROM
    BI_SALES_LOG biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$