-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    BI_DAILY_MEMBER_STATE biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$