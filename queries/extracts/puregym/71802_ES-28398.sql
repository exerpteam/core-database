-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    any_club_in_scope AS
    (
        SELECT
            id
        FROM
            centers
        WHERE
            id IN ($$scope$$)
            AND rownum = 1
    )
    ,
    params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN
            any_club_in_scope
    )
SELECT
    P.CENTER || 'p' || P.ID                                                                                                                                                         AS "MEMBERNO",
    TO_CHAR(p.CENTER)                                                                                                                                                               AS "PCENTER",
    TO_CHAR(p.ID)                                                                                                                                                                   AS "PID",
    TO_CHAR(cp.EXTERNAL_ID)                                                                                                                                                          AS "EXTERNALID",


    DECODE(pea.CHANGE_ATTRIBUTE,'true',1,0)                                                                                                                                       AS "SMSMARKETING"
    --TO_CHAR(longtodatetz(pea.SMSMARKET_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                     AS "SMSMARKETINGDATE"
 
FROM 
    PUREGYM.PERSONS p
JOIN
    centers c
ON
    c.id = p.CENTER
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    PUREGYM.JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.id = p.SUSPENSION_INTERNAL_NOTE
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    p.TRANSFERS_CURRENT_PRS_CENTER,
                    p.TRANSFERS_CURRENT_PRS_ID,
                    pcl.CHANGE_ATTRIBUTE,
                    pcl.NEW_VALUE,
                    pcl.ENTRY_TIME
                FROM
                    puregym.person_change_logs pcl
                JOIN
                    PERSONS p
                ON
                    p.center = pcl.PERSON_CENTER
                    AND p.id = pcl.PERSON_ID
                WHERE
                    pcl.CHANGE_ATTRIBUTE IN ( 'SMSMARKETING'))) pea
ON
    pea.TRANSFERS_CURRENT_PRS_CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND pea.TRANSFERS_CURRENT_PRS_ID = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    (
        SELECT
            cp.center as PERSON_CENTER,
            cp.id as PERSON_ID,
            MAX(dms.CHANGE_DATE) AS LASTJOINDATE,
            MIN(dms.CHANGE_DATE) AS FIRSTJOINDATE
        FROM
            DAILY_MEMBER_STATUS_CHANGES dms
        JOIN
            PERSONS p
        ON
            p.center = dms.PERSON_CENTER
            AND p.id = dms.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        WHERE
            dms.ENTRY_STOP_TIME IS NULL
            AND dms.MEMBER_NUMBER_DELTA =1
            AND dms.CHANGE IN (0,
                               1,
                               2,
                               3,
                               6,
                               9,
							   10)
        GROUP BY
            cp.center,
            cp.id) dms
ON
    dms.PERSON_CENTER = p.center
    AND dms.PERSON_ID = p.id
LEFT JOIN
(
  SELECT scl.CENTER, scl.id, MAX(scl.ENTRY_START_TIME) AS LastTime
  FROM 
      STATE_CHANGE_LOG scl
  WHERE
      scl.ENTRY_TYPE = 1  
  GROUP BY 
      scl.CENTER, scl.id
) last_person_status
ON
  last_person_status.id = p.id
  AND last_person_status.center = p.center
LEFT JOIN
(   SELECT distinct
		 ar.CUSTOMERCENTER
        , ar.CUSTOMERID
        , pag.INDIVIDUAL_DEDUCTION_DAY 
    FROM ACCOUNT_RECEIVABLES ar
    join PAYMENT_ACCOUNTS pa on pa.center = ar.center and pa.id = ar.id
    join PAYMENT_AGREEMENTS pag on pag.CENTER = pa.ACTIVE_AGR_center and pag.ID = pa.ACTIVE_AGR_id and pag.SUBID = pa.ACTIVE_AGR_SUBID and pag.state=4
) deduction_day
ON
    deduction_day.CUSTOMERID = p.id
    AND deduction_day.CUSTOMERCENTER = p.center
CROSS JOIN
    PARAMS
WHERE
    p.CENTER IN ($$scope$$)
    AND p.SEX != 'C'
    AND p.LAST_MODIFIED >= PARAMS.FROMDATE
    AND p.LAST_MODIFIED < PARAMS.TODATE
    AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER AND p.TRANSFERS_CURRENT_PRS_ID = p.ID