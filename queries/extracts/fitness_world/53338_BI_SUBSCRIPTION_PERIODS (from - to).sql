-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    BI_SUBSCRIPTION_PERIODS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
