SELECT
    biview.*
FROM
    
    BI_VISIT_LOG biview
WHERE
    biview.ETS BETWEEN $$FROMDATE$$ AND $$TODATE$$ AND CENTER_ID in ($$scope$$)