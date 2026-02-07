SELECT biview.*
FROM BI_PRODUCT_PRODUCT_GROUPS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$