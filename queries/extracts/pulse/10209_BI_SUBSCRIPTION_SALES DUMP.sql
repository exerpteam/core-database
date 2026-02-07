SELECT
    biview.*
FROM
    
    BI_SUBSCRIPTION_SALES biview
WHERE
    biview.ETS BETWEEN $$FROMDATE$$ AND $$TODATE$$ AND CENTER_ID in ($$scope$$)