SELECT
    biview.*
FROM
    BI_SALES_LOG biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
