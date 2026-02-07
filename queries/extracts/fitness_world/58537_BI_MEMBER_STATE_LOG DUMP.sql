-- This is the version from 2026-02-05
--  
SELECT
   biview.*
FROM
   BI_MEMBER_STATE_LOG biview
WHERE
   biview.ETS >= $$FROMDATE$$ 
   AND biview.ETS < $$TODATE$$