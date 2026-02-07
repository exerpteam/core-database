-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    BI_DAILY_MEMBER_STATE biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$