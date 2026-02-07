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
    END                                       AS "COMPANY_ID",
    cc.START_DATETIME                         AS "START_DATETIME",
    CAST(CAST (cc.CLOSED AS INT) AS SMALLINT) AS "CLOSED",
    cc.CLOSED_DATETIME                        AS "CLOSED_DATETIME",
    cc.LAST_MODIFIED                             "ETS"
FROM
    CASHCOLLECTIONCASES cc
LEFT JOIN
    PERSONS p
ON
    p.center = cc.PERSONCENTER
    AND p.ID = cc.PERSONID
WHERE
    cc.MISSINGPAYMENT = 0
