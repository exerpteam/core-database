SELECT
    biview.*
FROM
    BI_FREEZES biview
WHERE biview.ETS >= $$FROMDATE$$ 
	AND biview.ETS < $$TODATE$$
	AND biview."SUBSCRIPTION_CENTER_ID" in ($$scope$$)