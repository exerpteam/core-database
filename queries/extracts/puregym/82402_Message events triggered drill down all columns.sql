WITH
    params AS materialized
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                                                                                 AS StartDate,
            $$ToDate$$                                                                                 AS EndDate,
            datetolongTZ(TO_CHAR(cast($$FromDate$$ as date), 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR(cast($$ToDate$$ as date), 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
        
    )
SELECT *
FROM MESSAGES m
CROSS JOIN params
 WHERE
     m.CENTER IN ($$Scope$$)
     AND m.SENTTIME BETWEEN params.StartDateLong AND params.EndDateLong