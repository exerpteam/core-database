WITH params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR($$from_date$$, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR($$to_date$$, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    biview.*
FROM
    params,
    BI_BOOKINGS biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
