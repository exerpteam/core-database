WITH
    params AS
    (
        SELECT
            ID,
            shortname,
            CAST(datetolongC(TO_CHAR(to_date($$from_date$$,'YYYY-MM-DD')+1,'YYYY-MM-DD HH24:MI:SS'), ID)
            AS BIGINT) AS FROMDATE1,
            CAST(datetolongC(TO_CHAR(to_date($$to_date$$,'YYYY-MM-DD')+2,'YYYY-MM-DD HH24:MI:SS'), ID)
            AS BIGINT) AS TODATE1
        FROM
            purefitnessus.centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    kf.EXTERNAL_ID    AS "KPI_FIELD" ,
    kd.CENTER         AS "CENTER_ID" ,
    params.shortname       AS "CENTER_NAME" ,
    kd.FOR_DATE       AS "FOR_DATE" ,
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
    params
ON
    params.id = kd.CENTER
JOIN
    AREA_CENTERS AC
ON
    params.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    -- Area US and Blink
AND A.PARENT IN (7,8,9,10,78)
JOIN
    KPI_FIELDS kf
ON
    kf.id = kd.FIELD
WHERE
    kf.external_id NOT IN ('NET_GAIN',
                           'MEMBERS_DAY_BEFORE')
AND kd.TIMESTAMP BETWEEN params.FROMDATE1 AND PARAMS.TODATE1