SELECT
    biview.*
FROM
    BI_DAILY_MEMBER_STATE biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
    AND biview."CENTER_ID" in ($$scope$$)