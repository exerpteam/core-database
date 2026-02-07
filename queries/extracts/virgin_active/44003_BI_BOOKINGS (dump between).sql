SELECT
    biview.*
FROM
    BI_BOOKINGS biview
WHERE
    biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$
and biview.CENTER_ID in ($$scope$$)