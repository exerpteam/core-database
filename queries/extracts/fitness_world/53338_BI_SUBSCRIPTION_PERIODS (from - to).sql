-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    BI_SUBSCRIPTION_PERIODS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
