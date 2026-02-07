 WITH
     params AS
     (
         SELECT
             CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(CURRENT_TIMESTAMP)-$$offset$$-DATE('1970-01-01'))*24*3600*1000::bigint END      AS FROMDATE,
             (TRUNC(CURRENT_TIMESTAMP+1)-DATE('1970-01-01'))*24*3600*1000::bigint                                                       AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     BI2_PERSON biview
 WHERE
     biview."ETS" >= PARAMS.FROMDATE
     AND biview."CENTER_ID" in ($$scope$$)
