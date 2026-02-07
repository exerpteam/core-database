
SELECT
    *
FROM
    BI_SALES_LOG
WHERE
    CENTER_ID IN ($$Scope$$)    
    AND ETS >= $$startdate$$
    AND ETS < $$enddate$$ + (86400 * 1000)    
