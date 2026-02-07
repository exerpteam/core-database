 WITH
     params AS
     (
     SELECT
     CASE
        WHEN $$offset$$=-1
        THEN to_date('1970-01-01','yyyyy-MM-dd')
        ELSE CURRENT_DATE-$$offset$$
     END FROMDATE,
        CURRENT_DATE+1                              AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     BI_REVENUE_PERIODS biview
 WHERE
     biview.BOOK_DATE BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
