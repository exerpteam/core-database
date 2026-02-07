SELECT
    biview.*
FROM
    
    BI_ACCESS_PRIVILEGE_USAGE biview
WHERE
    biview.ETS BETWEEN $$FROMDATE$$ AND $$TODATE$$ AND CENTER_ID in ($$scope$$)