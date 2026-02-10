-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                      AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
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
    END                                                 AS "PERSON_ID",
    cc.CENTER || 'cc' || cc.ID                                              AS "DEBT_CASE.ID",
    CAST( cc.center AS VARCHAR(255))                                       AS "DEBT_CASE.CENTER_ID",
    TO_CHAR(longtodatetz(cc.START_DATETIME, cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                         "DEBT_CASE.START_DATETIME",
    CAST ( cc.AMOUNT AS VARCHAR(255)) AS "DEBT_CASE.AMOUNT",
    CASE
        WHEN cc.CLOSED = 1
        THEN 'TRUE'
        WHEN cc.CLOSED = 0
        THEN 'FALSE'
        ELSE 'UNKNOWN'
    END                                                                       AS "DEBT_CASE.CLOSED",
    TO_CHAR(longtodatetz(cc.CLOSED_DATETIME, cen.time_zone),'dd.MM.yyyy HH24:MI:SS') AS
                                             "DEBT_CASE.CLOSED_DATETIME",
    CAST( cc.CURRENTSTEP AS VARCHAR(255))                               AS "DEBT_CASE.CURRENT_STEP",
    TO_CHAR(longtodatetz(cc.LAST_MODIFIED, cen.time_zone), 'dd.MM.yyyy HH24:MI:SS') AS
    "DEBT_CASE.LAST_UPDATED_EXERP"
FROM
    CASHCOLLECTIONCASES cc
JOIN
    PERSONS p
ON
    p.center = cc.PERSONCENTER
AND p.ID = cc.PERSONID
    -- Needed to get the home center's country ID of the subscription owner to limit the scope of
    -- the data synchronization
JOIN
    centers cen
ON
    cen.id = cc.CENTER
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    cc.MISSINGPAYMENT = 1
    -- Phase 1 of Agillic project only covers DK
AND p.SEX != 'C'
    -- Exclude Transferred
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Limit by date
AND cc.LAST_MODIFIED > params.FROM_DATE
