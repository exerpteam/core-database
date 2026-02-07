WITH
    transfers AS
    (
        SELECT
            /*+INLINE*/
            cp.EXTERNAL_ID,
            p.center as CENTER_ID,
            TRUNC(longtodateC(scl.ENTRY_START_TIME,p.center))                                                                                                                   AS From_Date,
            ROW_NUMBER() OVER (PARTITION BY p.CURRENT_PERSON_CENTER, p.CURRENT_PERSON_ID, TRUNC(longtodateC(scl.ENTRY_START_TIME,p.center)) ORDER BY scl.ENTRY_START_TIME DESC)    rn,
            COUNT(DISTINCT scl.center) OVER (PARTITION BY p.CURRENT_PERSON_CENTER, p.CURRENT_PERSON_ID, TRUNC(longtodateC(scl.ENTRY_START_TIME,p.center)))                         ld,
            ROW_NUMBER() OVER (PARTITION BY p.CURRENT_PERSON_CENTER, p.CURRENT_PERSON_ID ORDER BY TRUNC(longtodateC(scl.ENTRY_START_TIME,p.center)) ASC )                          rnk
        FROM
            PUREGYM.PERSONS p
        JOIN
            PUREGYM.STATE_CHANGE_LOG scl
        ON
            scl.center = p.center
            AND scl.id = p.id
            AND scl.ENTRY_TYPE =1
        JOIN
            persons cp
        ON
            p.CURRENT_PERSON_CENTER = cp.CENTER
            AND p.CURRENT_PERSON_ID = cp.ID
        
    )
SELECT
    EXTERNAL_ID PERSON_ID,
    CENTER_ID,
    From_Date
FROM
    transfers
WHERE
    rn = 1
    AND (
        ld >1
        OR rnk=1)