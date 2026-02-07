SELECT
    biview.*
FROM
    
    BI_SUBSCRIPTION_STATE_LOG biview
WHERE
    biview.ETS BETWEEN $$FROMDATE$$ AND $$TODATE$$ AND CENTER_ID in ($$scope$$)