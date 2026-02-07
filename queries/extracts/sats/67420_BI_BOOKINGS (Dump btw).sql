WITH
    PARAMS AS
    (
        SELECT
			/*+ materialize */
            datetolongC(TO_CHAR($$from_date$$, 'YYYY-MM-DD HH24:MI'), c.ID) AS FROMDATE,
            datetolongC(TO_CHAR($$to_date$$, 'YYYY-MM-DD HH24:MI'), c.ID) + 86400*1000 AS TODATE,
            c.id AS CENTER_ID
        FROM
            centers c
    )
SELECT
	biview.*
FROM
    params
JOIN
    BI_BOOKINGS biview
ON
    biview.CENTER_ID = params.CENTER_ID
WHERE
    biview.ETS >= PARAMS.FROMDATE 
	AND biview.ETS < PARAMS.TODATE
	