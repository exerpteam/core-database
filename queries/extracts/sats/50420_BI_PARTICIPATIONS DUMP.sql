WITH
    params AS
    (
        SELECT
            $$from_date$$ AS FROMDATE,
            $$to_date$$                                AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    BI_PARTICIPATIONS biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
	and biview.CENTER_ID in ($$scope$$)