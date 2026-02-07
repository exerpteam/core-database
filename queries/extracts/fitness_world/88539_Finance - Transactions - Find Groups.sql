-- This is the version from 2026-02-05
-- Count of acc_trans by center
           WITH
                    params AS
                    (
                     SELECT
                                /*+ materialize */
                                --datetolongTZ (TO_CHAR (to_date ('2022-01-01', 'yyyy-mm-dd'), 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen')  AS fromDate,
                                --datetolongTZ (TO_CHAR (to_date ('2022-01-30', 'yyyy-mm-dd'), 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen') -1 AS toDate
                                :FromDate                         AS fromDate,
                                :ToDate                           AS toDate
                           FROM
                                dual
                    )
             SELECT
                        
                        atr.CENTER AS center,
                        COUNT(*)   AS COUNT
                        
                   FROM
                        ACCOUNT_TRANS atr
             CROSS JOIN
                        params
                  WHERE
                        atr.ENTRY_TIME BETWEEN params.fromDate AND params.toDate
                        AND atr.CENTER IN (:scope)
               GROUP BY
                        atr.center
               ORDER BY
                        COUNT ASC
       