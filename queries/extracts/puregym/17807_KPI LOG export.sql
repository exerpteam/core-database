 WITH
     params AS
     (
         SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolongC(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI'),100 ) AS BIGINT)
            END                                                                       AS FROMDATE,
            CAST(datetolongC(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI'),100) AS BIGINT) AS TODATE
     )
 SELECT
     biview.*
 FROM
     params
   ,(
         SELECT
             kf.EXTERNAL_ID                 AS "KPI_FIELD"
           , kd.CENTER                      AS "CENTER_ID"
           , c.shortname                    AS "CENTER_NAME"
           , kd.FOR_DATE                    AS "FOR_DATE"
           , ROUND(kd.VALUE,0) AS "KPI_VALUE"
           , CASE
                 WHEN kf.TYPE = 'EXTERNAL'
                 THEN 'EXTERNAL'
                 ELSE 'SYSTEM'
             END          AS "TYPE"
           , kd.TIMESTAMP AS "ETS"
         FROM
             KPI_DATA kd
         JOIN
             centers c
         ON
             c.id = kd.CENTER
         JOIN
             KPI_FIELDS kf
         ON
             kf.id = kd.FIELD
         WHERE
             kf.EXTERNAL_ID LIKE 'BI_%')biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
