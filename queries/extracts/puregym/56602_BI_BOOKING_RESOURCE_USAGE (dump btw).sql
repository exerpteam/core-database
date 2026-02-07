SELECT
    biview.*
FROM
    BI_BOOKING_RESOURCE_USAGE biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$

