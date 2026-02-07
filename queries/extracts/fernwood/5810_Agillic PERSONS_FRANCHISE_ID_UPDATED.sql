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
    p.EXTERNAL_ID                      AS "PERSON_ID",
    cea1.TXT_VALUE                     AS "HOME_CENTER_FRANCHISE_ID"
FROM
    PERSONS p
JOIN
    CENTERS cen
ON
    p.CENTER = cen.ID
LEFT JOIN
    CENTER_EXT_ATTRS cea1
ON
    cea1.name ='FranchiseId'
AND cea1.center_id = cen.id  
JOIN
    params
ON
    params.CENTER_ID = cen.id    
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude Transferred
AND p.external_id IS NOT NULL
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
    -- Only persons updated recently
AND cea1.LAST_EDIT_TIME > params.FROM_DATE