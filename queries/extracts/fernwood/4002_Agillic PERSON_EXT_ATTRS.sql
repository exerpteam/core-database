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
    p.EXTERNAL_ID                                                               AS "PERSON_ID",
    pea.NAME || '_' || pea.PERSONCENTER || '_' || pea.PERSONID                     AS "PERSON_EXT_ATTRS.ID",
    pea.NAME                                                                    AS "PERSON_EXT_ATTRS.NAME",
    CASE
        WHEN pea.TXTVALUE = 'false'
        THEN 'FALSE'
        WHEN pea.TXTVALUE = 'true'
        THEN 'TRUE'
        ELSE pea.TXTVALUE
    END                                      AS "PERSON_EXT_ATTRS.VALUE",
    CAST( p.CENTER AS VARCHAR(255))                                  AS "PERSON_EXT_ATTRS.CENTER_ID",
    TO_CHAR(longToDatetz(pea.LAST_EDIT_TIME,cen.time_zone), 'dd.MM.yyyy HH24:MI:SS') AS
    "PERSON_EXT_ATTRS.LAST_UPDATED_EXERP"
FROM
    PERSONS p
JOIN
    CENTERS cen
ON
    p.CENTER = cen.ID
JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
AND pea.PERSONID =p.id
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude Transferred
AND p.external_id IS NOT NULL
AND pea.NAME NOT LIKE '%eClub%'
AND pea.NAME != 'CREATION_DATE'
AND pea.NAME != 'COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Only persons updated in the last 24 hours
AND pea.LAST_EDIT_TIME > params.FROM_DATE