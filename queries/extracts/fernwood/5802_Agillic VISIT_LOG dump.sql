WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            datetolongtz(TO_CHAR(TO_DATE($$from_date$$ , 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI'),
            c.time_zone) AS FROM_DATE,
            datetolongtz(TO_CHAR(TO_DATE($$to_date$$, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI'),
            c.time_zone) AS TO_DATE
        FROM
            centers c
    )
SELECT
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                                         AS "PERSON_ID",
    CAST ( c.ID AS VARCHAR(255))                                AS "VISIT_LOG.VISIT_ID",
    CAST ( c.CHECKIN_CENTER AS VARCHAR(255))                          AS "VISIT_LOG.CENTER_ID",
    CAST ( p.CENTER AS VARCHAR(255))                                  AS "VISIT_LOG.HOME_CENTER_ID",
    TO_CHAR(longtodatetz(c.CHECKIN_TIME, cen.time_zone),'yyyy-MM-dd') AS "VISIT_LOG.CHECK_IN_DATE"
    ,
    TO_CHAR(longtodatetz(c.CHECKIN_TIME, cen.time_zone),'HH24:MI:SS') AS "VISIT_LOG.CHECK_IN_TIME"
    ,
    TO_CHAR(longtodatetz(c.CHECKIN_TIME, cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
    "VISIT_LOG.CHECK_IN_DATETIME",
    TO_CHAR(longtodatetz(c.CHECKOUT_TIME, cen.time_zone),'yyyy-MM-dd') AS
    "VISIT_LOG.CHECK_OUT_DATE",
    TO_CHAR(longtodatetz(c.CHECKOUT_TIME, cen.time_zone),'HH24:MI:SS') AS
                                                                     "VISIT_LOG.CHECK_OUT_TIME",
    BI_DECODE_FIELD('CHECKINS','CHECKIN_RESULT',c.CHECKIN_RESULT) AS "VISIT_LOG.CHECK_IN_RESULT",
    CASE
        WHEN c.CARD_CHECKED_IN = 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "VISIT_LOG.CARD_CHECKED_IN"
FROM
    CHECKINS c
JOIN
    PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
AND p.id = c.PERSON_ID
JOIN
    centers cen
ON
    cen.id = c.CHECKIN_CENTER
    join PARAMS on PARAMS.CENTER_ID = cen.id
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Only check-ins registered in the last 24 hours
AND c.CHECKIN_TIME BETWEEN PARAMS.FROM_DATE and PARAMS.TO_DATE