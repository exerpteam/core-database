WITH
    params AS
    (
        SELECT
            CAST((extract(epoch FROM CURRENT_DATE at time zone c.time_zone - $$offset$$)) AS bigint)*1000 AS FROMDATE ,
            CAST((extract(epoch FROM CURRENT_DATE at time zone c.time_zone + 1)) AS bigint)*1000          AS TODATE
          
    )
SELECT
    biview.*
FROM
    params ,
    (
        SELECT
            kf.EXTERNAL_ID                 AS "KPI_FIELD" ,
            kd.CENTER                      AS "CENTER_ID" ,
            c.shortname                    AS "CENTER_NAME" ,
            kd.FOR_DATE                    AS "FOR_DATE" ,
            ROUND(kd.VALUE,0) AS "KPI_VALUE" ,
            CASE
                WHEN kf.TYPE = 'EXTERNAL'
                THEN 'EXTERNAL'
                ELSE 'SYSTEM'
            END          AS "TYPE" ,
            kd.TIMESTAMP AS "ETS"
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
			kf.external_id NOT IN ('NET_GAIN','MEMBERS_DAY_BEFORE')
			and c.id in ($$Scope$$)
			
)biview
WHERE
    biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE