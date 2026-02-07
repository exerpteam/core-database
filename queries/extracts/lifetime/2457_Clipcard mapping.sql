WITH
    params AS
    (
        SELECT
            c.id AS CENTER_ID,
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS') , c.id) AS FROMDATE,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TODATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT 
        replace(left(c.cc_comment,strpos(c.cc_comment,chr(13))-1), 'LegacyClipcardId: ', '')    AS MMSClipcardId, 
        c.center || 'cc' || c.id || 'cc' || c.subid                                             AS ExerpClipcardId,
	c.center AS Clipcard_Center
FROM lifetime.clipcards c
JOIN params p ON p.CENTER_ID = c.CENTER
WHERE 
        c.cc_comment IS NOT NULL
        AND c.valid_from BETWEEN p.FROMDATE AND p.TODATE