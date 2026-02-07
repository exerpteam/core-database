SELECT
    cc.CENTER || 'ccol' || cc.ID "ID",
    cc.CENTER                  "CENTER_ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
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
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE
        WHEN P.SEX = 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
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
            END
        ELSE NULL
    END                                       AS "COMPANY_ID",
    cc.START_DATETIME                         AS "START_DATETIME",
    cc.AMOUNT                                 AS "AMOUNT",
    CAST(CAST (cc.CLOSED AS INT) AS SMALLINT) AS "CLOSED",
    cc.CLOSED_DATETIME                        AS "CLOSED_DATETIME",
    cc.CURRENTSTEP                            AS "CURRENT_STEP",
    CASE cc.CURRENTSTEP_TYPE
        WHEN 0
        THEN 'MESSAGE'
        WHEN 1
        THEN 'REMINDER'
        WHEN 2
        THEN 'BLOCK'
        WHEN 3
        THEN 'REQUESTANDSTOP'
        WHEN 4
        THEN 'CASHCOLLECTION'
        WHEN 5
        THEN 'CLOSE'
        WHEN 6
        THEN 'WAIT'
        WHEN 7
        THEN 'REQUESTBUYOUTANDSTOP'
        WHEN 8
        THEN 'PUSH'
        ELSE 'UNDEFINED'
    END AS "CURRENT_STEP_TYPE",
    cc.currentstep_date as "CURRENT_STEP_DATE",
    cc.LAST_MODIFIED AS "ETS"
FROM
    CASHCOLLECTIONCASES cc
JOIN
    PERSONS p
ON
    p.center = cc.PERSONCENTER
    AND p.ID = cc.PERSONID
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    cc.MISSINGPAYMENT = 1
