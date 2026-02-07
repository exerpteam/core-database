SELECT
    biview.*
FROM
    BI_SUBSCRIPTION_STATE_LOG biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
    AND biview.CENTER_ID in ($$scope$$)