 WITH
     params AS
     (
SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24*
            AS bigint),
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     BI_VISIT_LOG biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE $$FromDate$$ AND $$ToDate$$
 and biview."CENTER_ID" in ($$scope$$)

